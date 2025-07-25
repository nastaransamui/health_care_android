import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/patient_appointment_reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/status_badge_avatar.dart';
import 'package:timezone/timezone.dart' as tz;

class PatientAppointmentButtonSheet extends StatefulWidget {
  final PatientAppointmentReservation patientAppointmentReservation;
  const PatientAppointmentButtonSheet({super.key, required this.patientAppointmentReservation});

  @override
  State<PatientAppointmentButtonSheet> createState() => _PatientAppointmentButtonSheetState();
}

class _PatientAppointmentButtonSheetState extends State<PatientAppointmentButtonSheet> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final PatientAppointmentReservation reservation = widget.patientAppointmentReservation;
    final DoctorUserProfile doctorUserProfile = reservation.doctorProfile;
    final DateTime selectedDate = reservation.selectedDate;
    final TimeType timeSlot = reservation.timeSlot;
    final String doctorId = reservation.doctorId;
    final String period = timeSlot.period;
    final String profileImage = doctorUserProfile.profileImage;
    final String doctorName = 'Dr. ${doctorUserProfile.fullName}';

    final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
    final bangkok = tz.getLocation(dotenv.env['TZ']!);

    final String currencySymbol = timeSlot.currencySymbol;
    final double total = timeSlot.total;
    final formattedTotal = NumberFormat("#,##0.00", "en_US").format(total);

    final parts = period.split(' - ');
    final startTime = parts[0];
    final endTime = parts[1];

    final encodedId = base64.encode(utf8.encode(doctorId.toString()));
    final encodedinvoice = base64.encode(utf8.encode(reservation.id.toString()));

    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
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
                    online: doctorUserProfile.online,
                    idle: doctorUserProfile.idle ?? false,
                    userType: 'doctors',
                    onTap: () {
                      context.push(
                        Uri(path: '/doctors/profile/$encodedId').toString(),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 200, // Constrain this
                    child: GestureDetector(
                      onTap: () {
                        context.push(
                          Uri(path: '/doctors/profile/$encodedId').toString(),
                        );
                      },
                      child: Text(
                        doctorName.toString(),
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
                      Text(context.tr('invoice'), style: TextStyle(color: theme.primaryColor, fontSize: 18)),
                      GestureDetector(
                        onTap: () {
                          context.push(
                            Uri(path: '/patient/dashboard/invoice-view/$encodedinvoice').toString(),
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
