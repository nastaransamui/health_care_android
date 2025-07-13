import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/src/features/doctors/check-out/booking_pay_button.dart';
import 'package:health_care/src/features/doctors/check-out/booking_personal_form.dart';
import 'package:pay/pay.dart';

class BookingBillDetails extends StatefulWidget {
  final PatientUserProfile patientUserProfile;
  final OccupyTime occupyTime;

  const BookingBillDetails({
    super.key,
    required this.patientUserProfile,
    required this.occupyTime,
  });

  @override
  State<BookingBillDetails> createState() => _BookingBillDetailsState();
}

class _BookingBillDetailsState extends State<BookingBillDetails> {
  final formKey = GlobalKey<FormBuilderState>();

  bool showInfoWidget = true;
  bool showPaymentWidget = false;

  late List<PaymentItem> paymentItems = [];
  late final PaymentConfiguration defaultGooglePayConfig;


  void onSubmit() {
    final isValid = formKey.currentState?.saveAndValidate() ?? false;
    if (isValid) {
      final totalAmount = widget.occupyTime.timeSlot.total.toStringAsFixed(2);
      final countryCode = widget.occupyTime.doctorProfile?.currency.first.iso2;
      final currencyCode = widget.occupyTime.timeSlot.currencySymbol;
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
                        context.tr("reserve"),
                        style: TextStyle(fontSize: 18, color: textColor),
                      ),
                    ),
              )
            : BookingPayButton(
                occupyTime: widget.occupyTime,
                formKey: formKey,
                paymentItems: paymentItems,
                defaultGooglePayConfig: defaultGooglePayConfig,
              ),
      ),
    );
  }
}
