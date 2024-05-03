import 'package:flutter/material.dart';
import 'package:health_care/models/clinics.dart';

class ClinicsProvider extends ChangeNotifier {
  final List<Clinics> _clinics = [];

  List<Clinics> get clinics => _clinics;

  void setClinics(List<dynamic> clinics) {
    _clinics.clear();
    for (var element in clinics) {
      final clinicsFromAdmin = Clinics.fromMap(element);
      _clinics.add(clinicsFromAdmin);
    }
    notifyListeners();
  }
}
