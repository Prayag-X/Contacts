import 'dart:math';
import 'package:flutter/material.dart';

Size screenSize(context) => MediaQuery.of(context).size;
double bottomInsets(context) => MediaQuery.of(context).viewInsets.bottom;
double statusBarSize(context) => MediaQuery.of(context).viewPadding.top;

nextScreen(context, String pageName) async =>
    await Navigator.pushNamed(context, '/$pageName');

nextScreenReplace(context, String pageName) async =>
    await Navigator.pushReplacementNamed(context, '/$pageName');

nextScreenOnly(context, String pageName) async => await Navigator.of(context)
    .pushNamedAndRemoveUntil('/$pageName', ModalRoute.withName('/'));

screenPop(context) => Navigator.of(context).pop();

Color darkenColor(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

Color lightenColor(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

showSnackBar(
        {required BuildContext context,
        required String message,
        int duration = 3,
        Color color = Colors.green}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 14, color: color),
        ),
        backgroundColor: Colors.black.withOpacity(0.9),
        duration: Duration(seconds: duration),
      ),
    );

String randomColorGenerator() {
  final Random random = Random();
  int r = random.nextInt(256);
  int g = random.nextInt(256);
  int b = random.nextInt(256);

  return r.toRadixString(16).padLeft(2, '0') +
      g.toRadixString(16).padLeft(2, '0') +
      b.toRadixString(16).padLeft(2, '0');
}

String randomDocIDGenerator() {
  const String chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();
  String randomString = '';

  for (int i = 0; i < 20; i++) {
    randomString += chars[random.nextInt(chars.length)];
  }

  return randomString;
}
