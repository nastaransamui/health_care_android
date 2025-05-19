import 'package:health_care/src/features/doctors/schedule/select_check_box.dart';
import 'package:health_care/src/features/doctors/schedule/view_time_slots.dart';
import 'package:health_care/src/utils/gradient_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
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

