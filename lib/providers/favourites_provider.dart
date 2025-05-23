import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/users.dart';

class FavouritesProvider extends ChangeNotifier {
  List<PatientUserProfile> _userFavProfile = [];
  bool _isLoading = true;
  int _total = 0;

  List<PatientUserProfile> get userFavProfile => _userFavProfile;
  bool get isLoading => _isLoading;
  int get total => _total;
  void setUserFavProfile(List<PatientUserProfile> usersFavProfile) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _userFavProfile = usersFavProfile;
          // _isLoading = false;
          notifyListeners();
        });
        notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = true;
      notifyListeners();

      _userFavProfile = usersFavProfile;
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
