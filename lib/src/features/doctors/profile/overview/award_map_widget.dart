
import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/src/features/doctors/profile/overview/format_year_of_completion.dart';

class AwardMapWidget extends StatelessWidget {
  const AwardMapWidget({
    super.key,
    required this.doctorUserProfile,
  });

  final DoctorUserProfile doctorUserProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: doctorUserProfile.awards.asMap().entries.map((entry) {
        final int index = entry.key;
        final award = entry.value;
        final isLast = index == doctorUserProfile.awards.length - 1;
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
                  height: isLast ? 58 : 80,
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
                      formatYearOfCompletion(award.year),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      award.award,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    // Text(ed.degree),
                    // const SizedBox(height: 4),
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
