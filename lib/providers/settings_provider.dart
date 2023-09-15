import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';
import '../constants/themes.dart';

StateProvider<String> languageProvider =
    StateProvider((ref) => Const.availableLanguages[0]);

StateProvider<Themes> themesProvider =
    StateProvider<Themes>((ref) => ThemesDark());
