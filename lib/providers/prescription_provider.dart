import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/prescriptions.dart';

class PrescriptionProvider extends ChangeNotifier {
  List<Prescriptions> _prescriptions = [];
  bool _isLoading = true;
  int _total = 0;
  List<Prescriptions> get prescriptions => _prescriptions;
  bool get isLoading => _isLoading;
  int get total => _total;

  void setPrescriptions(List<Prescriptions> prescriptions, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _prescriptions = prescriptions;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = true;
      if (notify) notifyListeners();

      _prescriptions = prescriptions;
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
  if (notify) {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      _total = value;
      notifyListeners();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) {
          _total = value;
          notifyListeners();
        }
      });
    }
  } else {
    _total = value;
  }
}
}
