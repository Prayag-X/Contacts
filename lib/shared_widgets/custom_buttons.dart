import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/text_styles.dart';
import '../utils/extensions.dart';
import '../utils/image_shower.dart';
import '../constants/constants.dart';
import '../constants/themes.dart';
import '../providers/settings_provider.dart';

class CustomButton extends ConsumerWidget {
  const CustomButton(
      {super.key,
      required this.height,
      required this.width,
      this.icon,
      this.imageIcon,
      required this.text,
      required this.size,
      required this.onPressed,
        this.color,
      this.padding = EdgeInsets.zero});

  final double height;
  final double width;
  final IconData? icon;
  final String? imageIcon;
  final String text;
  final double size;
  final EdgeInsets padding;
  final Color? color;
  final Function onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Themes themes = ref.watch(themesProvider);
    return Padding(
      padding: padding,
      child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: color ?? themes.secondary,
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Const.uiRoundness - 2),
              )),
          onPressed: () async => await onPressed(),
          child: SizedBox(
            height: height,
            width: width,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon != null
                      ? Icon(
                          icon,
                          color: themes.oppositeColor,
                          size: size + 2,
                        )
                      : 0.pw,
                  imageIcon != null
                      ? ImageShower(image: imageIcon!, size: size)
                      : 0.pw,
                  icon != null || imageIcon != null ? 15.pw : 0.pw,
                  Text(text,
                      style: textStyleBold.copyWith(
                        fontSize: size,
                        color: themes.oppositeColor,
                      )),
                  icon != null || imageIcon != null ? 15.pw : 0.pw,
                ],
              ),
            ),
          )),
    );
  }
}
