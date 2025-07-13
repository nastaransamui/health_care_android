import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/services/booking_information_service.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:pay/pay.dart';

class BookingPayButton extends StatefulWidget {
  final OccupyTime occupyTime;
  final GlobalKey<FormBuilderState> formKey;
  final List<PaymentItem> paymentItems;
  final PaymentConfiguration defaultGooglePayConfig;
  const BookingPayButton({
    super.key,
    required this.occupyTime,
    required this.formKey,
    required this.paymentItems,
    required this.defaultGooglePayConfig,
  });

  @override
  State<BookingPayButton> createState() => _BookingPayButtonState();
}

class _BookingPayButtonState extends State<BookingPayButton> {
  final BookingInformationService bookingInformationService = BookingInformationService();

  void onGooglePayResult(paymentResult) async {
    // Example: Extract token
    final paymentMethodData = paymentResult['paymentMethodData'];
    final paymentToken = paymentMethodData?['tokenizationData']?['token'];
    final paymentType = paymentMethodData?['tokenizationData']?['type'];

    if (paymentToken != null) {
      widget.occupyTime.timeSlot.isReserved = true;
      TimeType timeSlot = widget.occupyTime.timeSlot;
      var serverParams = {
        "timeSlot": timeSlot,
        "selectedDate": widget.occupyTime.selectedDate.toIso8601String(),
        "dayPeriod": widget.occupyTime.dayPeriod,
        "doctorId": widget.occupyTime.doctorId,
        "startDate": widget.occupyTime.startDate.toIso8601String(),
        "finishDate": widget.occupyTime.finishDate.toIso8601String(),
        "slotId": widget.occupyTime.slotId,
        "patientId": widget.occupyTime.patientId,
        "paymentToken": paymentToken,
        "paymentType": paymentType
      };
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
      final String ocuppyId = widget.occupyTime.id;
      String newReservationId = await bookingInformationService.reserveAppointment(
        context,
        serverParams,
        updateMyInfo,
        newProfileInfo,
        ocuppyId,
      );
      if (newReservationId.isNotEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).maybePop();
          final encodedReservationId = base64.encode(utf8.encode(newReservationId.toString()));
          context.go(Uri(path: '/doctors/payment-success/$encodedReservationId').toString());
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
