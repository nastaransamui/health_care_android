import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/src/utils/build_bill_pdf.dart';
import 'package:path_provider/path_provider.dart';

class ExportBillAsPdfButton extends StatelessWidget {
  const ExportBillAsPdfButton({
    super.key,
    required,
    required this.bill,
    required this.isSameDoctor,
  });

  final Bills bill;
  final bool isSameDoctor;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Container(
          height: 38,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColorLight,
              ],
            ),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
              right: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.all(1),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              Future.delayed(Duration.zero, () async {
                if (!context.mounted) return;

                try {
                  final pdf = await buildBillPdf(context, bill, isSameDoctor);
                  final bytes = await pdf.save();
                  try {
                    // Get app-specific external directory
                    final directory = await getExternalStorageDirectory(); // path: Android/data/<package>/files/
                    if (directory == null) throw Exception("Cannot get external directory");
                    final path = directory.path;
                    final file = File('$path/bill_${bill.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
                    await file.writeAsBytes(bytes);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showConsistSnackBar(context, context.tr('savedToDownload', args: [path]));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showConsistSnackBar(context, 'Failed to save PDF: $e');
                    }
                  }
                } catch (e) {
                  debugPrint('PDF Error: $e');
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColorLight,
                    theme.primaryColor,
                  ],
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(7),
                  right: Radius.circular(7),
                ),
              ),
              child: Center(
                child: Text(
                  context.tr("exportAsPDF"),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
