import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:health_care/constants/error_handling.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/time_schedule_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/utils/gradient_text.dart';

AvailableType calculateFeeAndTotal(AvailableType availableType) {
  List<TimeType> updateList(List<TimeType> list) {
    return list.map((slot) {
      final feeAmount = double.parse(((slot.price * slot.bookingsFee) / 100).toStringAsFixed(2));
      final totalAmount = double.parse((slot.price + feeAmount).toStringAsFixed(2));

      return slot.copyWith(
        bookingsFeePrice: feeAmount,
        total: totalAmount,
      );
    }).toList();
  }

  return availableType.copyWith(
    morning: updateList(availableType.morning),
    afternoon: updateList(availableType.afternoon),
    evening: updateList(availableType.evening),
  );
}

class DoctorsDashboardScheduleTiming extends StatefulWidget {
  static const String routeName = "/doctors/dashboard/schedule-timing";
  final DoctorsProfile doctorProfile;

  const DoctorsDashboardScheduleTiming({
    super.key,
    required this.doctorProfile,
  });

  @override
  State<DoctorsDashboardScheduleTiming> createState() => _DoctorsDashboardScheduleTimingState();
}

class _DoctorsDashboardScheduleTimingState extends State<DoctorsDashboardScheduleTiming> {
  final AuthService authService = AuthService();
  final ScrollController scheduleScrollController = ScrollController();
  final TimeScheduleService timeScheduleService = TimeScheduleService();
  final DateRangePickerController dateRangePickerController = DateRangePickerController();
  DoctorsTimeSlot? doctorTimeSlot;
  DoctorsTimeSlot? _copyDoctorTimeSlot;
  bool isLoading = true;
  double scrollPercentage = 0;
  int _forceRebuildKey = 0;
  List<PickerDateRange> _initialRanges = [];
  List<AvailableType> doctorAvailableTimes = [];
  Timer? _snackBarTimer;
  bool _isProgrammaticUpdate = false;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    _forceRebuildKey = 0;
    doctorAvailableTimes.clear();
    _initialRanges.clear();
    var timeScheduleProvider = Provider.of<TimeScheduleProvider>(context, listen: false);
    timeScheduleProvider.setLoading(true);
    timeScheduleService.getDoctorTimeSlots(context, widget.doctorProfile);
    doctorTimeSlot = Provider.of<TimeScheduleProvider>(context, listen: false).doctorsTimeSlot;
    if (doctorTimeSlot != null) {
      _copyDoctorTimeSlot = doctorTimeSlot!.copyWith();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    doctorTimeSlot = Provider.of<TimeScheduleProvider>(context).doctorsTimeSlot;
    isLoading = Provider.of<TimeScheduleProvider>(context).isLoading;
    final currentProfileId = widget.doctorProfile.userId;
    final timeSlotDoctorId = doctorTimeSlot?.doctorId;

    if (doctorTimeSlot == null) {
      _copyDoctorTimeSlot = null;
    }
    if (doctorTimeSlot == null && _copyDoctorTimeSlot == null && _initialRanges.isNotEmpty) {
      _initialRanges = [];
      _forceRebuildKey = DateTime.now().millisecondsSinceEpoch;
      _onCancel();
    }
    if (!isLoading &&
        // doctorTimeSlot != null &&
        // doctorTimeSlot!.availableSlots.isNotEmpty &&
        timeSlotDoctorId == currentProfileId) {
      _copyDoctorTimeSlot = doctorTimeSlot!.copyWith();
      // Loop through available slots and create PickerDateRange for each
      List<PickerDateRange> ranges = [];
      List<AvailableType> timetype = [];
      for (var availableSlot in _copyDoctorTimeSlot!.availableSlots) {
        timetype.add(
          AvailableType(
            afternoon: availableSlot.afternoon,
            evening: availableSlot.evening,
            finishDate: availableSlot.finishDate,
            morning: availableSlot.morning,
            startDate: availableSlot.startDate,
            timeSlot: availableSlot.timeSlot,
            isNew: false,
          ),
        );
        ranges.add(PickerDateRange(
          availableSlot.startDate.toLocal(),
          availableSlot.finishDate.toLocal(),
        ));
      }
      setState(() {
        _isProgrammaticUpdate = true;
        _showButtons = true;
        _initialRanges = ranges;
        doctorAvailableTimes = timetype;
        dateRangePickerController.selectedRanges = [..._initialRanges];
        _forceRebuildKey = DateTime.now().millisecondsSinceEpoch;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _isProgrammaticUpdate = false;
      });
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (_isProgrammaticUpdate) return;
    if (args.value is! PickerDateRange && args.value is! DateTime && args.value is! List<DateTime>) {
      final List<PickerDateRange> selectedRanges = args.value;
      if (selectedRanges.isNotEmpty) {
        final newRange = selectedRanges.last;
        if (newRange.endDate != null && newRange.startDate != null) {
          bool isOverlapping = _initialRanges.any((existingRange) => _rangesOverlap(existingRange, newRange));

          if (!isOverlapping) {
            final newAvailable = AvailableType(
              afternoon: [],
              evening: [],
              finishDate: newRange.endDate!,
              morning: [],
              startDate: newRange.startDate!,
              timeSlot: 60,
              isNew: true,
              index: _copyDoctorTimeSlot == null
                  ? 0
                  : _copyDoctorTimeSlot!.availableSlots.isEmpty
                      ? 0
                      : _copyDoctorTimeSlot!.availableSlots.length,
            );
            if (_copyDoctorTimeSlot == null) {
              _copyDoctorTimeSlot = DoctorsTimeSlot(
                doctorId: widget.doctorProfile.userId,
                createDate: DateTime.now(),
                updateDate: DateTime.now(),
                availableSlots: [newAvailable],
              );
            } else {
              _copyDoctorTimeSlot?.availableSlots.add(newAvailable);
            }
            setState(() {
              doctorAvailableTimes.add(newAvailable);
              _copyDoctorTimeSlot = _copyDoctorTimeSlot;
              _initialRanges.add(newRange);
              dateRangePickerController.selectedRanges = [..._initialRanges];
              _forceRebuildKey = DateTime.now().millisecondsSinceEpoch;
            });
          } else {
            setState(() {
              dateRangePickerController.selectedRanges = [..._initialRanges];
              _forceRebuildKey = DateTime.now().millisecondsSinceEpoch;
            });
            if (_snackBarTimer?.isActive != true) {
              showErrorSnackBar(context, context.tr("betweenScheduleError"));
              _snackBarTimer = Timer(const Duration(seconds: 1), () {});
            }
          }
        }
      }
    }
  }

  void _onCancel() {
    // Check for null safety on _copyDoctorTimeSlot
    if (_copyDoctorTimeSlot?.availableSlots != null) {
      // Use `retainWhere` to keep only those ranges that match an available slot
      _initialRanges.retainWhere((range) {
        final start = range.startDate;
        final end = range.endDate;

        // Ensure current range is valid
        if (start == null || end == null) return false;
        doctorAvailableTimes.removeWhere((times) => times.startDate == start && times.finishDate == end);
        _copyDoctorTimeSlot!.availableSlots.removeWhere((times) => times.startDate == start && times.finishDate == end);
        bool existsInSlots;
        // Check if a matching slot exists
        if (doctorTimeSlot == null) {
          existsInSlots = _copyDoctorTimeSlot!.availableSlots.any((slot) {
            return start.isAtSameMomentAs(slot.startDate) && end.isAtSameMomentAs(slot.finishDate);
          });
        } else {
          existsInSlots = doctorTimeSlot!.availableSlots.any((slot) {
            return start.isAtSameMomentAs(slot.startDate) && end.isAtSameMomentAs(slot.finishDate);
          });
        }
        return existsInSlots;
      });
    } else {
      _initialRanges = [];
      doctorAvailableTimes = [];
    }
    _isProgrammaticUpdate = true; // 👈 Prevent triggering selection logic
    setState(() {
      doctorAvailableTimes = doctorAvailableTimes;
      _initialRanges = _initialRanges;
      dateRangePickerController.selectedRanges = [..._initialRanges];
      _forceRebuildKey = DateTime.now().millisecondsSinceEpoch;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _isProgrammaticUpdate = false;
    });
  }

  void _openTimeSlotBottomSheet(AvailableType times) async {
    final updatedTimes = await showModalBottomSheet<AvailableType>(
      useSafeArea: true,
      showDragHandle: false,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      context: context,
      builder: (context) => TimeSlotBottomSheet(
        initialTimes: times,
        viewType: "edit",
      ),
    );

    if (updatedTimes != null) {
      final updated = calculateFeeAndTotal(updatedTimes);
      if (_copyDoctorTimeSlot != null) {
        final indexToReplace = _copyDoctorTimeSlot!.availableSlots.indexWhere(
          (available) =>
              available.startDate.toUtc().millisecondsSinceEpoch == times.startDate.toUtc().millisecondsSinceEpoch &&
              available.finishDate.toUtc().millisecondsSinceEpoch == times.finishDate.toUtc().millisecondsSinceEpoch,
        );
        if (indexToReplace != -1) {
          setState(() {
            _copyDoctorTimeSlot!.availableSlots[indexToReplace] = updated;
            _showButtons = true;
          });
        }
      }
    }
  }

  void saveTodb() {
    timeScheduleService.createDoctorsTimeslots(context, DoctorsTimeSlot.createJsonForSave(widget.doctorProfile.userId, _copyDoctorTimeSlot!));
  }

  void deleteDb() async {
    bool success = await timeScheduleService.deleteDoctorsTimeslots(context, _copyDoctorTimeSlot!);
    if (success) {
      setState(() {
        _copyDoctorTimeSlot = null;
        doctorTimeSlot = null;
        doctorAvailableTimes.clear();
        _initialRanges.clear();
        dateRangePickerController.selectedRanges = [];
        isLoading = true;
        _showButtons = false;
        _forceRebuildKey = DateTime.now().millisecondsSinceEpoch;
        _isProgrammaticUpdate = true;
      });
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      _isProgrammaticUpdate = false;
    });
  }

  void updateDb() {
    timeScheduleService.updateDoctorsTimeslots(context, DoctorsTimeSlot.createJsonForUpdate(widget.doctorProfile.userId, _copyDoctorTimeSlot!));

  }

  @override
  void dispose() {
    super.dispose();
    scheduleScrollController.dispose();
    dateRangePickerController.dispose();
    doctorAvailableTimes.clear();
    _initialRanges.clear();
    dateRangePickerController.selectedRanges = [];
    doctorTimeSlot = null;
    _copyDoctorTimeSlot = null;
    isLoading = true;
    _showButtons = false;
    _forceRebuildKey = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    DoctorsProfile doctorProfile = widget.doctorProfile;
    var brightness = Theme.of(context).brightness;
    var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;

    return ScaffoldWrapper(
      key: Key(doctorProfile.userId),
      title: context.tr('scheduleTimings'),
      children: NotificationListener(
        onNotification: (notification) {
          double per = 0;
          if (scheduleScrollController.hasClients) {
            per = ((scheduleScrollController.offset / scheduleScrollController.position.maxScrollExtent));
          }
          if (per >= 0) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  scrollPercentage = 307 * per;
                });
              }
            });
          }
          return false;
        },
        child: Stack(
          children: [
            ListView.builder(
              shrinkWrap: true,
              key: Key(doctorProfile.userId),
              controller: scheduleScrollController,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (doctorProfile.userProfile.currency.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    height: 200,
                    child: Card(
                      elevation: 12,
                      color: Theme.of(context).canvasColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).primaryColorLight),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: Center(
                        child: Text(context.tr('noHaveCurrency')),
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      if (!isLoading) ...[
                        FadeinWidget(
                          isCenter: true,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SfDateRangePicker(
                                initialSelectedRanges: _initialRanges,
                                key: ValueKey(_forceRebuildKey),
                                controller: dateRangePickerController,
                                selectableDayPredicate: (date) {
                                  return !_isDateInsideRange(date, _initialRanges);
                                },
                                cellBuilder: (BuildContext context, DateRangePickerCellDetails details) {
                                  bool isStartDate = false;
                                  bool isEndDate = false;
                                  bool isInRange = false;
                                  bool isToday = isSameDate(details.date, DateTime.now());

                                  if (dateRangePickerController.selectedRanges != null) {
                                    for (PickerDateRange range in dateRangePickerController.selectedRanges!) {
                                      if (isSameDate(details.date, range.startDate)) {
                                        isStartDate = true;
                                      } else if (isSameDate(details.date, range.endDate)) {
                                        isEndDate = true;
                                      } else if (range.startDate != null &&
                                          range.endDate != null &&
                                          details.date.isAfter(range.startDate!) &&
                                          details.date.isBefore(range.endDate!)) {
                                        isInRange = true;
                                      }
                                    }
                                  }

                                  Color backgroundColor;
                                  BorderRadius borderRadius = BorderRadius.zero;
                                  if (isStartDate) {
                                    backgroundColor = Theme.of(context).primaryColor;
                                    borderRadius = const BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomLeft: Radius.circular(5),
                                    );
                                  } else if (isEndDate) {
                                    backgroundColor = Theme.of(context).primaryColor;
                                    borderRadius = const BorderRadius.only(
                                      topRight: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    );
                                  } else if (isInRange) {
                                    backgroundColor = Theme.of(context).primaryColor.withOpacity(0.2); // Color for range dates
                                  } else {
                                    backgroundColor = Colors.transparent;
                                  }

                                  if (isToday && !isStartDate) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        details.date.day.toString(),
                                        style: TextStyle(
                                          color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: borderRadius,
                                      shape: BoxShape.rectangle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${details.date.day}',
                                      style: TextStyle(
                                        color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  );
                                },
                                onSelectionChanged: _onSelectionChanged,
                                selectionMode: DateRangePickerSelectionMode.multiRange,
                                monthCellStyle: DateRangePickerMonthCellStyle(
                                  blackoutDatesDecoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                    color: Theme.of(context).primaryColor,
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 1,
                                    ),
                                    shape: BoxShape.rectangle,
                                  ),
                                  blackoutDateTextStyle: const TextStyle(color: Colors.white, decoration: TextDecoration.lineThrough),
                                ),
                                view: DateRangePickerView.month,
                                enablePastDates: false,
                                showNavigationArrow: true,
                                showActionButtons: true,
                                confirmText: context.tr('confirm'),
                                cancelText: context.tr("cancel"),
                                selectionShape: DateRangePickerSelectionShape.rectangle,
                                navigationDirection: DateRangePickerNavigationDirection.vertical,
                                monthViewSettings: DateRangePickerMonthViewSettings(blackoutDates: _getBlackoutDatesFromRanges()),
                                onCancel: _onCancel,
                              ),
                            ),
                          ),
                        ),
                        // Carousel Widget
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CarouselSlider(
                                options: CarouselOptions(
                                  autoPlay: false,
                                  enlargeCenterPage: true,
                                  height: 350,
                                  enableInfiniteScroll: false,
                                ),
                                items: [
                                  if (_copyDoctorTimeSlot != null && _copyDoctorTimeSlot!.availableSlots.isNotEmpty) ...[
                                    ...(_copyDoctorTimeSlot!.availableSlots
                                          ..sort((a, b) => a.startDate.compareTo(b.startDate))) // Sort in place first
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final times = entry.value;
                                      bool isNoHaveReserve = times.morning.every((a) => !a.isReserved) &&
                                          times.afternoon.every((a) => !a.isReserved) &&
                                          times.evening.every((a) => !a.isReserved);
                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        height: 300,
                                        child: Card(
                                          elevation: 12,
                                          color: Theme.of(context).dialogBackgroundColor,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(color: Theme.of(context).primaryColorLight, width: 1.0),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: SingleChildScrollView(
                                            child: FadeinWidget(
                                              isCenter: true,
                                              child: Column(
                                                children: [
                                                  //From to widget
                                                  IntrinsicHeight(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: [
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      "${context.tr("from")}: ${DateFormat("dd MMM yyyy").format(times.startDate.toLocal())}",
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const Text("-"),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      "${context.tr("to")}: ${DateFormat("dd MMM yyyy").format(times.finishDate.toLocal())}",
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // TimeSelect dropdown
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                                                    child: SizedBox(
                                                      height: 36,
                                                      child: DropdownButtonFormField<String>(
                                                        iconDisabledColor: Theme.of(context).disabledColor,
                                                        iconEnabledColor: Theme.of(context).primaryColor,
                                                        value: times.timeSlot.toString(),
                                                        onChanged: !times.isNew
                                                            ? null
                                                            : (value) {
                                                                if (value != null) {
                                                                  final int newTimeSlot = int.tryParse(value) ?? times.timeSlot;

                                                                  List<TimeType> newMorning = times.morning;
                                                                  List<TimeType> newAfternoon = times.afternoon;
                                                                  List<TimeType> newEvening = times.evening;

                                                                  if (times.morning.isNotEmpty) {
                                                                    newMorning = TimeType.generateTimeSlots(
                                                                      startHour: 9,
                                                                      totalHours: morningMinutes,
                                                                      slotDuration: newTimeSlot,
                                                                      userProfile: doctorProfile.userProfile,
                                                                    );
                                                                  }

                                                                  if (times.afternoon.isNotEmpty) {
                                                                    newAfternoon = TimeType.generateTimeSlots(
                                                                      startHour: 13,
                                                                      totalHours: afterNoonMinutes,
                                                                      slotDuration: newTimeSlot,
                                                                      userProfile: doctorProfile.userProfile,
                                                                    );
                                                                  }

                                                                  if (times.evening.isNotEmpty) {
                                                                    newEvening = TimeType.generateTimeSlots(
                                                                      startHour: 17,
                                                                      totalHours: eveningMinutes,
                                                                      slotDuration: newTimeSlot,
                                                                      userProfile: doctorProfile.userProfile,
                                                                    );
                                                                  }

                                                                  final updated = times.copyWith(
                                                                      timeSlot: newTimeSlot,
                                                                      morning: newMorning,
                                                                      afternoon: newAfternoon,
                                                                      evening: newEvening,
                                                                      index: index);

                                                                  if (index != -1) {
                                                                    setState(() {
                                                                      doctorAvailableTimes[index] = updated;
                                                                      _copyDoctorTimeSlot?.availableSlots[index] = updated;
                                                                    });
                                                                  }
                                                                }
                                                              }, // Disable dropdown
                                                        decoration: InputDecoration(
                                                          labelText: context.tr("timeSlotDuration"),
                                                          border: const OutlineInputBorder(),
                                                          isDense: true,
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                                          ),
                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                        ),
                                                        iconSize: 20,

                                                        items: const [
                                                          DropdownMenuItem(value: '15', child: Text('15 Minutes', style: TextStyle(fontSize: 10))),
                                                          DropdownMenuItem(value: '30', child: Text('30 Minutes', style: TextStyle(fontSize: 10))),
                                                          DropdownMenuItem(value: '45', child: Text('45 Minutes', style: TextStyle(fontSize: 10))),
                                                          DropdownMenuItem(value: '60', child: Text('60 Minutes', style: TextStyle(fontSize: 10))),
                                                        ],
                                                        selectedItemBuilder: (BuildContext context) {
                                                          return [
                                                            '15',
                                                            '30',
                                                            '45',
                                                            '60',
                                                          ].map((value) {
                                                            return Text(
                                                              "$value ${context.tr("minutes")}",
                                                              style: TextStyle(
                                                                color: times.isNew ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                                                fontSize: 14,
                                                              ),
                                                            );
                                                          }).toList();
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  //
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        //Moring
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Checkbox(
                                                              value: times.morning.isNotEmpty,
                                                              onChanged: !times.isNew
                                                                  ? null
                                                                  : (value) {
                                                                      if (value == true) {
                                                                        final slots = TimeType.generateTimeSlots(
                                                                          startHour: 9,
                                                                          totalHours: morningMinutes,
                                                                          slotDuration: times.timeSlot,
                                                                          userProfile: doctorProfile.userProfile,
                                                                        );
                                                                        setState(() {
                                                                          times.morning.addAll(slots);
                                                                        });
                                                                      } else {
                                                                        // Remove slots
                                                                        setState(() {
                                                                          times.morning.clear();
                                                                        });
                                                                      }
                                                                    },
                                                              visualDensity: VisualDensity.compact, // Makes checkbox smaller
                                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            GestureDetector(
                                                              // Or use InkWell for visual feedback
                                                              onTap: !times.isNew
                                                                  ? null
                                                                  : () {
                                                                      // Programmatically toggle the checkbox value
                                                                      if (times.morning.isEmpty) {
                                                                        // Simulate checking the box
                                                                        final slots = TimeType.generateTimeSlots(
                                                                          startHour: 9,
                                                                          totalHours: morningMinutes,
                                                                          slotDuration: times.timeSlot,
                                                                          userProfile: doctorProfile.userProfile,
                                                                        );
                                                                        setState(() {
                                                                          times.morning.addAll(slots);
                                                                        });
                                                                      } else {
                                                                        // Simulate unchecking the box
                                                                        setState(() {
                                                                          times.morning.clear();
                                                                        });
                                                                      }
                                                                    },
                                                              child: Text(
                                                                context.tr("morning"),
                                                                style: const TextStyle(fontSize: 14),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              "${DateFormat('HH:mm').format(morningStart)} to ${DateFormat('HH:mm').format(morningFinish)}",
                                                              style: const TextStyle(fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        //Afternoon
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Checkbox(
                                                              value: times.afternoon.isNotEmpty,
                                                              onChanged: !times.isNew
                                                                  ? null
                                                                  : (value) {
                                                                      if (value == true) {
                                                                        // Add slot
                                                                        final slots = TimeType.generateTimeSlots(
                                                                          startHour: 13,
                                                                          totalHours: afterNoonMinutes,
                                                                          slotDuration: times.timeSlot,
                                                                          userProfile: doctorProfile.userProfile,
                                                                        );
                                                                        setState(() {
                                                                          times.afternoon.addAll(slots);
                                                                        });
                                                                      } else {
                                                                        // Remove slots
                                                                        setState(() {
                                                                          times.afternoon.clear();
                                                                        });
                                                                      }
                                                                    },
                                                              visualDensity: VisualDensity.compact, // Makes checkbox smaller
                                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            GestureDetector(
                                                              // Or use InkWell for visual feedback
                                                              onTap: !times.isNew
                                                                  ? null
                                                                  : () {
                                                                      // Programmatically toggle the checkbox value
                                                                      if (times.afternoon.isEmpty) {
                                                                        // Simulate checking the box
                                                                        final slots = TimeType.generateTimeSlots(
                                                                          startHour: 13,
                                                                          totalHours: afterNoonMinutes,
                                                                          slotDuration: times.timeSlot,
                                                                          userProfile: doctorProfile.userProfile,
                                                                        );
                                                                        setState(() {
                                                                          times.afternoon.addAll(slots);
                                                                        });
                                                                      } else {
                                                                        // Simulate unchecking the box
                                                                        setState(() {
                                                                          times.afternoon.clear();
                                                                        });
                                                                      }
                                                                    },
                                                              child: Text(
                                                                context.tr("afternoon"),
                                                                style: const TextStyle(fontSize: 14),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              "${DateFormat('HH:mm').format(afterNoonStart)} to ${DateFormat('HH:mm').format(afterNoonFinish)}",
                                                              style: const TextStyle(fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        // Evening
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Checkbox(
                                                              value: times.evening.isNotEmpty,
                                                              onChanged: !times.isNew
                                                                  ? null
                                                                  : (value) {
                                                                      if (value == true) {
                                                                        // Add slot
                                                                        final slots = TimeType.generateTimeSlots(
                                                                          startHour: 17,
                                                                          totalHours: eveningMinutes,
                                                                          slotDuration: times.timeSlot,
                                                                          userProfile: doctorProfile.userProfile,
                                                                        );
                                                                        setState(() {
                                                                          times.evening.addAll(slots);
                                                                        });
                                                                      } else {
                                                                        // Remove slots
                                                                        setState(() {
                                                                          times.evening.clear();
                                                                        });
                                                                      }
                                                                    },
                                                              visualDensity: VisualDensity.compact, // Makes checkbox smaller
                                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            GestureDetector(
                                                              // Or use InkWell for visual feedback
                                                              onTap: !times.isNew
                                                                  ? null
                                                                  : () {
                                                                      // Programmatically toggle the checkbox value
                                                                      if (times.evening.isEmpty) {
                                                                        // Simulate checking the box
                                                                        final slots = TimeType.generateTimeSlots(
                                                                          startHour: 17,
                                                                          totalHours: eveningMinutes,
                                                                          slotDuration: times.timeSlot,
                                                                          userProfile: doctorProfile.userProfile,
                                                                        );
                                                                        setState(() {
                                                                          times.evening.addAll(slots);
                                                                        });
                                                                      } else {
                                                                        // Simulate unchecking the box
                                                                        setState(() {
                                                                          times.evening.clear();
                                                                        });
                                                                      }
                                                                    },
                                                              child: Text(
                                                                context.tr("evening"),
                                                                style: const TextStyle(fontSize: 14),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              "${DateFormat('HH:mm').format(eveningStart)} to ${DateFormat('HH:mm').format(eveningFinish)}",
                                                              style: const TextStyle(fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 16.0),
                                                          child: Column(
                                                            children: [
                                                              // Minus Circle
                                                              GestureDetector(
                                                                onTap: () async {
                                                                  if (isNoHaveReserve) {
                                                                    await showCustomInfoDialog(
                                                                      context: context,
                                                                      title: context.tr("delete"),
                                                                      description: context.tr("deleteTimeSlotDescription"),
                                                                      closeText: context.tr("cancel"),
                                                                      confirmText: context.tr("confirm"),
                                                                      onConfirm: () {
                                                                        Navigator.pop(context);
                                                                        DateTime targetStartDate = times.startDate.toLocal();
                                                                        DateTime targetEndDate = times.finishDate.toLocal();
                                                                        _initialRanges.removeWhere((range) =>
                                                                            range.startDate == targetStartDate && range.endDate == targetEndDate);
                                                                        doctorAvailableTimes.removeAt(index);
                                                                        _isProgrammaticUpdate = true;
                                                                        _copyDoctorTimeSlot?.availableSlots.removeWhere((avail) =>
                                                                            avail.startDate.isAtSameMomentAs(targetStartDate) &&
                                                                            avail.finishDate.isAtSameMomentAs(targetEndDate));
                                                                        setState(() {
                                                                          _initialRanges = _initialRanges;
                                                                          dateRangePickerController.selectedRanges = [..._initialRanges];
                                                                          _forceRebuildKey = DateTime.now().millisecondsSinceEpoch;
                                                                          doctorAvailableTimes = doctorAvailableTimes;
                                                                          _copyDoctorTimeSlot = _copyDoctorTimeSlot!.copyWith();
                                                                        });
                                                                        Future.delayed(const Duration(milliseconds: 100), () {
                                                                          _isProgrammaticUpdate = false;
                                                                        });
                                                                      },
                                                                    );
                                                                  } else {
                                                                    showErrorSnackBar(context, context.tr("cantDeleteScheduleError"));
                                                                  }
                                                                }, // Your function
                                                                child: Row(
                                                                  children: [
                                                                    FaIcon(
                                                                      FontAwesomeIcons.minusCircle,
                                                                      color: Theme.of(context).primaryColorLight, // like crimson
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(width: 11),
                                                                    Text(
                                                                      context.tr("removeSlot"),
                                                                      style: TextStyle(
                                                                        color: Theme.of(context).primaryColorLight,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              // Add edit Timeslot
                                                              GestureDetector(
                                                                onTap: () => {
                                                                  if (times.morning.isEmpty && times.afternoon.isEmpty && times.evening.isEmpty)
                                                                    {showErrorSnackBar(context, context.tr("atLeast1Period"))}
                                                                  else
                                                                    {_openTimeSlotBottomSheet(times)}
                                                                }, // Your function
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(top: 12.0),
                                                                  child: Row(
                                                                    children: [
                                                                      FaIcon(
                                                                        times.isNew ? FontAwesomeIcons.plusCircle : FontAwesomeIcons.edit,
                                                                        color: Theme.of(context).primaryColor,
                                                                        size: times.isNew ? 20 : 17,
                                                                      ),
                                                                      const SizedBox(width: 11),
                                                                      Text(
                                                                        times.isNew ? context.tr("addSlot") : context.tr("editSlot"),
                                                                        style: TextStyle(
                                                                          color: Theme.of(context).primaryColor,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              //View slot
                                                              GestureDetector(
                                                                onTap: () => {
                                                                  if (times.morning.isEmpty && times.afternoon.isEmpty && times.evening.isEmpty)
                                                                    {showErrorSnackBar(context, context.tr("atLeast1Period"))}
                                                                  else
                                                                    showModalBottomSheet(
                                                                      isDismissible: true,
                                                                      enableDrag: true,
                                                                      showDragHandle: true,
                                                                      useSafeArea: true,
                                                                      isScrollControlled: true,
                                                                      context: context,
                                                                      builder: (context) => TimeSlotBottomSheet(
                                                                        initialTimes: times,
                                                                        viewType: "view",
                                                                      ),
                                                                    )
                                                                }, // Your function
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(top: 12.0),
                                                                  child: Row(
                                                                    children: [
                                                                      FaIcon(
                                                                        FontAwesomeIcons.eye,
                                                                        color: Theme.of(context).primaryColorLight,
                                                                        size: times.isNew ? 20 : 17,
                                                                      ),
                                                                      const SizedBox(width: 11),
                                                                      Text(
                                                                        context.tr("viewSlot"),
                                                                        style: TextStyle(
                                                                          color: Theme.of(context).primaryColorLight,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
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
                                        ),
                                      );
                                    }),
                                  ]
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (_copyDoctorTimeSlot != null) ...[
                          if (_copyDoctorTimeSlot!.id == null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 26),
                              child: ElevatedButton(
                                onPressed: _showButtons
                                    ? () {
                                        saveTodb();
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(MediaQuery.of(context).size.width, 40),
                                  elevation: 5.0,
                                  foregroundColor: Colors.black,
                                  animationDuration: const Duration(milliseconds: 1000),
                                  backgroundColor: Theme.of(context).primaryColorLight,
                                  shadowColor: Theme.of(context).primaryColorLight,
                                ),
                                // style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                child: Text(
                                  context.tr("save"),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 26),
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: _showButtons
                                        ? () {
                                            updateDb();
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(MediaQuery.of(context).size.width, 40),
                                      elevation: 5.0,
                                      foregroundColor: Colors.black,
                                      animationDuration: const Duration(milliseconds: 1000),
                                      backgroundColor: Theme.of(context).primaryColor,
                                      shadowColor: Theme.of(context).primaryColor,
                                    ),
                                    // style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                    child: Text(
                                      context.tr("update"),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _showButtons
                                        ? () async {
                                            await showCustomInfoDialog(
                                              context: context,
                                              title: context.tr("delete"),
                                              description: context.tr("deleteTimeSlotDescription"),
                                              closeText: context.tr("cancel"),
                                              confirmText: context.tr("confirm"),
                                              onConfirm: () {
                                                Navigator.pop(context);
                                                deleteDb();
                                              },
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(MediaQuery.of(context).size.width, 40),
                                      elevation: 5.0,
                                      foregroundColor: Colors.black,
                                      animationDuration: const Duration(milliseconds: 1000),
                                      backgroundColor: homeThemeName == "joker" ? Theme.of(context).primaryColorLight : Colors.pinkAccent.shade400,
                                      shadowColor: homeThemeName == "joker" ? Theme.of(context).primaryColorLight :Colors.pinkAccent.shade400,
                                    ),
                                    // style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                    child: Text(
                                      context.tr("delete"),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        ]
                      ] else ...[
                        //Loading
                        Padding(
                          padding: const EdgeInsets.only(top: 140.0),
                          child: SizedBox(
                            height: 150,
                            width: 150,
                            child: LoadingIndicator(
                                indicatorType: Indicator.ballRotateChase,
                                colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
                                strokeWidth: 2.0,
                                pathBackgroundColor: null),
                          ),
                        ),
                      ]
                    ],
                  );
                }
              },
              itemCount: 1,
            ),
            ScrollButton(scrollController: scheduleScrollController, scrollPercentage: scrollPercentage)
          ],
        ),
      ),
    );
  }

  bool isSameDate(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  bool _rangesOverlap(PickerDateRange range1, PickerDateRange range2) {
    final start1 = range1.startDate!;
    final end1 = range1.endDate!;
    final start2 = range2.startDate!;
    final end2 = range2.endDate!;
    return start1.isBefore(end2) && start2.isBefore(end1);
  }

// Helper method to convert _initialRanges into blackoutDates
  List<DateTime> _getBlackoutDatesFromRanges() {
    List<DateTime> blackoutDates = [];

    for (var range in _initialRanges) {
      if (range.startDate != null && range.endDate != null) {
        DateTime startDate = range.startDate!;
        DateTime endDate = range.endDate!;

        // Add the start and end date as blackout dates
        blackoutDates.add(startDate);
        blackoutDates.add(endDate);

        // Add all dates in between to blackoutDates
        for (DateTime date = startDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
          blackoutDates.add(date);
        }
      }
    }
    return blackoutDates;
  }

  bool _isDateInsideRange(DateTime date, List<PickerDateRange> ranges) {
    for (var range in ranges) {
      // Check if date is within the current range (inclusive)
      if ((date.isAfter(range.startDate!) || date.isAtSameMomentAs(range.startDate!)) &&
          (date.isBefore(range.endDate!) || date.isAtSameMomentAs(range.endDate!))) {
        return true;
      }
    }
    return false;
  }
}

class TimeSlotBottomSheet extends StatefulWidget {
  final AvailableType initialTimes;
  final String viewType;

  const TimeSlotBottomSheet({
    super.key,
    required this.initialTimes,
    required this.viewType,
  });

  @override
  State<TimeSlotBottomSheet> createState() => _TimeSlotBottomSheetState();
}

class _TimeSlotBottomSheetState extends State<TimeSlotBottomSheet> {
  late AvailableType _editedTimes;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showValidation = true;
  String? _globalError;
  @override
  void initState() {
    super.initState();
    _editedTimes = widget.initialTimes.copyWith();
  }

  void _submit() {
    final formIsValid = _formKey.currentState?.validate() ?? false;

    final isAnyPeriodActive =
        _editedTimes.morning.any((e) => e.active) || _editedTimes.afternoon.any((e) => e.active) || _editedTimes.evening.any((e) => e.active);

    if (!isAnyPeriodActive) {
      setState(() {
        _globalError = context.tr('needActiveAtLeastOne');
      });
      return;
    }

    if (isAnyPeriodActive) {
      removeGlobalError();
    }

    if (formIsValid) {
      Navigator.pop(context, _editedTimes); // return updated list
    }
  }

  void removeGlobalError() {
    setState(() {
      _globalError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GradientText(
                        "${context.tr("from")}: ${DateFormat("dd MMM yyyy").format(_editedTimes.startDate.toLocal())}  ${context.tr("to")}: ${DateFormat("dd MMM yyyy").format(_editedTimes.finishDate.toLocal())}",
                        style: GoogleFonts.robotoCondensed(fontSize: 20),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColorLight,
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  if (widget.viewType == "edit") ...[
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: FadeinWidget(
                        isCenter: true,
                        child: Column(
                          children: [
                            SelectCheckBox(
                                period: "morning",
                                removeGlobalError: removeGlobalError,
                                periodArray: _editedTimes.morning,
                                updateFunction: (index, time) {
                                  setState(() {
                                    // Clone the current morning list
                                    final updatedMorning = List<TimeType>.from(_editedTimes.morning);

                                    // Replace the item at the specified index
                                    updatedMorning[index] = time;
                                    // Create a new AvailableType with the updated list
                                    _editedTimes = _editedTimes.copyWith(morning: updatedMorning);
                                  });
                                },
                                replaceFunction: (times) {
                                  setState(() {
                                    _editedTimes = _editedTimes.copyWith(
                                      morning: List<TimeType>.from(times),
                                    );
                                  });
                                }),
                            SelectCheckBox(
                              period: "afternoon",
                              removeGlobalError: removeGlobalError,
                              periodArray: _editedTimes.afternoon,
                              updateFunction: (index, time) {
                                setState(() {
                                  // Clone the current morning list
                                  final updatedAfternoon = List<TimeType>.from(_editedTimes.afternoon);

                                  // Replace the item at the specified index
                                  updatedAfternoon[index] = time;

                                  // Create a new AvailableType with the updated list
                                  _editedTimes = _editedTimes.copyWith(afternoon: updatedAfternoon);
                                });
                              },
                              replaceFunction: (times) {
                                setState(() {
                                  _editedTimes = _editedTimes.copyWith(
                                    afternoon: List<TimeType>.from(times),
                                  );
                                });
                              },
                            ),
                            SelectCheckBox(
                              period: "evening",
                              removeGlobalError: removeGlobalError,
                              periodArray: _editedTimes.evening,
                              updateFunction: (index, time) {
                                setState(() {
                                  // Clone the current morning list
                                  final updatedEvening = List<TimeType>.from(_editedTimes.evening);

                                  // Replace the item at the specified index
                                  updatedEvening[index] = time;

                                  // Create a new AvailableType with the updated list
                                  _editedTimes = _editedTimes.copyWith(evening: updatedEvening);
                                });
                              },
                              replaceFunction: (times) {
                                setState(() {
                                  _editedTimes = _editedTimes.copyWith(
                                    evening: List<TimeType>.from(times),
                                  );
                                });
                              },
                            ),
                            if (_globalError != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  _globalError!,
                                  style: TextStyle(color: Colors.pinkAccent.shade400),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(MediaQuery.of(context).size.width, 40),
                                  elevation: 5.0,
                                  foregroundColor: Colors.black,
                                  animationDuration: const Duration(milliseconds: 1000),
                                  backgroundColor: Theme.of(context).primaryColorLight,
                                  shadowColor: Theme.of(context).primaryColorLight,
                                ),
                                child: Text(context.tr("submit")),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ] else ...[
                    ViewTimeSlots(
                      periodArray: _editedTimes.morning,
                      period: "morning",
                    ),
                    ViewTimeSlots(
                      periodArray: _editedTimes.afternoon,
                      period: "afternoon",
                    ),
                    ViewTimeSlots(
                      periodArray: _editedTimes.evening,
                      period: "evening",
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectCheckBox extends StatefulWidget {
  final String period;
  final List<TimeType> periodArray;
  final Function(int index, TimeType time) updateFunction;
  final Function(List<TimeType> times) replaceFunction;
  final VoidCallback? removeGlobalError;
  const SelectCheckBox({
    super.key,
    required this.period,
    required this.periodArray,
    required this.updateFunction,
    required this.replaceFunction,
    this.removeGlobalError,
  });

  @override
  State<SelectCheckBox> createState() => _SelectCheckBoxState();
}

class _SelectCheckBoxState extends State<SelectCheckBox> {
  final TextEditingController sharedPriceController = TextEditingController();
  final List<TextEditingController> _controllers = [];
  final List<VoidCallback> _controllerListeners = [];
  final List<FocusNode> _focusNodes = [];

  bool get allSelected => widget.periodArray.every((e) => e.active);

  void selectAllToggle() {
    final updatedList = widget.periodArray.map((time) => time.copyWith(active: !allSelected)).toList();

    setState(() {
      widget.replaceFunction(updatedList);
    });
  }

  void updatePriceForAll(double value) {
    final updatedList = widget.periodArray.map((time) => time.copyWith(price: value)).toList();
    setState(() {
      widget.replaceFunction(updatedList);
    });
  }

  @override
  void initState() {
    super.initState();
    _initControllers();
    final uniquePrices = widget.periodArray.map((e) => e.price).toSet();
    if (uniquePrices.length == 1 && widget.periodArray.first.price > 0) {
      sharedPriceController.text = toCurrencyString(
        widget.periodArray.first.price.toStringAsFixed(0),
        thousandSeparator: ThousandSeparator.Comma,
        mantissaLength: 0,
        trailingSymbol: '',
      );
    }
  }

  @override
  void didUpdateWidget(covariant SelectCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.periodArray != widget.periodArray) {
      _initControllers(); // Refresh controllers if data changes
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _initControllers() {
    // If controllers already exist, update their text safely
    if (_controllers.length == widget.periodArray.length) {
      for (int i = 0; i < widget.periodArray.length; i++) {
        final price = widget.periodArray[i].price;
        final formatted = price > 0
            ? toCurrencyString(
                price.toString(),
                thousandSeparator: ThousandSeparator.Comma,
                mantissaLength: 0,
                trailingSymbol: '',
              )
            : '';

        if (_controllers[i].text != formatted) {
          // Update text without breaking focus
          final controller = _controllers[i];
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            controller.value = controller.value.copyWith(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          });
        }
      }
      return;
    }

    // Dispose old controllers and remove listeners properly
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].removeListener(_controllerListeners[i]);
      _controllers[i].dispose();
    }

    _controllers.clear();
    _controllerListeners.clear();
// Create new controllers and listeners
    for (int i = 0; i < widget.periodArray.length; i++) {
      final price = widget.periodArray[i].price;
      final controller = TextEditingController(
        text: price > 0
            ? toCurrencyString(
                price.toString(),
                thousandSeparator: ThousandSeparator.Comma,
                mantissaLength: 0,
                trailingSymbol: '',
              )
            : '',
      );

      void listener() {
        if (!mounted) return;
        final text = controller.text;
        final parsed = double.tryParse(text.replaceAll(',', '')) ?? 0;
        //Schedule it after the current build complete
        Future.delayed(Duration.zero, () {
          if (mounted) {
            widget.updateFunction(i, widget.periodArray[i].copyWith(price: parsed));
          }
        });
      }

      controller.addListener(listener);

      _controllers.add(controller);
      _controllerListeners.add(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    final capitalPeriod = widget.period[0].toUpperCase() + widget.period.substring(1);
    final itemCount = widget.periodArray.length;
    var brightness = Theme.of(context).brightness;

    return widget.periodArray.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        context.tr(capitalPeriod),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: allSelected,
                      onChanged: (value) {
                        if (value == true) {
                          widget.removeGlobalError!();
                        }
                        selectAllToggle();
                      },
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      style: TextStyle(
                        color: brightness == Brightness.dark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                      allSelected ? context.tr("deselectAll", args: [capitalPeriod]) : context.tr("selectAll", args: [capitalPeriod]),
                    ),
                  ],
                ),
              ),
              if (allSelected)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                  child: TextFormField(
                    controller: sharedPriceController,
                    inputFormatters: [
                      CurrencyInputFormatter(
                        thousandSeparator: ThousandSeparator.Comma,
                        mantissaLength: 0,
                        trailingSymbol: '',
                      ),
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      labelText: context.tr("priceForAll"),
                      hintText: context.tr('enterPrice'),
                      suffixText: widget.periodArray.first.currencySymbol,
                      suffixStyle: TextStyle(color: Theme.of(context).primaryColorLight),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value.replaceAll(',', ''));
                      if (parsed != null) updatePriceForAll(parsed);
                    },
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Wrap(
                  spacing: 12, // Horizontal spacing
                  runSpacing: 12, // Vertical spacing
                  children: widget.periodArray.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    // Check if it's the last item and it's a single one in the last row
                    final isLastSingle = itemCount % 2 != 0 && i == itemCount - 1;
                    final screenWidth = MediaQuery.of(context).size.width;
                    final itemWidth = isLastSingle
                        ? screenWidth - 20 // Full width with padding
                        : (screenWidth - 34) / 2; // Two items per row: 10 padding left + 10 right + 12 spacing

                    return SizedBox(
                      width: itemWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: item.active,
                                  onChanged: (value) {
                                    if (value == true) {
                                      widget.removeGlobalError!();
                                    }
                                    setState(() {
                                      widget.updateFunction(i, item.copyWith(active: !item.active));
                                    });
                                  },
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                Expanded(
                                  child: Text(
                                    item.period,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item.active) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextFormField(
                                key: ValueKey(item.period),
                                controller: _controllers[i],
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 13),
                                inputFormatters: [
                                  CurrencyInputFormatter(
                                    thousandSeparator: ThousandSeparator.Comma,
                                    mantissaLength: 0,
                                    trailingSymbol: '',
                                  ),
                                ],
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                  isDense: true,
                                  labelText: context.tr("price"),
                                  labelStyle: const TextStyle(fontSize: 13),
                                  hintText: context.tr("price"),
                                  hintStyle: const TextStyle(fontSize: 13),
                                  suffixText: widget.periodArray.first.currencySymbol,
                                  suffixStyle: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontSize: 13,
                                  ),
                                  border: const OutlineInputBorder(),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.pinkAccent.shade400,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColorLight,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  final parsed = double.tryParse(value?.replaceAll(",", "") ?? "");
                                  if (parsed == null || parsed == 0) {
                                    return context.tr("required");
                                  }
                                  return null;
                                },
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                            ),
                          ]
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}

class ViewTimeSlots extends StatefulWidget {
  final List<TimeType> periodArray;
  final String period;
  const ViewTimeSlots({
    super.key,
    required this.periodArray,
    required this.period,
  });

  @override
  State<ViewTimeSlots> createState() => _ViewTimeSlotsState();
}

class _ViewTimeSlotsState extends State<ViewTimeSlots> {
  @override
  Widget build(BuildContext context) {
    final capitalPeriod = widget.period[0].toUpperCase() + widget.period.substring(1);
    var brightness = Theme.of(context).brightness;
    return widget.periodArray.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        context.tr(capitalPeriod),
                        style: TextStyle(color: brightness == Brightness.dark ? Colors.white : Colors.black, fontSize: 16),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: widget.periodArray.asMap().entries.map((entry) {
                        // final i = entry.key;
                        final item = entry.value;
                        final priceFormatter = NumberFormat('#,##0.00');
                        if (item.active) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Card(
                                elevation: 12,
                                color: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Theme.of(context).primaryColorLight),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: SizedBox(
                                  height: 100, // or MediaQuery.of(context).size.height * 0.5
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(color: Theme.of(context).primaryColorLight),
                                                    bottom: BorderSide(color: Theme.of(context).primaryColorLight),
                                                  ),
                                                ),
                                                child: Row(children: [Text(context.tr("time")), const Text(": "), Text(item.period)]),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(color: Theme.of(context).primaryColorLight),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(context.tr("price")),
                                                      const Text(": "),
                                                      Text("${priceFormatter.format(item.price)} ${item.currencySymbol}")
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(color: Theme.of(context).primaryColorLight),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(context.tr("bookingsFee")),
                                                    const Text(": "),
                                                    Text("${priceFormatter.format(item.bookingsFeePrice)} ${item.currencySymbol}"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    Text(context.tr("totalPrice")),
                                                    const Text(": "),
                                                    Text("${priceFormatter.format(item.total)} ${item.currencySymbol}")
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        }

                        return const SizedBox.shrink(); // Return empty widget if inactive
                      }).toList(),
                    ),
                  ),
                ],
              )
            ],
          )
        : const SizedBox();
  }
}
