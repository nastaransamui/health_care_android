import 'package:flutter/material.dart';
import 'package:health_care/models/doctors.dart';

class DoctorsProvider extends ChangeNotifier {
  final List<Doctors> _doctors = [];

  List<Doctors> get doctors => _doctors;

  void setDoctors(List<dynamic> doctors) {
    _doctors.clear();
    for (var element in doctors) {
      final doctorsFromAdmin = Doctors.fromMap(element);
      _doctors.add(doctorsFromAdmin);
    }
    notifyListeners();
  }
}
