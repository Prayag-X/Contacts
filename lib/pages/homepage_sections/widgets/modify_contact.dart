import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../../constants/text_styles.dart';
import '../../../providers/data_provider.dart';
import '../../../utils/extensions.dart';
import '../../../constants/constants.dart';
import '../../../constants/themes.dart';
import '../../../firebase/database.dart';
import '../../../firebase/storage.dart';
import '../../../models/contact.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared_widgets/custom_buttons.dart';
import '../../../shared_widgets/custom_form_fields.dart';
import '../../../utils/image_picker.dart';

class ModifyContact extends ConsumerStatefulWidget {
  const ModifyContact({super.key, required this.contact});
  final Contact contact;

  @override
  ConsumerState createState() => _ModifyContactState();
}

class _ModifyContactState extends ConsumerState<ModifyContact> {
  File? profilePic;
  String error = '';
  String profilePicLink = '';
  Database database = Database();
  FireStorage storage = FireStorage();
  double size = 70 * 2;

  TextEditingController phoneController = TextEditingController(text: '');
  TextEditingController firstNameController = TextEditingController(text: '');
  TextEditingController lastNameController = TextEditingController(text: '');
  TextEditingController addressController = TextEditingController(text: '');
  TextEditingController emailController = TextEditingController(text: '');

  init() {
    Future.delayed(Duration.zero).then((x) async {
      setState(() {
        phoneController.text = widget.contact.phone ?? '';
        firstNameController.text = widget.contact.firstName ?? '';
        lastNameController.text = widget.contact.lastName ?? '';
        addressController.text = widget.contact.address ?? '';
        emailController.text = widget.contact.email ?? '';
        profilePicLink = widget.contact.profilePicLink ?? '';
      });
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DraggableScrollableController bottomSheetController =
        ref.watch(bottomSheetControllerProvider);
    Themes themes = ref.watch(themesProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: DraggableScrollableSheet(
          expand: true,
          snap: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          controller: bottomSheetController,
          builder: (_, controller) => ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Const.uiRoundness),
                  topRight: Radius.circular(Const.uiRoundness)),
              child: Container(
                color: themes.primary,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, left: 20, right: 20, bottom: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Divider(
                            thickness: 1,
                            indent: 100,
                            endIndent: 100,
                            color: themes.oppositeColor,
                          ),
                          20.ph,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: themes.oppositeColor,
                                  size: 20,
                                ),
                              ),
                              Text(
                                translate('homepage.edit_contact'),
                                style: textStyleBold.copyWith(
                                    fontSize: 25, color: themes.oppositeColor),
                              ),
                              const SizedBox(
                                width: 20,
                                height: 20,
                              )
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          var pickedImage = await pickImage();
                          setState(() => profilePic = pickedImage);
                        },
                        child: Container(
                          height: size,
                          width: size,
                          decoration: BoxDecoration(
                            color: widget.contact.profilePicColor!.toColor(),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: profilePic != null || profilePicLink != ''
                                ? Stack(
                                    children: [
                                      profilePic != null
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  image: DecorationImage(
                                                      image: FileImage(
                                                          profilePic!),
                                                      fit: BoxFit.cover)))
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: Image.network(
                                                widget.contact.profilePicLink!,
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
                                              }),
                                              child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    color: themes.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .delete_forever_rounded,
                                                    color: themes.oppositeColor,
                                                    size: 25,
                                                  )),
                                            ),
                                          )),
                                    ],
                                  )
                                : Text(
                                    widget.contact.firstName![0].toUpperCase(),
                                    style: textStyleNormal.copyWith(
                                        fontSize: 70, color: Colors.black),
                                  ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
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
                          TextFormFieldCustom(
                            icon: Icons.email,
                            hintText: translate('email'),
                            controller: emailController,
                          ),
                          Text(
                            error,
                            style: textStyleNormal.copyWith(
                                fontSize: 13, color: Colors.red),
                          ),
                        ],
                      ),
                      CustomButton(
                        height: 45,
                        width: double.maxFinite,
                        icon: Icons.edit_note,
                        text: translate('homepage.save'),
                        size: 17,
                        onPressed: () async {
                          if (phoneController.text == '') {
                            setState(
                                () => error = translate('login.error_phone'));
                            return;
                          }
                          if (firstNameController.text == '') {
                            setState(
                                () => error = translate('login.error_name'));
                            return;
                          }
                          setState(() => error = '');
                          if (profilePic != null) {
                            await storage.uploadUserPhoto(ref, profilePic!,
                                widget.contact.docRef!.reference.id);
                          }
                          await database.modifyContact(
                            ref,
                            widget.contact.docRef!,
                            firstNameController.text,
                            lastNameController.text,
                            addressController.text,
                            phoneController.text,
                            emailController.text,
                            profilePicLink == ''
                                ? profilePic != null
                                    ? Const.imageLocation(ref.read(uidProvider),
                                        widget.contact.docRef!.reference.id)
                                    : ''
                                : profilePicLink,
                          );
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }
}
