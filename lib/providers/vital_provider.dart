import 'package:flutter/material.dart';
import 'package:health_care/models/vital_signs.dart';

class VitalProvider extends ChangeNotifier {
  VitalSigns? _vitalSigns;

  VitalSigns? get vitalSign => _vitalSigns;

  void setVitalSigns(List<dynamic> data) {
    if (data.isNotEmpty) {
      final signsFromAdmin = VitalSigns.fromMap(data[0]);
      _vitalSigns = signsFromAdmin;
    }else{
      _vitalSigns = null;
    }

    notifyListeners();
  }
}
