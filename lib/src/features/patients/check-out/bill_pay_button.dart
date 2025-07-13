import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/services/bill_service.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:pay/pay.dart';

class BillPayButton extends StatefulWidget {
  final Bills bill;
  final GlobalKey<FormBuilderState> formKey;
  final List<PaymentItem> paymentItems;
  final PaymentConfiguration defaultGooglePayConfig;
  const BillPayButton({
    super.key,
    required this.bill,
    required this.formKey,
    required this.paymentItems,
    required this.defaultGooglePayConfig,
  });

  @override
  State<BillPayButton> createState() => _BillPayButtonState();
}

class _BillPayButtonState extends State<BillPayButton> {
  final BillService billService = BillService();
  void onGooglePayResult(paymentResult) async {
    // Example: Extract token
    final paymentMethodData = paymentResult['paymentMethodData'];
    final paymentToken = paymentMethodData?['tokenizationData']?['token'];
    final paymentType = paymentMethodData?['tokenizationData']?['type'];

    if (paymentToken != null) {
      final serverParams = widget.bill.toMap(paymentToken, paymentType);
      final data = widget.formKey.currentState!.value;

      var newProfileInfo = {
        "email": data['email'],
        "firstName": data['firstName'],
        "lastName": data['lastName'],
        "mobileNumber": data['mobileNumber']
      };
      var updateMyInfo = data['updateMyInfo'];
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: true,
        context: context,
        builder: (context) => const LoadingScreen(),
      );

      // final String ocuppyId = widget.occupyTime.id;
      String newBillId = await billService.updateBillingPayment(context, serverParams, updateMyInfo, newProfileInfo);
      if (newBillId.isNotEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).maybePop();
          final encodedReservationId = base64.encode(utf8.encode(newBillId.toString()));
          context.go(Uri(path: '/patient/payment-success/$encodedReservationId').toString());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('paymentMethod'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: GooglePayButton(
            paymentConfiguration: widget.defaultGooglePayConfig,
            paymentItems: widget.paymentItems,
            type: GooglePayButtonType.buy,
            onPaymentResult: onGooglePayResult,
            cornerRadius: 4,
            theme: theme.brightness == Brightness.dark ? GooglePayButtonTheme.dark : GooglePayButtonTheme.light,
            loadingIndicator: const Center(child: CircularProgressIndicator()),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
