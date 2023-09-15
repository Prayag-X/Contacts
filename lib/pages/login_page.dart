import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../constants/text_styles.dart';
import '../constants/themes.dart';
import '../firebase/database.dart';
import '../providers/data_provider.dart';
import '../utils/extensions.dart';
import '../utils/helper.dart';
import '../shared_widgets/custom_buttons.dart';
import '../utils/image_picker.dart';
import '../constants/constants.dart';
import '../constants/images.dart';
import '../firebase/authentication.dart';
import '../firebase/storage.dart';
import '../providers/settings_provider.dart';
import '../shared_widgets/custom_form_fields.dart';
import '../utils/image_shower.dart';
import '../shared_widgets/language_changer.dart';
import '../utils/loaders.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  ThemesDark theme = ThemesDark();
  final Authentication _auth = Authentication();
  int currentPage = 0;
  File? profilePic;
  String error = '';
  double size = 140;
  late String profilePicColor;

  GlobalKey key1 = GlobalKey();
  GlobalKey key2 = GlobalKey();
  GlobalKey key3 = GlobalKey();
  GlobalKey key4 = GlobalKey();

  TextEditingController phoneController = TextEditingController(text: '');
  TextEditingController firstNameController = TextEditingController(text: '');
  TextEditingController lastNameController = TextEditingController(text: '');
  TextEditingController addressController = TextEditingController(text: '');

  @override
  void initState() {
    profilePicColor = '#${randomColorGenerator()}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String language = ref.watch(languageProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: theme.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 25.0, right: 25, bottom: 30, top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    LanguageChanger(size: 10),
                  ],
                ),
                topHeading(),
                0.ph,
                topWidgets(),
                Column(
                  children: [
                    centerDots(),
                    25.ph,
                    bottomButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  topHeading() {
    return currentPage == 0
        ? AnimationLimiter(
            key: key3,
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: Const.animationDuration,
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: screenSize(context).height / 8,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  const ImageShower(image: Images.appLogo, size: 120),
                  Text(
                    translate('contacts'),
                    style: textStyleBold.copyWith(
                        color: theme.oppositeColor, fontSize: 37),
                  ),
                ],
              ),
            ),
          )
        : AnimationLimiter(
            key: key4,
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: Const.animationDuration,
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: screenSize(context).height / 8,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Text(
                    translate('login.register_normal'),
                    style: textStyleBold.copyWith(
                        color: theme.oppositeColor, fontSize: 37),
                  ),
                ],
              ),
            ),
          );
  }

  topWidgets() {
    return currentPage == 0
        ? AnimationLimiter(
            key: key1,
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: Const.animationDuration,
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: screenSize(context).height / 8,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Column(
                    children: [
                      Row(children: [
                        Text(
                          translate('login.one'),
                          style: textStyleBold.copyWith(
                              color: theme.secondary, fontSize: 30),
                        ),
                        Text(
                          ' ',
                          style: textStyleBold.copyWith(
                              color: theme.secondary, fontSize: 30),
                        ),
                        Text(
                          translate('login.solution'),
                          style: textStyleBold.copyWith(
                              color: theme.oppositeColor, fontSize: 30),
                        ),
                      ]),
                      10.ph,
                      Text(
                        translate('login.solution_description'),
                        style: textStyleNormal.copyWith(
                            color: theme.oppositeColor, fontSize: 15),
                        textAlign: TextAlign.justify,
                      ),
                      30.ph
                    ],
                  )
                ],
              ),
            ),
          )
        : AnimationLimiter(
            key: key2,
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: Const.animationDuration,
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: screenSize(context).height / 8,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  profilePic != null
                      ? SizedBox(
                          width: size,
                          height: size,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var pickedImage = await pickImage();
                                  setState(() => profilePic = pickedImage);
                                },
                                child: CircleAvatar(
                                  radius: size / 2,
                                  backgroundImage: FileImage(profilePic!),
                                ),
                              ),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        profilePic = null;
                                      }),
                                      child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: ThemesDark().primary,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: Icon(
                                            Icons.delete_forever_rounded,
                                            color: ThemesDark().oppositeColor,
                                            size: 25,
                                          )),
                                    ),
                                  )),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: () async {
                            var pickedImage = await pickImage();
                            setState(() => profilePic = pickedImage);
                          },
                          child: CircleAvatar(
                            radius: size / 2,
                            backgroundImage:
                                const AssetImage(Images.profileDefault),
                          ),
                        ),
                  15.ph,
                  Text(
                    ref.read(emailProvider),
                    style: textStyleNormal.copyWith(
                        color: theme.oppositeColor, fontSize: 14),
                  ),
                  40.ph,
                  TextFormFieldIntegerCustom(
                    icon: Icons.phone,
                    hintText: translate('phone'),
                    controller: phoneController,
                  ),
                  TextFormFieldCustom(
                    icon: Icons.drive_file_rename_outline_rounded,
                    hintText: translate('first_name'),
                    controller: firstNameController,
                  ),
                  TextFormFieldCustom(
                    icon: Icons.drive_file_rename_outline_rounded,
                    hintText: translate('last_name'),
                    controller: lastNameController,
                  ),
                  TextFormFieldCustom(
                    icon: Icons.location_on,
                    hintText: translate('address'),
                    controller: addressController,
                  ),
                  Text(
                    error,
                    style: textStyleNormal.copyWith(
                        fontSize: 13, color: Colors.red),
                  ),
                  20.ph,
                ],
              ),
            ),
          );
  }

  centerDots() {
    return SizedBox(
        height: 10,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: currentPage == index ? Colors.white : Colors.transparent,
                border: Border.all(color: ThemesDark().secondary, width: 1),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ));
  }

  bottomButton() {
    return currentPage == 0
        ? CustomButton(
            height: 45,
            width: double.maxFinite,
            imageIcon: Images.google,
            text: translate('login.login_with_google'),
            size: 17,
            onPressed: () async {
              showLoaderDialog(context, ref);
              User? user = await _auth.signInWithGoogle();
              if (user != null) {
                ref.read(uidProvider.notifier).state = user.uid;
                ref.read(emailProvider.notifier).state = user.email!;
                if (await _auth.isUserRegistered(user.uid)) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  await nextScreenReplace(context, 'HomePage');
                } else {
                  setState(() => currentPage = 1);
                }
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                height: 45,
                width: 100,
                text: translate('login.back'),
                size: 17,
                onPressed: () async {
                  await _auth.logout();
                  ref.read(uidProvider.notifier).state = '';
                  ref.read(emailProvider.notifier).state = '';
                  setState(() => error = '');
                  setState(() => currentPage = 0);
                },
              ),
              CustomButton(
                height: 45,
                width: screenSize(context).width - 110 - 50,
                text: translate('login.register'),
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
                  showLoaderDialog(context, ref);
                  await Database().registerUser(
                    ref,
                    firstNameController.text,
                    lastNameController.text,
                    addressController.text,
                    phoneController.text,
                    profilePicColor,
                    profilePic != null,
                  );
                  if (profilePic != null) {
                    await FireStorage().uploadUserPhoto(
                        ref,
                        profilePic ??
                            await getImageFileFromAssets(Images.profileDefault),
                        Images.profileDefaultUrlName);
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                  await nextScreenReplace(context, 'HomePage');
                },
              )
            ],
          );
  }
}
