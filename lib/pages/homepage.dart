import 'dart:async';
import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:contacts/constants/text_styles.dart';
import 'package:contacts/pages/homepage_sections/contacts_page.dart';
import 'package:contacts/pages/homepage_sections/profile_page.dart';
import 'package:contacts/providers/data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../constants/constants.dart';
import '../constants/themes.dart';
import '../providers/settings_provider.dart';
import 'homepage_sections/widgets/add_contact.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int page = 0;
  TextEditingController controller = TextEditingController(text: '');
  bool listening = false;
  final SpeechToText _speechToText = SpeechToText();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
  }

  void _startListening() async {
    _speechToText.listen(onResult: _onSpeechResult);
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    ref.read(searchProvider.notifier).state = result.recognizedWords;
    controller.text = result.recognizedWords;
  }

  @override
  Widget build(BuildContext context) {
    Themes themes = ref.watch(themesProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar(),
        backgroundColor: themes.primary,
        extendBody: true,
        body: page == 0
            ? const ContactsPage()
            : const SafeArea(child: ProfilePage()), //destination screen
        floatingActionButton: page == 0
            ? FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      enableDrag: true,
                      context: context,
                      builder: (context) => const AddContact());
                },
                elevation: 0,
                backgroundColor: themes.tertiary,
                child: Icon(
                  Icons.person_add_alt_rounded,
                  color: themes.oppositeColor,
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar(
          height: Const.bottomNavBarHeight,
          splashRadius: 0,
          backgroundColor: themes.tertiary,
          inactiveColor: themes.oppositeColor,
          activeColor: themes.secondary,
          elevation: 0,
          icons: const [Icons.people_outline_rounded, Icons.person_pin_rounded],
          activeIndex: page,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          onTap: (index) => setState(() {
            page = index;
          }),
          //other params
        ),
      ),
    );
  }

  appBar() {
    Themes themes = ref.watch(themesProvider);
    return page == 0
        ? AppBar(
            toolbarHeight: Const.appBarHeight,
            elevation: 0,
            backgroundColor: themes.primary,
            title: SizedBox(
              width: double.maxFinite,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: themes.tertiary,
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          if (listening) {
                            _stopListening();
                          } else {
                            _startListening();
                          }
                          setState(() {
                            listening = !listening;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 13.0, right: 8),
                          child: Icon(
                            listening ? Icons.mic : Icons.mic_off_rounded,
                            color: !listening
                                ? themes.oppositeColor
                                : Colors.green,
                            size: 23,
                          ),
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 13.0, right: 8),
                        child: Icon(
                          Icons.search_rounded,
                          color: themes.oppositeColor,
                          size: 25,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 25),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  !listening ? themes.secondary : Colors.green,
                              width: 1),
                          borderRadius: BorderRadius.circular(35.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: !listening
                                  ? Colors.transparent
                                  : Colors.green,
                              width: 1),
                          borderRadius: BorderRadius.circular(35.0)),
                      hintText:
                          '${ref.watch(contactsCountProvider)} ${translate('contacts')}',
                      hintStyle: textStyleNormal.copyWith(
                          color: themes.oppositeColor.withOpacity(0.5),
                          fontSize: 16)),
                  style: textStyleNormal.copyWith(
                      color: themes.oppositeColor, fontSize: 16),
                  controller: controller,
                  onChanged: (val) {
                    ref.read(searchProvider.notifier).state = val;
                  },
                ),
              ),
            ),
          )
        : null;
  }
}
