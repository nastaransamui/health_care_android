import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/src/features/doctors/profile/businesshours/available_badge.dart';

class AvailabilityColumnWidget extends StatelessWidget {
  const AvailabilityColumnWidget({
    super.key,
    required this.allPeriods,
    required this.index,
    this.isToday = true, // ✅ default to today
  });

  final List<TimeType> allPeriods;
  final int index;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final DateTime targetDay = isToday ? DateTime.now() : DateTime.now().add(const Duration(days: 1));

    DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);
    final normalizedTarget = normalize(targetDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allPeriods.asMap().entries.map((secondEntry) {
        final time = secondEntry.value;
        final j = secondEntry.key;

        bool isReservedOnTargetDay = false;

        if (time.isReserved) {
          final reservationsDaysArray = time.reservations.map((a) => a.selectedDate).toList();
          isReservedOnTargetDay = reservationsDaysArray.any(
            (date) => normalize(date).isAtSameMomentAs(normalizedTarget),
          );
        }

        return Column(
          key: ValueKey('$index-$j'),
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(time.period, style: const TextStyle(fontSize: 14)),
                  AvailableBadge(
                    bgColor: time.isReserved
                        ? (isReservedOnTargetDay ? const Color.fromRGBO(242, 17, 54, 0.12) : const Color.fromRGBO(40, 199, 111, 0.12))
                        : const Color.fromRGBO(40, 199, 111, 0.12),
                    textColor: time.isReserved && isReservedOnTargetDay ? const Color(0xFFE63C3C) : const Color(0xFF28C76F),
                    text: time.isReserved ? (isReservedOnTargetDay ? context.tr('notAvailable') : context.tr('available')) : context.tr('available'),
                  )
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
