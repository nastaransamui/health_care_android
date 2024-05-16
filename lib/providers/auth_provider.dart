import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/models/patients.dart';

class AuthProvider extends ChangeNotifier {
   Patients? _profile;
  String _homeAccessToken = '';
  bool _isLogin = false;

  Patients? get profile => _profile;
  String get homeAccessToken => _homeAccessToken;

  bool get isLogin => _isLogin;

  void setAuth(String token, bool isLogin, String profile) {
    _homeAccessToken = token;
    _isLogin = isLogin;
    final parsedPatient = Patients.fromJson(jsonEncode(jsonDecode(profile)));
    _profile = parsedPatient;
    notifyListeners();
  }

  void removeAuth() {
    _profile ;
    _homeAccessToken = '';
    _isLogin = false;
    notifyListeners();
  }
}
