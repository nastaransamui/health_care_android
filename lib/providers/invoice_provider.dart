import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/appointment_reservation.dart';

class InvoiceProvider extends ChangeNotifier {
  List<AppointmentReservation> _appointmentReservations = [];
  bool _isLoading = true;
  int _total = 0;
  List<AppointmentReservation> get appointmentReservations => _appointmentReservations;
  bool get isLoading => _isLoading;
  int get total => _total;
  void setAppointmentReservations(List<AppointmentReservation> reservations) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _appointmentReservations = reservations;
          // _isLoading = false;
          notifyListeners();
        });
        notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = true;
      notifyListeners();

      _appointmentReservations = reservations;
      // _isLoading = false;
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading = value;
      notifyListeners();
    });
  }

  void setTotal(int value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _total = value;
      notifyListeners();
    });
  }
}
