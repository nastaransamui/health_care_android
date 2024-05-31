import 'package:flutter/material.dart';
import 'package:health_care/models/vital_signs.dart';

class VitalProvider extends ChangeNotifier {
  VitalSigns? _vitalSigns;

  VitalSigns? get vitalSign => _vitalSigns;

  void setVitalSigns(Map<String, dynamic> data) {

      final signsFromAdmin =
          VitalSigns.fromMap(data);
      _vitalSigns = signsFromAdmin;


    notifyListeners();
  }
}
