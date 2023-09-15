import 'package:flutter/material.dart';

extension SizedBoxPadding on num {
  SizedBox get ph => SizedBox(height: toDouble());
  SizedBox get pw => SizedBox(width: toDouble());
}

extension ColorExtension on String {
  toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension Formatter on String {
  String get formatPhoneNumber {
    String formatted = '';
    for (int i = 1; i <= length; i++) {
      if (i != length && i % 3 == 0) {
        formatted += '${this[i - 1]} ';
      } else {
        formatted += this[i - 1];
      }
    }
    return formatted;
  }
}
