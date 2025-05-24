import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/users.dart';

class MyPatientsProvider extends ChangeNotifier {
  List<PatientUserProfile> _myPatientsProfile = [];
  bool _isLoading = true;
  int _total = 0;

  List<PatientUserProfile> get myPatientsProfile => _myPatientsProfile;
  bool get isLoading => _isLoading;
  int get total => _total;

  void setMyPatientsProfile(List<PatientUserProfile> myPatientsProfiles) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _myPatientsProfile = myPatientsProfiles;
          // _isLoading = false;
          notifyListeners();
        });
        notifyListeners();
      });
    } else {
      _myPatientsProfile = myPatientsProfiles;
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
