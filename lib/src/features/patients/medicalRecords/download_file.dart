import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadFile(
  String fileUrl,
  BuildContext context,
  void Function(double)? onProgress,
  void Function(String path)? onDone,
) async {
  try {
    final uri = Uri.parse(fileUrl);
    final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last.split('?').first : "downloaded_file";

    final directory = await getExternalStorageDirectory();
    if (directory == null) throw Exception("Cannot access internal app storage");

    final savePath = "${directory.path}/$fileName";

    final dio = Dio();
    final response = await dio.download(
      fileUrl,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );

    if (response.statusCode == 200 && onDone != null) {
      onDone(savePath);
    } else {
      throw Exception("Download failed: ${response.statusCode}");
    }
  } catch (e) {
    if (context.mounted) {
      showErrorSnackBar(context, 'Failed to download: $e');
    }
  }
}
