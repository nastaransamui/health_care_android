import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/patient_appointment_reservation.dart';

class PatientAppointmentProvider extends ChangeNotifier {
  List<PatientAppointmentReservation> _patientAppointmentReservations = [];
  bool _isLoading = true;
  int _total = 0;
  List<PatientAppointmentReservation> get patientAppointmentReservations => _patientAppointmentReservations;
  bool get isLoading => _isLoading;
  int get total => _total;

  void setPatientAppointmentReservations(List<PatientAppointmentReservation> reservations, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _patientAppointmentReservations = reservations;
          // _isLoading = false;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = false;
      if (notify) notifyListeners();

      _patientAppointmentReservations = reservations;
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

  void setTotal(int value, {bool notify = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _total = value;
      if (notify) notifyListeners();
    });
  }
}
