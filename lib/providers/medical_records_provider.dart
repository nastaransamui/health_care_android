import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/medical_records.dart';

class MedicalRecordsProvider extends ChangeNotifier {
  List<MedicalRecords> _medicalRecords = [];
  bool _isLoading = true;
  int _total = 0;
  List<MedicalRecords> get medicalRecords => _medicalRecords;
  bool get isLoading => _isLoading;
  int get total => _total;

  void setMedicalRecords(List<MedicalRecords> medicalRecords, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _medicalRecords = medicalRecords;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = true;
      if (notify) notifyListeners();

      _medicalRecords = medicalRecords;
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
