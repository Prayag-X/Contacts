import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<File?> pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile == null) {
    return null;
  }
  return File(pickedFile.path);
}

Future<File> getImageFileFromAssets(String path) async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  var filePath = "$tempPath/$path";
  var file = File(filePath);
  if (file.existsSync()) {
    return file;
  } else {
    final byteData = await rootBundle.load(path);
    final buffer = byteData.buffer;
    await file.create(recursive: true);
    return file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
}
