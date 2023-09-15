import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/data_provider.dart';
import '../constants/constants.dart';
import '../constants/images.dart';
import '../constants/themes.dart';
import '../firebase/authentication.dart';
import '../providers/settings_provider.dart';
import '../utils/helper.dart';
import '../utils/image_shower.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashPage> {
  final Authentication _auth = Authentication();

  initApp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    ref.read(languageProvider.notifier).state =
        prefs.getString('language') ?? 'English';
    if (prefs.getBool('dark_theme') == false) {
      ref.read(themesProvider.notifier).state = ThemesLight();
    }
    if (!mounted) return;
    changeLocale(
        context,
        Const.availableLanguageCodes[
            Const.availableLanguages.indexOf(ref.read(languageProvider))]);
    await nextPageDecider();
  }

  Future<void> nextPageDecider() async {
    User? user = await _auth.isUserLoggedIn();
    await Future.delayed(const Duration(milliseconds: 400));
    if (user != null) {
      if (await _auth.isUserRegistered(user.uid)) {
        ref.read(uidProvider.notifier).state = user.uid;
        ref.read(emailProvider.notifier).state = user.email!;
        if (!mounted) return;
        nextScreenReplace(context, 'HomePage');
        return;
      }
    }
    if (!mounted) return;
    nextScreenReplace(context, 'LoginPage');
  }

  @override
  void initState() {
    super.initState();
    initApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesDark().primary,
      body: const Center(
        child: ImageShower(image: Images.appLogo, size: 120),
      ),
    );
  }
}
