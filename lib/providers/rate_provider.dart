import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RateProvider extends ChangeNotifier {
  List<double> _ratesArray = [];
  bool _isLoading = true;
  int _total = 0;
  List<double> get ratesArray => _ratesArray;
  bool get isLoading => _isLoading;
  int get total => _total;
  void setRateArray(List<double> ratesArray, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _ratesArray = ratesArray;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      _isLoading = false;
      if (notify) notifyListeners();

      _ratesArray = ratesArray;
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
