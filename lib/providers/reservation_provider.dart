import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/reservation.dart';

class ReservationProvider extends ChangeNotifier {
  late Reservation _reservation;
  bool _isLoading = true;
  Reservation? get reservation => _isLoading ? null : _reservation;
  bool get isLoading => _isLoading;

  void setReservation(Reservation reservation, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _reservation = reservation;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = false;
      if (notify) notifyListeners();

      _reservation = reservation;
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
