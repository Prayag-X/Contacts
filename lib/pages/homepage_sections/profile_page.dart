import 'dart:async';
import 'dart:io';
import 'package:flutter_contacts/flutter_contacts.dart' as phone_contact;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/text_styles.dart';
import '../../providers/data_provider.dart';
import '../../utils/extensions.dart';
import '../../utils/helper.dart';
import '../../constants/constants.dart';
import '../../constants/images.dart';
import '../../constants/themes.dart';
import '../../firebase/authentication.dart';
import '../../firebase/database.dart';
import '../../firebase/storage.dart';
import '../../models/contact.dart';
import '../../providers/settings_provider.dart';
import '../../shared_widgets/custom_buttons.dart';
import '../../shared_widgets/custom_form_fields.dart';
import '../../utils/image_picker.dart';
import '../../utils/loaders.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Database database = Database();

  @override
  Widget build(BuildContext context) {
    Themes themes = ref.watch(themesProvider);
    return StreamBuilder(
        stream: database.streamUser(ref),
        builder: (context, user) {
          if (user.connectionState == ConnectionState.waiting) {
            return Center(
                child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      color: themes.oppositeColor,
                    )));
          } else {
            return ProfilePageWidgets(
              user: user.data!,
            );
          }
        });
  }
}

class ProfilePageWidgets extends ConsumerStatefulWidget {
  const ProfilePageWidgets({super.key, required this.user});
  final Contact user;

  @override
  ConsumerState createState() => _ProfilePageWidgetsState();
}

class _ProfilePageWidgetsState extends ConsumerState<ProfilePageWidgets> {
  File? profilePic;
  String error = '';
  String profilePicLink = '';

  Database database = Database();
  Authentication auth = Authentication();
  FireStorage storage = FireStorage();

  double size = 50 * 2;
  bool darkMode = true;
  late SharedPreferences prefs;
  late String dropdownValue;

  TextEditingController phoneController = TextEditingController(text: '');
  TextEditingController firstNameController = TextEditingController(text: '');
  TextEditingController lastNameController = TextEditingController(text: '');
  TextEditingController addressController = TextEditingController(text: '');
  TextEditingController emailController = TextEditingController(text: '');

  init() async {
    dropdownValue = ref.read(languageProvider);
    Future.delayed(Duration.zero).then((x) async {
      ref.read(profileModifiedProvider.notifier).state = false;
    });
    phoneController.text = widget.user.phone ?? '';
    firstNameController.text = widget.user.firstName ?? '';
    lastNameController.text = widget.user.lastName ?? '';
    addressController.text = widget.user.address ?? '';
    emailController.text = widget.user.email ?? '';
    profilePicLink = widget.user.profilePicLink ?? '';
    prefs = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero).then((x) {
      setState(() {
        darkMode = prefs.getBool('dark_theme') ?? true;
      });
    });
  }

  importPhoneContacts() async {
    ref.read(importedCurrentProvider.notifier).state = 0;
    ref.read(importedTotalProvider.notifier).state = 0;
    if (await phone_contact.FlutterContacts.requestPermission()) {
      List<phone_contact.Contact> phoneContacts =
          await phone_contact.FlutterContacts.getContacts(
              withProperties: true, withPhoto: true);
      ref.read(importedTotalProvider.notifier).state = phoneContacts.length;
      for (phone_contact.Contact phoneContact in phoneContacts) {
        String docID = randomDocIDGenerator();
        if (phoneContact.name.first != '' && phoneContact.phones.isNotEmpty) {
          if (phoneContact.thumbnail != null) {
            var tempDir = await getTemporaryDirectory();
            File thumbnail =
                await File('${tempDir.path}/temp_thumbnail.jpg').create();
            thumbnail.writeAsBytesSync(phoneContact.thumbnail!);
            await storage.uploadUserPhoto(ref, thumbnail, docID);
          }
          await database.addContact(
              ref,
              docID,
              phoneContact.name.first,
              phoneContact.name.last,
              phoneContact.addresses.isNotEmpty
                  ? phoneContact.addresses[0].address
                  : '',
              phoneContact.phones.isNotEmpty
                  ? phoneContact.phones[0].number
                  : '',
              phoneContact.emails.isNotEmpty
                  ? phoneContact.emails[0].address
                  : '',
              phoneContact.thumbnail != null,
              '#${randomColorGenerator()}');
        }
        ref.read(importedCurrentProvider.notifier).state++;
      }
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Themes themes = ref.watch(themesProvider);
    bool profileModified = ref.watch(profileModifiedProvider);
    return Padding(
      padding:
          const EdgeInsets.only(left: 15.0, right: 15, bottom: 15, top: 15),
      child: AnimationLimiter(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: AnimationConfiguration.toStaggeredList(
          duration: Const.animationDuration,
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            CustomButton(
              height: 45,
              color: themes.tertiary,
              width: double.maxFinite,
              icon: Icons.download,
              text: translate('homepage.import_contacts'),
              size: 17,
              onPressed: () async {
                showImportDialog(context);
                await importPhoneContacts();
                if (!mounted) return;
                Navigator.pop(context);
              },
            ),
            profilePicSection(),
            profileDetailsSection(),
            settingsSection(),
            profileModified
                ? CustomButton(
                    height: 45,
                    width: double.maxFinite,
                    icon: Icons.edit_note,
                    text: translate('homepage.save'),
                    size: 17,
                    onPressed: () async {
                      if (phoneController.text == '') {
                        setState(() => error = translate('login.error_phone'));
                        return;
                      }
                      if (firstNameController.text == '') {
                        setState(() => error = translate('login.error_name'));
                        return;
                      }
                      setState(() => error = '');
                      if (profilePic != null) {
                        await storage.uploadUserPhoto(
                            ref, profilePic!, Images.profileDefaultUrlName);
                      }
                      await database.modifyUser(
                        ref,
                        firstNameController.text,
                        lastNameController.text,
                        addressController.text,
                        phoneController.text,
                        emailController.text,
                        profilePic != null
                            ? Const.imageLocation(ref.read(uidProvider),
                                Images.profileDefaultUrlName)
                            : profilePicLink,
                      );
                      ref.read(profileModifiedProvider.notifier).state = false;
                    },
                  )
                : CustomButton(
                    height: 45,
                    color: Colors.red,
                    width: double.maxFinite,
                    icon: Icons.logout,
                    text: translate('login.logout'),
                    size: 17,
                    onPressed: () async {
                      await auth.logout();
                      ref.read(uidProvider.notifier).state = '';
                      ref.read(emailProvider.notifier).state = '';
                      ref.read(emailProvider.notifier).state = '';
                      if (!mounted) return;
                      nextScreenOnly(context, '');
                    },
                  ),
          ],
        ),
      )),
    );
  }

  profilePicSection() {
    Themes themes = ref.watch(themesProvider);
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: () async {
              var pickedImage = await pickImage();
              setState(() => profilePic = pickedImage);
              ref.read(profileModifiedProvider.notifier).state = true;
            },
            child: Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                color: widget.user.profilePicColor!.toColor(),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: profilePic != null || profilePicLink != ''
                    ? Stack(
                        children: [
                          profilePic != null
                              ? Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      image: DecorationImage(
                                          image: FileImage(profilePic!),
                                          fit: BoxFit.cover)))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    widget.user.profilePicLink!,
                                    fit: BoxFit.cover,
                                    width: size,
                                    height: size,
                                  ),
                                ),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    profilePic = null;
                                    profilePicLink = '';
                                    ref
                                        .read(profileModifiedProvider.notifier)
                                        .state = true;
                                  }),
                                  child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: themes.primary,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Icon(
                                        Icons.delete_forever_rounded,
                                        color: themes.oppositeColor,
                                        size: 25,
                                      )),
                                ),
                              )),
                        ],
                      )
                    : Text(
                        widget.user.firstName![0].toUpperCase(),
                        style: textStyleNormal.copyWith(
                            fontSize: 70, color: Colors.black),
                      ),
              ),
            ),
          ),
        ),
        15.ph,
        Text(
          ref.read(emailProvider),
          style: textStyleNormal.copyWith(
              color: themes.oppositeColor, fontSize: 14),
        ),
      ],
    );
  }

  profileDetailsSection() {
    Themes themes = ref.watch(themesProvider);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: themes.tertiary.withOpacity(0.4),
            borderRadius: BorderRadius.circular(Const.uiRoundness),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Column(
              children: [
                TextFormFieldIntegerProfileCustom(
                  icon: Icons.phone,
                  hintText: translate('phone'),
                  controller: phoneController,
                ),
                TextFormFieldProfileCustom(
                  icon: Icons.drive_file_rename_outline_rounded,
                  hintText: translate('first_name'),
                  controller: firstNameController,
                ),
                TextFormFieldProfileCustom(
                  icon: Icons.drive_file_rename_outline_rounded,
                  hintText: translate('last_name'),
                  controller: lastNameController,
                ),
                TextFormFieldProfileCustom(
                  icon: Icons.location_on,
                  hintText: translate('address'),
                  controller: addressController,
                ),
              ],
            ),
          ),
        ),
        5.ph,
        Text(
          error,
          style: textStyleNormal.copyWith(fontSize: 13, color: Colors.red),
        ),
      ],
    );
  }

  settingsSection() {
    Themes themes = ref.watch(themesProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translate('homepage.theme'),
                style: textStyleNormal.copyWith(
                    fontSize: 17,
                    color: themes.oppositeColor,
                    letterSpacing: 0),
              ),
              FlutterSwitch(
                width: 50.0,
                height: 25.0,
                valueFontSize: 10.0,
                toggleSize: 25.0,
                activeColor: Colors.black,
                inactiveColor: Colors.greenAccent,
                toggleColor: Colors.blue,
                value: darkMode,
                borderRadius: 30.0,
                padding: 4.0,
                showOnOff: false,
                onToggle: (val) async {
                  if (val == true) {
                    await prefs.setBool('dark_theme', true);
                    ref.read(themesProvider.notifier).state = ThemesDark();
                  } else {
                    await prefs.setBool('dark_theme', false);
                    ref.read(themesProvider.notifier).state = ThemesLight();
                  }
                },
              ),
            ],
          ),
          10.ph,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translate('homepage.language'),
                style: textStyleNormal.copyWith(
                    fontSize: 17,
                    color: themes.oppositeColor,
                    letterSpacing: 0),
              ),
              DropdownButton<String>(
                value: dropdownValue,
                dropdownColor: themes.tertiary,
                elevation: 10,
                style: textStyleNormal.copyWith(
                    color: themes.oppositeColor, fontSize: 13),
                onChanged: (String? value) async {
                  setState(() {
                    dropdownValue = value!;
                  });
                  await prefs.setString('language', value!);
                  if (!mounted) {
                    return;
                  }
                  ref.read(languageProvider.notifier).state = value;
                  changeLocale(
                      context,
                      Const.availableLanguageCodes[
                          Const.availableLanguages.indexOf(value)]);
                },
                items: Const.availableLanguages
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          )
        ],
      ),
    );
  }
}
