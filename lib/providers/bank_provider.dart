import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/bank.dart';

class BankProvider extends ChangeNotifier {
  late BankWithReservations _bankWithReservations = BankWithReservations.empty();
  bool _isLoading = true;

  BankWithReservations get bankWithReservations => _bankWithReservations;
  bool get isLoading => _isLoading;

  void setBankWithReservations(BankWithReservations bankWithReservations, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _bankWithReservations = bankWithReservations;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = true;
      if (notify) notifyListeners();

      _bankWithReservations = bankWithReservations;
      if (notify) notifyListeners();
    }
  }
}
