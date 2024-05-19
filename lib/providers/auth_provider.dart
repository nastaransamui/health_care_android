import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';

class AuthProvider extends ChangeNotifier {
  PatientsProfile? _patientProfile;
  DoctorsProfile? _doctorsProfile;
  String _homeAccessToken = '';
  String _roleName = '';
  bool _isLogin = false;

  PatientsProfile? get patientProfile => _patientProfile;
  DoctorsProfile? get doctorsProfile => _doctorsProfile;
  String get homeAccessToken => _homeAccessToken;
  String get roleName => _roleName;

  bool get isLogin => _isLogin;

  void setAuth(String token, bool isLogin, String profile) {
    var response = jsonDecode(profile);
    var roleName = response['roleName'];
    _homeAccessToken = token;
    _isLogin = isLogin;
    _roleName = roleName;

    if (roleName == 'patient') {
      final parsedPatient =
          PatientsProfile.fromJson(jsonEncode(jsonDecode(profile)));
      _patientProfile = parsedPatient;
      _doctorsProfile = null;
    } else if (roleName == 'doctors') {
      final parsedPatient =
          DoctorsProfile.fromJson(jsonEncode(jsonDecode(profile)));
      _patientProfile = null;
      _doctorsProfile = parsedPatient;
    }

    notifyListeners();
  }

  void removeAuth() {
    _doctorsProfile = null;
    _patientProfile = null;
    _homeAccessToken = '';
    _isLogin = false;
    _roleName = '';
    notifyListeners();
  }
}
