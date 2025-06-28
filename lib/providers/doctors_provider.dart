
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/doctors.dart';
import 'package:health_care/models/users.dart';

class DoctorsProvider extends ChangeNotifier {
  final List<Doctors> _doctors = [];
  List<Doctors> _searchDoctors = [];
  int _total = 0;
  DoctorUserProfile? _doctor;

  List<Doctors> get doctors => _doctors;
  List<Doctors> get searchDoctors => _searchDoctors;
  int get total => _total;
  DoctorUserProfile? get singleDoctor => _doctor;

  void setDoctors(List<dynamic> doctors) {
    _doctors.clear();
    for (var element in doctors) {
      final doctorsFromAdmin = Doctors.fromJson(element);
      _doctors.add(doctorsFromAdmin);
    }
    notifyListeners();
  }

  void setDoctorsSearch(List<Doctors> searchDoctors, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _searchDoctors = searchDoctors;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      if (notify) notifyListeners();

      _searchDoctors = searchDoctors;
      if (notify) notifyListeners();
    }
  }


  void setTotal(int value, {bool notify = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _total = value;
      if (notify) notifyListeners();
    });
  }

  void setSingleDoctor(Map<String, dynamic> doctor) {
    final doctorFromAdmin = DoctorUserProfile.fromMap(doctor);
    _doctor = doctorFromAdmin;
    notifyListeners();
  }
}
