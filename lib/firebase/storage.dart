import 'dart:io';
import 'package:contacts/providers/data_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FireStorage {
  final FirebaseStorage storage = FirebaseStorage.instance;

  uploadUserPhoto(WidgetRef ref, File file, String name) async {
    // String extension = file.path.split('.').last;
    Reference storageRef = storage.ref().child('${ref.read(uidProvider)}/$name.jpg');
    await storageRef.putFile(file);
  }
}
