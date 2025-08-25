import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/booking_information_service.dart';
import 'package:health_care/src/features/doctors/booking/booking_helpers.dart';
import 'package:health_care/src/features/doctors/booking/countdown_timer.dart';
import 'package:health_care/src/features/doctors/booking/day_period_divider.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:moment_dart/moment_dart.dart';

class BookingButtonBox extends StatefulWidget {
  final AvailableType slot;
  final DateTime calendarValue;
  final BookingInformation bookingInformation;
  final OccupyTime? occupyTime;
  final void Function(OccupyTime?) onSetOccupy;
  final AuthProvider authProvider;
  const BookingButtonBox({
    super.key,
    required this.slot,
    required this.calendarValue,
    required this.bookingInformation,
    this.occupyTime,
    required this.onSetOccupy,
    required this.authProvider,
  });

  @override
  State<BookingButtonBox> createState() => _BookingButtonBoxState();
}

class _BookingButtonBoxState extends State<BookingButtonBox> {
  OccupyTime? occupyTime;
  OccupyTime? matchingOccupy;
  final BookingInformationService bookingInformationService = BookingInformationService();
  @override
  void initState() {
    super.initState();
    occupyTime = null;
  }

  @override
  void dispose() {
    occupyTime = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String roleName = widget.authProvider.roleName;
    final String? patientId = roleName == 'patient' ? widget.authProvider.patientProfile?.userId : widget.authProvider.doctorsProfile?.userId;
    // setState(() {
    if (widget.bookingInformation.occupyTime.isNotEmpty) {
      try {
        matchingOccupy = widget.bookingInformation.occupyTime.firstWhere(
          (occupy) =>
              occupy.selectedDate.year == widget.calendarValue.year &&
              occupy.selectedDate.month == widget.calendarValue.month &&
              occupy.selectedDate.day == widget.calendarValue.day &&
              occupy.patientId == patientId,
        );
      } catch (_) {
        matchingOccupy = null;
      }
      if (matchingOccupy != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            setState(() {
              occupyTime = matchingOccupy;
            });
            widget.onSetOccupy(matchingOccupy);
          },
        );
      }
    }
  }

  Future<void> deleteOccupationFromDb(List<String> deleteIds) async {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      showDragHandle: false,
      useSafeArea: true,
      context: context,
      builder: (context) => const LoadingScreen(),
    );
    bool succes = await bookingInformationService.deleteOccupyTime(context, deleteIds);
    if (succes) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
        setState(() {
          occupyTime = null;
        });
        widget.onSetOccupy(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AvailableType slot = widget.slot;
    final DateTime calendarValue = widget.calendarValue;
    final BookingInformation bookingInformation = widget.bookingInformation;
    final AuthProvider authProvider = widget.authProvider;
    final timeSections = {
      'morning': slot.morning,
      'afternoon': slot.afternoon,
      'evening': slot.evening,
    };
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final String roleName = authProvider.roleName;
    final String? patientId = roleName == 'patient' ? authProvider.patientProfile?.userId : authProvider.doctorsProfile?.userId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...timeSections.entries.map(
          (entry) {
            final periodName = entry.key;
            final slots = entry.value;
            if (slots.isEmpty) return const SizedBox.shrink();
            bool atListOneActive = slots.any((s) => s.active);
            final String timeRange = periodName == 'morning'
                ? '08:00 to 12:00'
                : periodName == 'afternoon'
                    ? '12:00 to 17:00'
                    : '17:00 to 21:00';

            if (atListOneActive) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DayPeriodDivider(periodName: periodName, timeRange: timeRange, textColor: textColor),
                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: slots.where((s) => s.active == true).map((TimeType timeSlot) {
                      final String period = timeSlot.period;
                      final bool isPassed = !disablePastTimeBooking(DateFormat('MMMM d, yyyy').format(calendarValue), period);
                      final bool isBooked = isTimeSlotBooked(timeSlot, calendarValue, period);
                      final bool isOccupied = isTimeSlotOccupied(bookingInformation.occupyTime, timeSlot, calendarValue);
                      final bool patientHasOccupiedTime =
                          patientHasOccupiedTimeFunction(bookingInformation.occupyTime, patientId ?? '', calendarValue, period);
                      final List<String> occupyTimeDeleteArrayOfIds = getOccupiedIdsByPatient(bookingInformation.occupyTime, patientId ?? "");
                      final String dayAndPeriodOfOcupy = getAllDayPeriodCombinations(bookingInformation.occupyTime);
                      final bool disableExactOccupy = isExactOccupyMatch(bookingInformation.occupyTime, calendarValue, period);
                      final bool disable = isPassed
                          ? true
                          : isBooked
                              ? true
                              : patientHasOccupiedTime
                                  ? false // Allow action for the user's occupied time
                                  : bookingInformation.occupyTime.any((a) => a.patientId == patientId)
                                      ? true // If the user has any occupied time, disable all other buttons
                                      : disableExactOccupy;
                      // Find matching occupyTime for current slot/date/period
                      bool isLocalySelect = false;
                      if (occupyTime != null) {
                        isLocalySelect = occupyTime?.dayPeriod == periodName &&
                            occupyTime?.timeSlot.period == period &&
                            occupyTime!.selectedDate.isAtSameDayAs(calendarValue);
                      }
                      //Remove occupyTime on pass each time
                      try {
                        matchingOccupy = bookingInformation.occupyTime.firstWhere(
                          (occupy) =>
                              occupy.selectedDate.year == calendarValue.year &&
                              occupy.selectedDate.month == calendarValue.month &&
                              occupy.selectedDate.day == calendarValue.day &&
                              occupy.timeSlot.period == timeSlot.period,
                        );
                      } catch (e) {
                        matchingOccupy = null;
                      }
                      return Tooltip(
                        message: isPassed
                            ? context.tr('bookingIsPassed')
                            : isBooked
                                ? context.tr('bookingIsReserved')
                                : isOccupied
                                    ? patientHasOccupiedTime
                                        ? 'You need to finish or remove this in process booking first.'
                                        : context.tr('bookingIsInprocess')
                                    : bookingInformation.occupyTime.any((a) => a.patientId == patientId)
                                        ? 'You have appointment that in process on $dayAndPeriodOfOcupy and not finish yet first remove that.'
                                        : '',
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (disable) {
                                  if (isOccupied) {
                                    deleteOccupationFromDb(occupyTimeDeleteArrayOfIds);
                                  } else {
                                    showModalBottomSheet(
                                      context: context,
                                      useSafeArea: true,
                                      isDismissible: true,
                                      showDragHandle: true,
                                      barrierColor: Theme.of(context).cardColor.withAlpha((0.8 * 255).round()),
                                      constraints: BoxConstraints(
                                        maxHeight: double.infinity,
                                        minWidth: MediaQuery.of(context).size.width,
                                        minHeight: MediaQuery.of(context).size.height / 5,
                                      ),
                                      scrollControlDisabledMaxHeightRatio: 1,
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            isBooked
                                                ? context.tr('bookingIsReserved')
                                                : isPassed
                                                    ? context.tr('bookingIsPassed')
                                                    : isOccupied && !patientHasOccupiedTime
                                                        ? context.tr('bookingIsInprocess')
                                                        : bookingInformation.occupyTime.any((a) => a.patientId == patientId)
                                                            ? context.tr('dayAndPeriodOfOcupy', args: [dayAndPeriodOfOcupy])
                                                            : '',
                                            textAlign: TextAlign.justify,
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  if (isOccupied) {
                                    deleteOccupationFromDb(occupyTimeDeleteArrayOfIds);
                                  } else {
                                    if (isPassed) return;
                                    final timeslot = TimeType(
                                      active: timeSlot.active,
                                      bookingsFee: timeSlot.bookingsFee,
                                      bookingsFeePrice: timeSlot.bookingsFeePrice,
                                      currencySymbol: timeSlot.currencySymbol,
                                      isReserved: timeSlot.isReserved,
                                      period: timeSlot.period,
                                      price: timeSlot.price,
                                      reservations: [],
                                      total: timeSlot.total,
                                    );
                                    setState(() {
                                      if (isLocalySelect && occupyTime != null) {
                                        // Deselect if already selected
                                        occupyTime = null;
                                        widget.onSetOccupy(null);
                                      } else {
                                        // Replace or add new one
                                        occupyTime = OccupyTime.empty(
                                          periodName,
                                          bookingInformation.doctorId,
                                          patientId ?? "",
                                          bookingInformation.id,
                                          slot.finishDate,
                                          calendarValue,
                                          slot.startDate,
                                          timeslot,
                                        );
                                        widget.onSetOccupy(occupyTime);
                                      }
                                    });
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isBooked
                                      ? theme.primaryColor
                                      : isOccupied
                                          ? hexToColor('#ffa500')
                                          : isLocalySelect
                                              ? theme.primaryColorLight
                                              : Colors.transparent,
                                  border: Border.all(color: isLocalySelect ? theme.primaryColor : theme.primaryColorLight),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 2.0),
                                          child: FaIcon(
                                            isPassed || isBooked || isOccupied ? FontAwesomeIcons.circleStop : FontAwesomeIcons.clock,
                                            size: 12,
                                            color: isPassed
                                                ? isBooked
                                                    ? textColor
                                                    : theme.disabledColor
                                                : isOccupied
                                                    ? Colors.black
                                                    : textColor,
                                          ),
                                        ),
                                        Text(
                                          period,
                                          style: TextStyle(
                                            color: isPassed
                                                ? isBooked
                                                    ? textColor
                                                    : theme.disabledColor
                                                : isOccupied
                                                    ? Colors.black
                                                    : textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${timeSlot.total} ${timeSlot.currencySymbol}',
                                      style: TextStyle(
                                        color: isPassed
                                            ? isBooked
                                                ? textColor
                                                : theme.disabledColor
                                            : isOccupied
                                                ? Colors.black
                                                : textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (matchingOccupy != null) ...[
                              CountdownTimer(
                                expireAt: matchingOccupy!.expireAt,
                                doctorId: matchingOccupy!.doctorId,
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}
