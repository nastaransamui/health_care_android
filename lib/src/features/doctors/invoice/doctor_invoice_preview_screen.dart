import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DoctorInvoicePreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final Widget title;

  const DoctorInvoicePreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.title,
  });
  Future<void> savePDFToDownloads(Uint8List pdfBytes, BuildContext context) async {
    try {
      // Get app-specific external directory
      final directory = await getExternalStorageDirectory(); // path: Android/data/<package>/files/
      if (directory == null) throw Exception("Cannot get external directory");
      final path = directory.path;
      final file = File('$path/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(pdfBytes);

      if (context.mounted) {
        showErrorSnackBar(context, context.tr('savedToDownload', args: [path]));
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, 'Failed to save PDF: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await savePDFToDownloads(pdfBytes, context);
            },
          ),
        ],
      ),
      body: SfPdfViewer.memory(pdfBytes),
    );
  }
}
