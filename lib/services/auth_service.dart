// ignore_for_file: implementation_imports

import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/navigator_key.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/src/utils/verify_home_access_token.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:flutter/scheduler.dart';

class AuthService {
  final Localization L = Localization.instance;

  Future<void> getAuthService(BuildContext context) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? homeAccessToken = prefs.getString('homeAccessToken');
    final String? profile = prefs.getString('profile');

    final bool? isLogin = prefs.getBool('isLogin');
    if (isLogin != null && isLogin) {
      authProvider.setAuth(homeAccessToken!, true, profile!);
    } else {
      authProvider.removeAuth();
    }
  }

  Future<void> updateLiveAuth(BuildContext context) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    socket.on('getUserProfileFromAdmin', (token) async {
      var payloadData = verifyHomeAccessToken(token);
      var response = jsonDecode(payloadData);
      var roleName = response['roleName'];
      final bool? newIsLogin = prefs.getBool('isLogin');
      // var currentContext =
      //     NavigationService.navigatorKey.currentContext as BuildContext;
      if (response['accessToken'].isEmpty) {
        //logout
        if (newIsLogin != null) {
          BotToast.showCustomLoading(
            duration: const Duration(
              seconds: 3,
            ),
            toastBuilder: (void Function() cancelFunc) {
              return Text(L.tr('notEligible'));
            },
          );

          logoutService();
        }
      } else {
        final bool? isLogin = prefs.getBool('isLogin');
        //Check is Login or not
        if (isLogin != null && isLogin) {
          var payloadData = verifyHomeAccessToken(token);
          prefs.setBool('isLogin', true);
          prefs.setString('homeAccessToken', token);
          prefs.setString('profile', payloadData);
          prefs.setString('roleName', roleName);
          authProvider.setAuth(token, true, payloadData);
        }
      }
    });
  }

  Future<void> loginService(BuildContext context, String token) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var payloadData = verifyHomeAccessToken(token);
    var response = jsonDecode(payloadData);
    var roleName = response['roleName'];
    prefs.setBool('isLogin', true);
    prefs.setString('homeAccessToken', token);
    prefs.setString('profile', payloadData);
    prefs.setString('roleName', roleName);
    late String accessToken = '';
    late String userid = '';

    if (roleName == 'patient') {
      final parsedPatient = PatientsProfile.fromJson(
        jsonEncode(
          jsonDecode(payloadData),
        ),
      );
      accessToken = parsedPatient.accessToken;
      userid = parsedPatient.userId;
    } else if (roleName == 'doctors') {
      final parsedDoctor = DoctorsProfile.fromJson(
        jsonEncode(
          jsonDecode(payloadData),
        ),
      );
      accessToken = parsedDoctor.accessToken;
      userid = parsedDoctor.userId;
    }

    socket.io.options?['extraHeaders'] = {
      'userData': "${prefs.getString('userData')}",
      'token': 'Bearer $accessToken',
      'userid': userid //${parsedProfile?.userId}
    }; // Update the extra headers.
    socket.io
      ..disconnect()
      ..connect();
    authProvider.setAuth(token, true, payloadData);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final currentUri = GoRouter.of(context).routerDelegate.currentConfiguration.uri;
      final isLoginPage = currentUri.path == '/login';
      if (isLoginPage) {
        if (GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString() != '/') {
          if (roleName == 'doctors') {
            context.go('/doctors/dashboard');
          } else if (roleName == 'patient') {
            context.go('/patient/dashboard');
          }
        }
      } else {
        Navigator.of(context).maybePop();
      }
    });
  }

  Future<void> updateProfile(BuildContext context, String token) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var payloadData = verifyHomeAccessToken(token);
    var response = jsonDecode(payloadData);
    var roleName = response['roleName'];
    prefs.setBool('isLogin', true);
    prefs.setString('homeAccessToken', token);
    prefs.setString('profile', payloadData);
    prefs.setString('roleName', roleName);

    authProvider.setAuth(token, true, payloadData);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
    });
  }

  Future<void> logoutService() async {
    BuildContext context = NavigationService.navigatorKey.currentContext!;
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('homeAccessToken');
    await prefs.remove('profile');
    await prefs.remove('roleName');
    authProvider.removeAuth();

    socket.io.options?['extraHeaders'] = {
      'userData': "${prefs.getString('userData')}",
      'token': 'Bearer ',
      'userid': ''
    }; // Update the extra headers.
    socket.io
      ..disconnect()
      ..connect();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final currentUri = GoRouter.of(context).routerDelegate.currentConfiguration.uri;
      if (currentUri.path.startsWith('/dashboard')) {
        context.go('/');
      }
    });
  }

  /// Method to load translations since context is not available in isolate.
  Future<void> loadTranslations() async {
    //this will only set EasyLocalizationController.savedLocale
    await EasyLocalizationController.initEasyLocation();

    final controller = EasyLocalizationController(
      saveLocale: true, //mandatory to use EasyLocalizationController.savedLocale
      fallbackLocale: const Locale(
        'en',
        'US',
      ),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
      assetLoader: const RootBundleAssetLoader(),
      useOnlyLangCode: false,
      useFallbackTranslations: true,
      path: 'assets/translations',
      onLoadError: (FlutterError e) {},
    );

    //Load translations from assets
    await controller.loadTranslations();

    //load translations into exploitable data, kept in memory
    Localization.load(controller.locale, translations: controller.translations, fallbackTranslations: controller.fallbackTranslations);
  }
}
