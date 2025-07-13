import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/status_badge_avatar.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:timezone/timezone.dart' as tz;

class AppointmentButtomSheet extends StatefulWidget {
  final AppointmentReservation reservation;
  final ScrollController scrollController;
  const AppointmentButtomSheet({
    super.key,
    required this.reservation,
    required this.scrollController,
  });

  @override
  State<AppointmentButtomSheet> createState() => _AppointmentButtomSheetState();
}

class _AppointmentButtomSheetState extends State<AppointmentButtomSheet> {
  @override
  Widget build(BuildContext context) {
    final AppointmentReservation reservation = widget.reservation;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final dateFormat = DateFormat('dd MMM yyyy');
    final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    final PatientUserProfile patientProfile = reservation.patientProfile!;
    final DateTime selectedDate = reservation.selectedDate;
    final TimeType timeSlot = reservation.timeSlot;
    final String patientId = reservation.patientId;
    final String period = timeSlot.period;
    final String currencySymbol = timeSlot.currencySymbol;
    final double total = timeSlot.total;
    final formattedTotal = NumberFormat("#,##0.00", "en_US").format(total);
    final parts = period.split(' - ');
    final startTime = parts[0];
    final endTime = parts[1];
    final String gender = patientProfile.gender;
    final String profileImage = patientProfile.profileImage;
    final String patientName = "$gender ${gender != '' ? '.' : ''} ${patientProfile.fullName}";
    final encodedId = base64.encode(utf8.encode(patientId.toString()));

    final encodedInvoice = base64.encode(utf8.encode(reservation.id.toString()));
    return Scaffold(
      body: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatusBadgeAvatar(
                    imageUrl: profileImage,
                    online: patientProfile.online,
                    idle: patientProfile.idle ?? false,
                    userType: 'patient',
                    onTap: () {
                      context.push(
                        Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 200, // Constrain this
                    child: GestureDetector(
                      onTap: () {
                        context.push(
                          Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                        );
                      },
                      child: Text(
                        patientName.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: theme.primaryColor, decoration: TextDecoration.underline, fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 1,
              color: theme.primaryColorLight,
            ),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${reservation.appointmentId}', style: TextStyle(color: theme.primaryColor, fontSize: 18)),
                      Text(
                        dateFormat.format(selectedDate),
                        style: const TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColorLight,
                          theme.primaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(123, 140, 210, 0.3),
                          offset: Offset(0, 12),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        context.tr("confirmed"),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsetsGeometry.directional(start: 16, end: 16),
              color: theme.primaryColorLight,
            ),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('start'), style: TextStyle(color: theme.primaryColor, fontSize: 18)),
                      Text(
                        startTime,
                        style: const TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsetsGeometry.directional(start: 16, end: 16),
              color: theme.primaryColorLight,
            ),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('finish'), style: TextStyle(color: theme.primaryColor, fontSize: 18)),
                      Text(
                        endTime,
                        style: const TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsetsGeometry.directional(start: 16, end: 16),
              color: theme.primaryColorLight,
            ),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('confirmDate'), style: TextStyle(color: theme.primaryColor, fontSize: 18)),
                      Text(
                        dateTimeFormat.format(tz.TZDateTime.from(reservation.createdDate, bangkok)),
                        style: const TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsetsGeometry.directional(start: 16, end: 16),
              color: theme.primaryColorLight,
            ),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('status'), style: TextStyle(color: theme.primaryColor, fontSize: 18)),
                      Chip(
                        label: Text(
                          reservation.doctorPaymentStatus,
                          style: TextStyle(color: textColor),
                        ),
                        backgroundColor: reservation.doctorPaymentStatus == "Paid"
                            ? Colors.green
                            : reservation.doctorPaymentStatus == "Awaiting Request"
                                ? hexToColor('#f44336')
                                : hexToColor('#ffa500'), // Chip background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                          side: BorderSide.none, // optional: border color/width
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsetsGeometry.directional(start: 16, end: 16),
              color: theme.primaryColorLight,
            ),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('invoice'),
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(
                            Uri(path: '/doctors/dashboard/invoice-view/$encodedInvoice').toString(),
                          );
                        },
                        child: Text(
                          reservation.invoiceId,
                          style: TextStyle(
                            color: theme.primaryColorLight,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsetsGeometry.directional(start: 16, end: 16),
              color: theme.primaryColorLight,
            ),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('price'), style: TextStyle(color: theme.primaryColor, fontSize: 18)),
                      Text(
                        '$formattedTotal $currencySymbol',
                        style: const TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsetsGeometry.directional(start: 16, end: 16),
              color: theme.primaryColorLight,
            ),
          ],
        ),
      ),
    );
  }
}
