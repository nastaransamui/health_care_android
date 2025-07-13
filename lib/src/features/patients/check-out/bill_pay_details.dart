import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/src/features/doctors/check-out/booking_personal_form.dart';
import 'package:health_care/src/features/patients/check-out/bill_pay_button.dart';
import 'package:pay/pay.dart';

class BillPayDetails extends StatefulWidget {
  final PatientUserProfile patientUserProfile;
  final Bills bill;
  const BillPayDetails({
    super.key,
    required this.patientUserProfile,
    required this.bill,
  });

  @override
  State<BillPayDetails> createState() => _BillPayDetailsState();
}

class _BillPayDetailsState extends State<BillPayDetails> {
  final formKey = GlobalKey<FormBuilderState>();
  bool showInfoWidget = true;
  bool showPaymentWidget = false;
  late List<PaymentItem> paymentItems = [];
  late final PaymentConfiguration defaultGooglePayConfig;

  void onSubmit() {
    final isValid = formKey.currentState?.saveAndValidate() ?? false;
    if (isValid) {
      final totalAmount = widget.bill.total.toStringAsFixed(2);
      final countryCode = widget.bill.doctorProfile.currency.first.iso2;
      final currencyCode = widget.bill.currencySymbol;
      // Update transactionInfo
      googlePayData['data']['transactionInfo']['totalPrice'] = totalAmount;
      googlePayData['data']['transactionInfo']['countryCode'] = countryCode;
      googlePayData['data']['transactionInfo']['currencyCode'] = currencyCode;

      setState(() {
        showInfoWidget = false;
        showPaymentWidget = true;
        paymentItems = [
          PaymentItem(
            status: PaymentItemStatus.final_price,
            label: 'Total',
            amount: totalAmount,
          ),
        ];
        defaultGooglePayConfig = PaymentConfiguration.fromJsonString(jsonEncode(googlePayData));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return FormBuilder(
      key: formKey,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: showInfoWidget
            ? BookingPersonalForm(
                patientUserProfile: widget.patientUserProfile,
                onSubmit: onSubmit,
                formKey: formKey,
                submitButtonText: Center(
                  child: Text(
                    context.tr("makePayment"),
                    style: TextStyle(fontSize: 18, color: textColor),
                  ),
                ),
              )
            : BillPayButton(
                bill: widget.bill,
                formKey: formKey,
                paymentItems: paymentItems,
                defaultGooglePayConfig: defaultGooglePayConfig,
              ),
      ),
    );
  }
}
