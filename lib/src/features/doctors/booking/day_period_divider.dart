import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DayPeriodDivider extends StatelessWidget {
  const DayPeriodDivider({
    super.key,
    required this.periodName,
    required this.timeRange,
    required this.textColor,
  });

  final String periodName;
  final String timeRange;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${context.tr(periodName)}\n$timeRange',
              style: TextStyle(color: textColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
