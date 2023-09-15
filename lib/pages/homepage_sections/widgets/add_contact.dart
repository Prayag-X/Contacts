import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../../constants/text_styles.dart';
import '../../../providers/data_provider.dart';
import '../../../utils/extensions.dart';
import '../../../constants/constants.dart';
import '../../../constants/images.dart';
import '../../../constants/themes.dart';
import '../../../firebase/database.dart';
import '../../../firebase/storage.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared_widgets/custom_buttons.dart';
import '../../../shared_widgets/custom_form_fields.dart';
import '../../../utils/helper.dart';
import '../../../utils/image_picker.dart';

class AddContact extends ConsumerStatefulWidget {
  const AddContact({super.key});

  @override
  ConsumerState createState() => _AddContactState();
}

class _AddContactState extends ConsumerState<AddContact> {
  File? profilePic;
  String error = '';
  Database database = Database();
  FireStorage storage = FireStorage();
  late String profilePicColor;

  TextEditingController phoneController = TextEditingController(text: '');
  TextEditingController firstNameController = TextEditingController(text: '');
  TextEditingController lastNameController = TextEditingController(text: '');
  TextEditingController addressController = TextEditingController(text: '');
  TextEditingController emailController = TextEditingController(text: '');

  @override
  void initState() {
    profilePicColor = '#${randomColorGenerator()}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DraggableScrollableController bottomSheetController =
        ref.watch(bottomSheetControllerProvider);
    Themes themes = ref.watch(themesProvider);
    double size = 140;
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
                                translate('homepage.add_contact'),
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
                                      radius: size/2,
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
                              ),
                          )
                          : GestureDetector(
                              onTap: () async {
                                var pickedImage = await pickImage();
                                setState(() => profilePic = pickedImage);
                              },
                              child:  CircleAvatar(
                                radius: size/2,
                                backgroundImage:
                                    const AssetImage(Images.profileDefault),
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
                          String docID = randomDocIDGenerator();
                          if (profilePic != null) {
                            await storage.uploadUserPhoto(
                                ref, profilePic!, docID);
                          }
                          await database.addContact(
                              ref,
                              docID,
                              firstNameController.text,
                              lastNameController.text,
                              addressController.text,
                              phoneController.text,
                              emailController.text,
                              profilePic != null,
                              profilePicColor);
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
