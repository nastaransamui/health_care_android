import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/users.dart';

class FavouritesProvider extends ChangeNotifier {
  List<PatientUserProfile> _userFavProfile = [];
  List<DoctorUserProfile> _doctorFavProfileForPatient = [];
  bool _isLoading = true;
  int _total = 0;

  List<PatientUserProfile> get userFavProfile => _userFavProfile;
  List<DoctorUserProfile> get doctorFavProfileForPatient => _doctorFavProfileForPatient;
  bool get isLoading => _isLoading;
  int get total => _total;
  void setUserFavProfile(List<PatientUserProfile> usersFavProfile, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _userFavProfile = usersFavProfile;
          // _isLoading = false;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = true;
      if (notify) notifyListeners();

      _userFavProfile = usersFavProfile;
      // _isLoading = false;
      if (notify) notifyListeners();
    }
  }

  void setDoctorFavProfileForPatient(List<DoctorUserProfile> doctorFavProfileForPatient, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _doctorFavProfileForPatient = doctorFavProfileForPatient;
          // _isLoading = false;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = true;
      if (notify) notifyListeners();

      _doctorFavProfileForPatient = doctorFavProfileForPatient;
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
