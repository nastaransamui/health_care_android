import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/booking_information.dart';

class BookingInformationProvider extends ChangeNotifier {
  late BookingInformation _bookingInformation;
  late OccupyTime _occupyTime;
  bool _isLoading = true;
  BookingInformation? get bookingInformation =>
    _isLoading ? null : _bookingInformation;
  OccupyTime? get occupyTime => _isLoading ? null : _occupyTime;
  bool get isLoading => _isLoading;

  void setBookingInformation(BookingInformation bookingInformation, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _bookingInformation = bookingInformation;
          // _isLoading = false;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = false;
      if (notify) notifyListeners();

      _bookingInformation = bookingInformation;
      // _isLoading = false;
      if (notify) notifyListeners();
    }
  }

    void setOccypyTime(OccupyTime occupyTime,{bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _occupyTime = occupyTime;
          // _isLoading = false;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = false;
      if (notify) notifyListeners();

      _occupyTime = occupyTime;
      // _isLoading = false;
      if (notify) notifyListeners();
    }
  }

  void setLoading(bool value, {bool notify = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading = value;
      if (notify) notifyListeners();
    });
  }
}
