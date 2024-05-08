import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:health_care/models/theme_from_admin.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ThemeService {
  Future<void> getThemeFromAdmin(BuildContext context) async {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    ///Set theme if connection error
    socket.onConnectError(
      (_) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? getThemeFromAdmin = prefs.getString('getThemeFromAdmin');
        if (getThemeFromAdmin != null) {
          themeProvider.setThemeData(json.decode(getThemeFromAdmin));
        }
      },
    );

    // Set theme if connection
    socket.on('getThemeFromAdmin', (data) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('getThemeFromAdmin', json.encode(data));
      themeProvider.setThemeData(data);
      //  final themeFromAdmin = ThemeFromAdmin.fromJson(json.encode(data));

      // streamSocket.addResponse(themeFromAdmin.toJson());
    });
  }
}
