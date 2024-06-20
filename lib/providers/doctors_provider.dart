import 'package:flutter/material.dart';
import 'package:health_care/models/doctors.dart';

class DoctorsProvider extends ChangeNotifier {
  final List<Doctors> _doctors = [];
  final List<Doctors> _searchDoctors = [];
  int? _totalDoctors;

  List<Doctors> get doctors => _doctors;
  List<Doctors> get searchDoctors => _searchDoctors;
  int? get totalDoctors => _totalDoctors;

   void setDoctors(List<dynamic> doctors) {
    _doctors.clear();
    for (var element in doctors) {
      final doctorsFromAdmin = Doctors.fromMap(element);
      _doctors.add(doctorsFromAdmin);
    }
    notifyListeners();
  }
    void setDoctorsSearch(List<dynamic> doctors, int totalDoctors)  {
    _searchDoctors.clear();
    for (var element in doctors) {
      final doctorsFromAdmin = Doctors.fromMap(element);
      _searchDoctors.add(doctorsFromAdmin);
    }
    _totalDoctors = totalDoctors;
    notifyListeners();
  }

 
}
