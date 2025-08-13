import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeLoadProvider with ChangeNotifier {
  late String _homeThemeName;
  late String _homeThemeType;
  late String _homeActivePage;

  String get homeThemeName => _homeThemeName;
  String get homeThemeType => _homeThemeType;
  String get homeActivePage => _homeActivePage;

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? themDataPrefs = prefs.getString('getThemeFromAdmin');
    if (themDataPrefs != null) {
      var formatedTheme = json.decode(themDataPrefs);
      _homeThemeName = formatedTheme['homeThemeName'];
      _homeThemeType = formatedTheme['homeThemeType'];
      _homeActivePage = formatedTheme['homeActivePage'];
    } else {
      _homeThemeName = 'cloud';
      _homeThemeType = 'dark';
      _homeActivePage = 'default';
    }

    notifyListeners();
  }
}
