import 'package:flutter/material.dart';
import 'package:health_care/models/specialities.dart';

class SpecialitiesProvider extends ChangeNotifier {
  final List<Specialities> _specialities = [];

  List<Specialities> get specialities => _specialities;

  void setSpecialities(List<dynamic> specialities) {
    _specialities.clear();
    for (var element in specialities) {
      final specialitiesFromAdmin = Specialities.fromMap(element);
      _specialities.add(specialitiesFromAdmin);
    }
    notifyListeners();
  }
}
