import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/users.dart';

class AvailablityTimeShow extends StatefulWidget {
  final DoctorUserProfile doctorUserProfile;
  const AvailablityTimeShow({
    super.key,
    required this.doctorUserProfile,
  });

  @override
  State<AvailablityTimeShow> createState() => _AvailablityTimeShowState();
}

class _AvailablityTimeShowState extends State<AvailablityTimeShow> {
  Map<String, bool> showPrice = {
    "morning": false,
    "afternoon": false,
    "evening": false,
  };
  String showPricePeriod = "";
  @override
  Widget build(BuildContext context) {
    DoctorUserProfile doctorUserProfile = widget.doctorUserProfile;
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (doctorUserProfile.timeslots != null && doctorUserProfile.timeslots!.isNotEmpty)
          ...doctorUserProfile.timeslots!.first.availableSlots.asMap().entries.map((entry) {
            final time = entry.value;
            // final timeIndex = entry.key;

            String periodLabel(DateTime start, DateTime end) {
              return "${DateFormat('dd MMM yyyy').format(start)} to ${DateFormat('dd MMM yyyy').format(end)}";
            }

            final periodRange = periodLabel(time.startDate, time.finishDate);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  periodRange,
                  style: TextStyle(
                    fontSize: 20,
                    color: theme.primaryColorLight,
                  ),
                ),
                // Show information on click
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.vertical,
                      child: child,
                    );
                  },
                  child: showPrice.containsValue(true)
                      ? Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...showPrice.entries.where((e) => e.value).expand((entry) {
                                final periodKey = entry.key;

                                return doctorUserProfile.timeslots!.expand((slot) {
                                  return slot.availableSlots.expand((available) {
                                    final formattedPeriod =
                                        "${DateFormat('dd MMM yyyy').format(available.startDate)} to ${DateFormat('dd MMM yyyy').format(available.finishDate)}";

                                    if (formattedPeriod == showPricePeriod) {
                                      final periodArray = available.toJson()[periodKey] as List<dynamic>;

                                      return periodArray.asMap().entries.map((e) {
                                        final time = TimeType.fromJson(e.value);

                                        return time.active
                                            ? Text(
                                                "${time.period} : ${NumberFormat("#,##0.00", "en_US").format(time.total)} ${time.currencySymbol}",
                                                style: const TextStyle(fontSize: 20),
                                              )
                                            : const SizedBox();
                                      });
                                    }
                                    return [];
                                  });
                                });
                              }),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (time.morning.isNotEmpty)
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: time.morning.any((t) => t.active),
                    onChanged: (_) {
                      setState(() {
                        showPrice = {
                          'morning': !showPrice['morning']!,
                          'afternoon': false,
                          'evening': false,
                        };
                        showPricePeriod = periodRange;
                      });
                    },
                    title: Text(
                      context.tr('morning'),
                      style: TextStyle(
                        color: showPrice['morning'] == true && showPricePeriod == periodRange ? theme.primaryColorLight : textColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    subtitle: Text("${DateFormat.Hm().format(morningStart)} to ${DateFormat.Hm().format(morningFinish)}"),
                  ),
                if (time.afternoon.isNotEmpty)
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: time.afternoon.any((t) => t.active),
                    onChanged: (_) {
                      setState(() {
                        showPrice = {
                          'morning': false,
                          'afternoon': !showPrice['afternoon']!,
                          'evening': false,
                        };
                        showPricePeriod = periodRange;
                      });
                    },
                    title: Text(
                      context.tr('afternoon'),
                      style: TextStyle(
                        color: showPrice['afternoon'] == true && showPricePeriod == periodRange ? theme.primaryColorLight : textColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    subtitle: Text("${DateFormat.Hm().format(afterNoonStart)} to ${DateFormat.Hm().format(afterNoonFinish)}"),
                  ),
                if (time.evening.isNotEmpty)
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: time.evening.any((t) => t.active),
                    onChanged: (_) {
                      setState(() {
                        showPrice = {
                          'morning': false,
                          'afternoon': false,
                          'evening': !showPrice['evening']!,
                        };
                        showPricePeriod = periodRange;
                      });
                    },
                    title: Text(
                      context.tr('evening'),
                      style: TextStyle(
                        color: showPrice['evening'] == true && showPricePeriod == periodRange ? theme.primaryColorLight : textColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    subtitle: Text("${DateFormat.Hm().format(eveningStart)} to ${DateFormat.Hm().format(eveningFinish)}"),
                  ),
              ],
            );
          }),
      ],
    );
  }
}
