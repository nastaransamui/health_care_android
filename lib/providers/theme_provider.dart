import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  String _homeThemeName = '';
  String _homeThemeType = '';
  String _homeActivePage = '';

  // Allow Widgets to read the user's preferred ThemeMode.
  String get homeThemeName => _homeThemeName;
  String get homeThemeType => _homeThemeType;
  String get homeActivePage => _homeActivePage;

  void setThemeData(Map<dynamic, dynamic> themDataLive) async {
    _homeThemeName = themDataLive['homeThemeName'];
    _homeThemeType = themDataLive['homeThemeType'];
    _homeActivePage = themDataLive['homeActivePage'];
    notifyListeners();
  }
}
