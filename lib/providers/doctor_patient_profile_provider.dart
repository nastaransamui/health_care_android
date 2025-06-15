import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';

class DoctorPatientProfileProvider extends ChangeNotifier {
  late DoctorPatientProfileModel _patientProfile = DoctorPatientProfileModel.empty();
  bool _isLoading = true;
  DoctorPatientProfileModel get patientProfile => _patientProfile;
  bool get isLoading => _isLoading;

  void setPatientProfile(Map<String, dynamic> rawDoctorPatientProfile, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((__) {
          log('message');
          _patientProfile = DoctorPatientProfileModel.fromMap(rawDoctorPatientProfile);
          if (notify) notifyListeners();
        });
          log('message');
          _patientProfile = DoctorPatientProfileModel.fromMap(rawDoctorPatientProfile);
        if (notify) notifyListeners();
      });
    } else {
      _isLoading = false;
      if (notify) notifyListeners();

      _patientProfile = DoctorPatientProfileModel.fromMap(rawDoctorPatientProfile);
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
