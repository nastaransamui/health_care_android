import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';

class ExperinceMapWidget extends StatelessWidget {
  const ExperinceMapWidget({
    super.key,
    required this.doctorUserProfile,
  });

  final DoctorUserProfile doctorUserProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: doctorUserProfile.experinces.asMap().entries.map((entry) {
        final int index = entry.key;
        final ex = entry.value;
        final isLast = index == doctorUserProfile.experinces.length - 1;
        DateTime from = ex.from;
        DateTime to = ex.to;
        DateTime b = DateTime(from.year, from.month, from.day);
        int totalDays = to.difference(b).inDays;
        int y = totalDays ~/ 365;
        int m = (totalDays - y * 365) ~/ 30;
        int d = totalDays - y * 365 - m * 30;

        final String years = '$y';
        final String months = '$m';
        final String days = '$d';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                // Line
                Container(
                  width: 2,
                  height: isLast ? 80 : 102,
                  color: Theme.of(context).primaryColorLight,
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Timeline content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${ex.hospitalName} (${ex.designation})",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(ex.from)} - ${DateFormat('dd MMM yyyy').format(ex.to)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$years ${context.tr('year')}, $months ${context.tr('monthFull')}, $days ${context.tr('daysFull')}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
