import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:timezone/timezone.dart' as tz;

class LastTwoAppointmentPatientProfile extends StatelessWidget {
  const LastTwoAppointmentPatientProfile({
    super.key,
    required this.doctorPatientProfile,
    required this.theme,
  });

  final DoctorPatientProfileModel doctorPatientProfile;
  final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (doctorPatientProfile.lastTwoAppointments.isNotEmpty)
          FadeinWidget(
            isCenter: true,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Card(
                elevation: 6,
                color: Theme.of(context).canvasColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColorLight),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                      child: Text(
                    context.tr("lastTwoAppointments"),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  )),
                ),
              ),
            ),
          ),
        ...doctorPatientProfile.lastTwoAppointments.map(
          (entry) {
            final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
            final bangkok = tz.getLocation(dotenv.env['TZ']!);
            final encodedinvoice = base64.encode(utf8.encode(entry.id.toString()));
            return FadeinWidget(
              isCenter: true,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Card(
                  elevation: 6,
                  color: Theme.of(context).canvasColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).primaryColorLight),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Dr. ${entry.doctorProfile.fullName}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              dateTimeFormat.format(tz.TZDateTime.from(entry.createdDate, bangkok)),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorLight,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              entry.doctorProfile.specialities.first.specialities,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${DateFormat('dd MMM yyyy ').format(tz.TZDateTime.from(entry.selectedDate, bangkok))} ${entry.timeSlot.period}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push(
                              Uri(path: '/doctors/dashboard/invoice-view/$encodedinvoice').toString(),
                            );
                          },
                          child: Text(
                            entry.invoiceId,
                            style: TextStyle(
                              color: theme.primaryColorLight,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
