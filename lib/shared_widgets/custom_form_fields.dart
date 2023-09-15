import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/data_provider.dart';
import '../constants/text_styles.dart';
import '../constants/themes.dart';
import '../providers/settings_provider.dart';

InputDecoration formFieldDecoration(
        IconData icon, String hintText, Themes themes) =>
    InputDecoration(
      prefixIcon: Icon(
        icon,
        color: themes.oppositeColor.withOpacity(0.7),
        size: 20,
      ),
      labelText: hintText,
      labelStyle: textStyleNormal.copyWith(
          fontSize: 17, color: themes.oppositeColor.withOpacity(0.3)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: themes.secondary, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: themes.oppositeColor.withOpacity(0.3), width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.transparent, width: 1),
      ),
    );

class TextFormFieldCustom extends ConsumerWidget {
  const TextFormFieldCustom({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hintText,
  }) : super(key: key);

  final TextEditingController controller;
  final IconData icon;
  final String hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Themes themes = ref.watch(themesProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.maxFinite,
        child: TextFormField(
          decoration: formFieldDecoration(icon, hintText, themes),
          style: textStyleNormal.copyWith(
              color: themes.oppositeColor, fontSize: 17),
          controller: controller,
        ),
      ),
    );
  }
}

class TextFormFieldIntegerCustom extends ConsumerWidget {
  const TextFormFieldIntegerCustom({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hintText,
  }) : super(key: key);

  final TextEditingController controller;
  final IconData icon;
  final String hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Themes themes = ref.watch(themesProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.maxFinite,
        child: TextFormField(
          decoration: formFieldDecoration(icon, hintText, themes),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          style: textStyleNormal.copyWith(
              color: themes.oppositeColor, fontSize: 17),
          controller: controller,
        ),
      ),
    );
  }
}

class TextFormFieldProfileCustom extends ConsumerStatefulWidget {
  const TextFormFieldProfileCustom({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hintText,
  }) : super(key: key);

  final TextEditingController controller;
  final IconData icon;
  final String hintText;

  @override
  ConsumerState createState() => _TextFormFieldProfileCustomState();
}

class _TextFormFieldProfileCustomState
    extends ConsumerState<TextFormFieldProfileCustom> {
  bool enabled = false;

  @override
  Widget build(BuildContext context) {
    Themes themes = ref.watch(themesProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 8,
            child: TextFormField(
              decoration:
                  formFieldDecoration(widget.icon, widget.hintText, themes),
              enabled: enabled,
              style: textStyleNormal.copyWith(
                  color: themes.oppositeColor, fontSize: 17),
              controller: widget.controller,
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  enabled = !enabled;
                });
                ref.read(profileModifiedProvider.notifier).state = true;
              },
              child: Icon(
                !enabled ? Icons.edit_note : Icons.save_alt_rounded,
                color: Colors.green.withOpacity(0.5),
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TextFormFieldIntegerProfileCustom extends ConsumerStatefulWidget {
  const TextFormFieldIntegerProfileCustom({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hintText,
  }) : super(key: key);

  final TextEditingController controller;
  final IconData icon;
  final String hintText;

  @override
  ConsumerState createState() => _TextFormFieldIntegerProfileCustomState();
}

class _TextFormFieldIntegerProfileCustomState
    extends ConsumerState<TextFormFieldIntegerProfileCustom> {
  bool enabled = false;

  @override
  Widget build(BuildContext context) {
    Themes themes = ref.watch(themesProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: TextFormField(
              decoration:
                  formFieldDecoration(widget.icon, widget.hintText, themes),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              enabled: enabled,
              style: textStyleNormal.copyWith(
                  color: themes.oppositeColor, fontSize: 17),
              controller: widget.controller,
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  enabled = !enabled;
                });
                ref.read(profileModifiedProvider.notifier).state = true;
              },
              child: Icon(
                !enabled ? Icons.edit_note : Icons.save_alt_rounded,
                color: Colors.green.withOpacity(0.5),
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}
