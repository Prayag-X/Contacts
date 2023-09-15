import 'package:flutter/material.dart';

abstract class Themes {
  Color get primary;
  Color get oppositeColor;
  Color get tertiary;
  Color get secondary;
}

class ThemesDark implements Themes {
  @override
  final Color primary = const Color(0xFF1E1721);
  @override
  final Color oppositeColor = Colors.white;
  @override
  final Color tertiary = const Color(0xFF2B2233);
  @override
  final Color secondary = const Color(0xFF0037FF);
}

class ThemesLight implements Themes {
  @override
  final Color primary = const Color(0xFFFFFFFF);
  @override
  final Color oppositeColor = const Color(0xFF000000);
  @override
  final Color tertiary = const Color(0xFFD3D7E3);
  @override
  final Color secondary = const Color(0xFF3C5BFF);
}
