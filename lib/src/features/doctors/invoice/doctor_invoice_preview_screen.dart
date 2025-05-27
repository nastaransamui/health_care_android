
// ignore: depend_on_referenced_packages
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';


class DoctorInvoicePreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;

  const DoctorInvoicePreviewScreen({super.key, required this.pdfBytes});
  Future<void> savePDFToDownloads(Uint8List pdfBytes, BuildContext context) async {
    final storageStatus = await Permission.storage.request();
    final manageStatus = await Permission.manageExternalStorage.request();

    if (storageStatus.isGranted || manageStatus.isGranted) {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final file = File('${downloadsDir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(pdfBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('savedToDownload'))),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr("storagePermissionForPDF"))),
        );
      }

      // Optional: Open app settings to let user grant MANAGE_EXTERNAL_STORAGE manually
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('invoicePreview')),
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
