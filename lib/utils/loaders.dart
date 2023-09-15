import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/extensions.dart';
import '../constants/text_styles.dart';
import '../providers/data_provider.dart';
import '../providers/settings_provider.dart';

showLoaderDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Center(
          child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color: ref.read(themesProvider).oppositeColor,
              )));
    },
  );
}

showImportDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return const ImportLoader();
    },
  );
}

class ImportLoader extends ConsumerWidget {
  const ImportLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: ref.watch(themesProvider).oppositeColor,
            )),
        15.ph,
        Text(
          'Importing ${ref.watch(importedCurrentProvider)}/${ref.read(importedTotalProvider)}',
          style: textStyleNormal.copyWith(
            fontSize: 15,
            color: ref.watch(themesProvider).oppositeColor,
          ),
        )
      ],
    ));
  }
}
