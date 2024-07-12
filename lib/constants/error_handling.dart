import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:toastify/toastify.dart';
import 'package:http/http.dart' as http;

void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  switch (response.statusCode) {
    case 200:
      onSuccess();
      break;
    case 400:
      if (context.mounted) {
        var snackBar = SnackBar(content: Text(jsonDecode(response.body)['msg']));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      break;
    case 500:
      if (context.mounted) {
        var snackBar = SnackBar(content: Text(jsonDecode(response.body)['error']));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      break;
    default:
      if (context.mounted) {
        var snackBar = SnackBar(content: Text(jsonDecode(response.body)));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
  }
}

class CustomInfoToast extends StatelessWidget {
  const CustomInfoToast({
    super.key,
    required this.title,
    required this.description,
    required this.closeText,
    required this.confirmText,
    required this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String description;
  final String closeText;
  final String confirmText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: hexToColor('#ad1c5f'),
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
          )
        ],
      ),
      margin: const EdgeInsets.all(1),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        description,
                        overflow: TextOverflow.visible,
                        maxLines: 4,
                        style: const TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Toastify.of(context).remove(this);
                    Future<void> confirmDelay() async {
                      // Navigator.pop(context);
                      await Future<void>.delayed(const Duration(milliseconds: 1000), () {
                        onConfirm();
                      });
                    }

                    confirmDelay();
                    showModalBottomSheet(
                      isDismissible: false,
                      enableDrag: false,
                      showDragHandle: false,
                      useSafeArea: true,
                      context: context,
                      builder: (context) => const LoadingScreen(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    // minimumSize: const Size(150, 40),
                    elevation: 5.0,
                    foregroundColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 1000),
                    backgroundColor: Theme.of(context).primaryColorLight,
                    shadowColor: Theme.of(context).primaryColorLight,
                  ),
                  child: Text(context.tr(confirmText)),
                ),
                const Spacer(), // Defaults to flex: 1
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 40),
                    elevation: 5.0,
                    foregroundColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 1000),
                    backgroundColor: Theme.of(context).primaryColor,
                    shadowColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    Toastify.of(context).removeAll();
                    if (onCancel != null) {
                      Navigator.maybePop(context);
                    }
                  },
                  child: Text(context.tr(closeText)),
                ),
                const Spacer()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
