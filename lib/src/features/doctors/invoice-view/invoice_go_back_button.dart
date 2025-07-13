import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvoiceGoBackButton extends StatelessWidget {
  const InvoiceGoBackButton({super.key, required this.roleName});
  final String roleName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
              if (roleName == 'doctors') {
                context.replace('/doctors/dashboard/invoice');
              } else {
                context.replace('/patient/dashboard/invoice');
              }
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
                  context.tr("goBacktoInvoicePage"),
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
