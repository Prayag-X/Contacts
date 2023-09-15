import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

StateProvider<String> uidProvider = StateProvider((ref) => '');
StateProvider<String> emailProvider = StateProvider((ref) => '');

StateProvider<String> searchProvider = StateProvider((ref) => '');
StateProvider<int> contactsCountProvider = StateProvider((ref) => 0);

StateProvider<DraggableScrollableController> bottomSheetControllerProvider =
StateProvider<DraggableScrollableController>(
        (ref) => DraggableScrollableController());

StateProvider<bool> expandedProvider = StateProvider((ref) => false);
StateProvider<bool> collapseProvider = StateProvider((ref) => false);
StateProvider<bool> profileModifiedProvider = StateProvider((ref) => false);

StateProvider<int> importedCurrentProvider = StateProvider((ref) => 0);
StateProvider<int> importedTotalProvider = StateProvider((ref) => 0);