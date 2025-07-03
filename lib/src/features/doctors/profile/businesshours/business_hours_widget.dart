import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/src/features/doctors/profile/businesshours/availability_column_widget.dart';
import 'package:health_care/src/features/doctors/profile/businesshours/available_badge.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';

class BusinessHoursWidget extends StatelessWidget {
  const BusinessHoursWidget({
    super.key,
    required this.doctorUserProfile,
  });

  final DoctorUserProfile doctorUserProfile;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.primaryColorLight),
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${context.tr('today')}: ",
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(DateFormat('dd MMM yyyy').format(DateTime.now()))
              ],
            ),
            if (doctorUserProfile.timeslots != null &&
                doctorUserProfile.timeslots!.isNotEmpty &&
                doctorUserProfile.timeslots!.first.isTodayAvailable == true) ...[
              ...doctorUserProfile.timeslots!.first.availableSlots.asMap().entries.map((entry) {
                final availables = entry.value;
                final index = entry.key;

                final DateTime startDate = availables.startDate;
                final DateTime finishDate = availables.finishDate;
                final DateTime today = DateTime.now();

                DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

                final isTodayInRange = normalize(today).isAfter(normalize(startDate).subtract(const Duration(days: 1))) &&
                    normalize(today).isBefore(normalize(finishDate).add(const Duration(days: 1)));

                if (isTodayInRange) {
                  final allPeriods = [
                    ...availables.morning,
                    ...availables.afternoon,
                    ...availables.evening,
                  ];

                  if (allPeriods.isNotEmpty) {
                    return AvailabilityColumnWidget(allPeriods: allPeriods, index: index);
                  }
                }

                return const SizedBox.shrink();
              })
            ] else ...[
              AvailableBadge(
                bgColor: const Color.fromRGBO(242, 17, 54, 0.12),
                textColor: const Color(0xFFE63C3C),
                text: context.tr('notAvailable'),
              )
            ],
            MyDivider(theme: theme),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${context.tr('tommorow')}: ",
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(DateFormat('dd MMM yyyy').format(DateTime.now().add(const Duration(days: 1))))
              ],
            ),
            if (doctorUserProfile.timeslots != null &&
                doctorUserProfile.timeslots!.isNotEmpty &&
                doctorUserProfile.timeslots!.first.isTommorowAvailable == true) ...[
              ...doctorUserProfile.timeslots!.first.availableSlots.asMap().entries.map((entry) {
                final availables = entry.value;
                final index = entry.key;

                final DateTime startDate = availables.startDate;
                final DateTime finishDate = availables.finishDate;
                final DateTime tommorow = DateTime.now().add(const Duration(days: 1));

                DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

                final isTodayInRange = normalize(tommorow).isAfter(normalize(startDate).subtract(const Duration(days: 1))) &&
                    normalize(tommorow).isBefore(normalize(finishDate).add(const Duration(days: 1)));

                if (isTodayInRange) {
                  final allPeriods = [
                    ...availables.morning,
                    ...availables.afternoon,
                    ...availables.evening,
                  ];

                  if (allPeriods.isNotEmpty) {
                    return AvailabilityColumnWidget(allPeriods: allPeriods, index: index, isToday: false);
                  }
                }

                return const SizedBox.shrink();
              })
            ] else ...[
              AvailableBadge(
                bgColor: const Color.fromRGBO(242, 17, 54, 0.12),
                textColor: const Color(0xFFE63C3C),
                text: context.tr('notAvailable'),
              )
            ],
          ],
        ),
      ),
    );
  }
}
