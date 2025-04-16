

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/doctors_time_slot.dart';

class TimeScheduleProvider extends ChangeNotifier {
  DoctorsTimeSlot? _doctorsTimeSlot;
  bool _isLoading = true;
  DoctorsTimeSlot? get doctorsTimeSlot => _doctorsTimeSlot;
  bool get isLoading => _isLoading;
  void setDoctorsTimeSlot(DoctorsTimeSlot? timeSlot) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay setting the actual value to next frame
      WidgetsBinding.instance.addPostFrameCallback((__) {
        _doctorsTimeSlot = timeSlot;
        _isLoading = false;
        notifyListeners();
      });
        notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
    _isLoading = true;
    notifyListeners();

    _doctorsTimeSlot = timeSlot;
    _isLoading = false;
    notifyListeners();
    }
  }

  void setLoading(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading = value;
      notifyListeners();
    });
  }
}
