import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';

class ServicesMapWidget extends StatelessWidget {
  const ServicesMapWidget({
    super.key,
    required this.doctorUserProfile,
  });

  final DoctorUserProfile doctorUserProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: doctorUserProfile.specialitiesServices.asMap().entries.map((entry) {
        final int index = entry.key;
        final service = entry.value;
        final isLast = index == doctorUserProfile.specialitiesServices.length - 1;
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
                  height: isLast ? 38 : 60,
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
                    const SizedBox(height: 4),
                    Text(
                      service,
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
