import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/dependents.dart';

class DependentsProvider extends ChangeNotifier{
  List<Dependents> _dependents= [];
  bool _isLoading = true;
  int _total = 0;

  List<Dependents> get dependents => _dependents;
  bool get isLoading => _isLoading;
  int get total => _total;

  void setDependents(List<Dependents> dependents, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _dependents = dependents;
          // _isLoading = false;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = true;
      if (notify) notifyListeners();

      _dependents = dependents;
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