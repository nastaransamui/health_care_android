import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/features/patients/dependents/patients_dependants_show_box.dart';

void showDeleteConfirmationDialog(BuildContext context, VoidCallback onDelete) {
  showDialog(
    context: context,
    barrierDismissible: false, // prevent tap outside to dismiss
    builder: (context) {
      final ThemeData theme = Theme.of(context);
      return Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 8.0),
                child: Row(
                  children: [
                    Text(
                      context.tr('delete'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close, color: theme.primaryColor),
                    ),
                  ],
                ),
              ),
              MyDevider(theme: theme),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  context.tr('deleteQuestion'),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // close the dialog
                      onDelete(); // callback for deletion
                    },
                    child: Text(
                      context.tr('delete'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close the dialog
                    },
                    child: Text(
                      context.tr('cancel'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
