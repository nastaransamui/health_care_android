import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/src/features/doctors/appointments/appointment_buttom_sheet.dart';
import 'package:health_care/src/utils/hex_to_color.dart';

class DoctorAppointmentShowBox extends StatefulWidget {
  final AppointmentReservation reservation;
  const DoctorAppointmentShowBox({super.key, required this.reservation});

  @override
  State<DoctorAppointmentShowBox> createState() => _DoctorAppointmentShowBoxState();
}

class _DoctorAppointmentShowBoxState extends State<DoctorAppointmentShowBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final dateFormat = DateFormat('dd MMM yyyy');
    final AppointmentReservation reservation = widget.reservation;
    final PatientUserProfile patientProfile = reservation.patientProfile;
    final DateTime selectedDate = reservation.selectedDate;
    final TimeType timeSlot = reservation.timeSlot;
    final String patientId = reservation.patientId;
    final String period = timeSlot.period;
    final String gender = patientProfile.gender;
    final String profileImage = patientProfile.profileImage;
    final String patientName = "$gender ${gender != '' ? '.' : ''} ${patientProfile.fullName}";
    final encodedId = base64.encode(utf8.encode(patientId.toString()));
    final encodedinvoice = base64.encode(utf8.encode(reservation.id.toString()));
    Color statusColor = patientProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : patientProfile.online
            ? const Color(0xFF44B700)
            : Colors.pinkAccent; // offline

    return Padding(
      padding: const EdgeInsetsGeometry.all(8.0),
      child: Card(
        elevation: 12,
        color: theme.canvasColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        splashColor: theme.primaryColorLight,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        onTap: () {
                          context.push(
                            Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                          );
                        },
                        child: Container(
                          // margin: const EdgeInsets.symmetric(
                          //   vertical: 8.0,
                          // ),
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: theme.primaryColorLight),
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: profileImage.isEmpty
                                  ? const AssetImage(
                                      'assets/images/default-avatar.png',
                                    ) as ImageProvider
                                  : CachedNetworkImageProvider(
                                      profileImage,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.primaryColor, width: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push(
                            Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                          );
                        },
                        child: Text(
                          patientName,
                          style: TextStyle(
                            color: theme.primaryColorLight,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text('#${reservation.appointmentId}', style: TextStyle(color: theme.primaryColorLight)),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.clock, size: 13, color: textColor),
                          const SizedBox(width: 5),
                          Text(
                            '${dateFormat.format(selectedDate)} $period',
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.mapMarkedAlt, size: 13, color: textColor),
                          const SizedBox(width: 5),
                          Text(
                            '${patientProfile.address1} ${patientProfile.address2}',
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.envelope, size: 13, color: textColor),
                          const SizedBox(width: 5),
                          Text(
                            patientProfile.userName,
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.phone, size: 13, color: textColor),
                          const SizedBox(width: 5),
                          Text(
                            patientProfile.mobileNumber,
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          context.push(
                            Uri(path: '/doctors/dashboard/invoice-view/$encodedinvoice').toString(),
                          );
                        },
                        child: Text(
                          reservation.invoiceId,
                          style: TextStyle(
                            color: theme.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 100, height: 80),
                    GradientButton(
                      onPressed: () {
                        showModalBottomSheet(
                          useSafeArea: true,
                          showDragHandle: true,
                          isScrollControlled: true,
                          isDismissible: true,
                          enableDrag: true,
                          context: context,
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.9,
                            child: AppointmentButtomSheet(reservation: reservation),
                          ),
                        );
                      },
                      colors: [
                        Theme.of(context).primaryColorLight,
                        Theme.of(context).primaryColor,
                      ],
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.eye, size: 13, color: textColor),
                          const SizedBox(width: 5),
                          Text(
                            context.tr("view"),
                            style: TextStyle(fontSize: 12, color: textColor),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GradientButton(
                      onPressed: () {},
                      colors: reservation.doctorPaymentStatus == "Paid"
                          ? [
                              hexToColor('#5BC236'),
                              Theme.of(context).canvasColor,
                            ]
                          : reservation.doctorPaymentStatus == 'Awaiting Request'
                              ? [
                                  hexToColor('#d32f2f'),
                                  Theme.of(context).canvasColor,
                                ]
                              : [
                                  hexToColor('#ffa500'),
                                  Theme.of(context).canvasColor,
                                ],
                      child: Row(
                        children: [
                          Text(
                            reservation.doctorPaymentStatus,
                            style: TextStyle(fontSize: 12, color: textColor),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
