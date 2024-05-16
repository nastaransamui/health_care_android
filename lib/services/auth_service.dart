import 'package:flutter/material.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/src/utils/verify_home_access_token.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> getAuthService(BuildContext context) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? homeAccessToken = prefs.getString('homeAccessToken');
    final String? profile = prefs.getString('profile');
    if (homeAccessToken != null && profile != null) {
      authProvider.setAuth(homeAccessToken, true, profile);
    }else{
      authProvider.removeAuth();
    }
  }

  Future<void> loginService(BuildContext context, String token) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var payloadData = verifyHomeAccessToken(token);
    prefs.setBool('isLogin', true);
    prefs.setString('homeAccessToken', token);
    prefs.setString('profile', payloadData);
    authProvider.setAuth(token, true, payloadData);
  }

  Future<void> logoutService(BuildContext context) async {

    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('homeAccessToken');
    await prefs.remove('profile');
    authProvider.removeAuth();

  }
}
