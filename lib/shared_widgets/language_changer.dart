import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/text_styles.dart';
import '../constants/themes.dart';
import '../constants/constants.dart';
import '../providers/settings_provider.dart';
import '../utils/helper.dart';

class LanguageChanger extends ConsumerStatefulWidget {
  const LanguageChanger({
    super.key,
    required this.size,
  });
  final double size;

  @override
  ConsumerState createState() => _LanguageChangerState();
}

class _LanguageChangerState extends ConsumerState<LanguageChanger> {
  late String dropdownValue;
  late SharedPreferences prefs;

  init() async {
    dropdownValue = ref.read(languageProvider);
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Themes themes = ref.watch(themesProvider);
    return DropdownButton<String>(
      value: dropdownValue,
      dropdownColor: darkenColor(themes.primary, 0.02),
      elevation: 10,
      style: textStyleNormal.copyWith(
          color: themes.oppositeColor, fontSize: widget.size),
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
          child: Text(
            value,
            style: textStyleNormal.copyWith(
                color: themes.oppositeColor, fontSize: widget.size),
          ),
        );
      }).toList(),
    );
  }
}
