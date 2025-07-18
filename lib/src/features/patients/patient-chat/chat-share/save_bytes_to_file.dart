import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveBytesToFile({
  required Uint8List bytes,
  required String fileName,
  required BuildContext context,
  void Function(String path)? onDone,
}) async {
  try {
    final directory = await getExternalStorageDirectory();
    if (directory == null) throw Exception("Storage directory unavailable");

    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    if (onDone != null) {
      onDone(filePath);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving file: $e')),
      );
    }
  }
}
