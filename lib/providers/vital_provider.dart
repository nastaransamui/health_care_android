
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/vital_signs.dart';

class VitalProvider extends ChangeNotifier {
  VitalSigns? _vitalSigns;
  bool _isLoading = true;
  int _total = 0;
  List<VitalSignValues> _vitalSignValues = [];

  VitalSigns? get vitalSign => _vitalSigns;
  bool get isLoading => _isLoading;
  int get total => _total;
  List<VitalSignValues> get vitalSignValues => _vitalSignValues;

  void setVitalSigns(List<dynamic> data) {
    if (data.isNotEmpty) {
      final signsFromAdmin = VitalSigns.fromMap(data[0]);
      _vitalSigns = signsFromAdmin;
    } else {
      _vitalSigns = null;
    }

    notifyListeners();
  }

  void setVitalSignValues(List<VitalSignValues> vitalSignValues, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _vitalSignValues = vitalSignValues;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      _isLoading = false;
      if (notify) notifyListeners();

      _vitalSignValues = vitalSignValues;
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
