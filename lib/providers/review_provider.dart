import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/reviews.dart';

class ReviewProvider extends ChangeNotifier {
   List<Reviews> _reviews = [];
   List<PatientReviews> _patientReviews = [];
  bool _isLoading = true;
  int _total = 0;
  List<Reviews> get reviews => _reviews;
  List<PatientReviews> get patientReviews => _patientReviews;
  bool get isLoading => _isLoading;
  int get total => _total;
  void setReviews(List<Reviews> reviews, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _reviews = reviews;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      _isLoading = false;
      if (notify) notifyListeners();

      _reviews = reviews;
      if (notify) notifyListeners();
    }
  }


  void setPatientReviews(List<PatientReviews> patientReviews, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _patientReviews = patientReviews;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      _isLoading = false;
      if (notify) notifyListeners();

      _patientReviews = patientReviews;
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
