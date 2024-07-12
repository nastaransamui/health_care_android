// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/controllers/theme_controller.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/router.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/clinics_service.dart';
import 'package:health_care/services/device_service.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/services/specialities_service.dart';
import 'package:health_care/services/theme_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:health_care/theme_config.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';

class MyApp extends StatefulWidget {
  final StreamSocket streamSocket;
  final ThemeController controller;
  const MyApp({
    super.key,
    required this.streamSocket,
    required this.controller,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  // This widget is the root of your application.
  final ThemeService themeService = ThemeService();
  final AuthService authService = AuthService();
  final ClinicsService clinicsService = ClinicsService();
  final SpecialitiesService specialitiesService = SpecialitiesService();
  final DoctorsService doctorsService = DoctorsService();
  final DeviceService deviceService = DeviceService();
  @override
  void initState() {
    super.initState();
    themeService.getThemeFromAdmin(context);
    deviceService.getDeviceService(context);
    authService.getAuthService(context);
    clinicsService.getClinicData(context);
    specialitiesService.getSpecialitiesData(context);
    doctorsService.getDoctorsData(context, {
      "keyWord": null,
      "specialities": null,
      "gender": null,
      "country": null,
      "state": null,
      "city": null,
      "sortBy": 'profile.userName',
      "limit": 10,
      "skip": 0,
    });
  }

  @override
  Widget build(BuildContext context) {

    Jiffy.setLocale(context.locale.toString() == 'th_TH' ? 'th' : 'en');
    return StreamBuilder(
        stream: streamSocket.getResponse,
        initialData: '',
        builder: (context, snapshot) {
          var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;
          var homeThemeType = Provider.of<ThemeProvider>(context).homeThemeType;
          if (snapshot.hasData) {
            var data = snapshot.data;
            if (data!.isNotEmpty) {
              var response = jsonDecode(data);
              homeThemeName = response['homeThemeName'];
              homeThemeType = response['homeThemeType'];
              // homeActivePage = response['homeActivePage'];
            }
          }
          return MaterialApp.router(
            routerConfig: router,
            builder: BotToastInit(), //1. call BotToastInit
            // navigatorObservers: [BotToastNavigatorObserver()],
            debugShowCheckedModeBanner: false,
            restorationScopeId: 'health_care',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: themDataLive(
                homeThemeName.isEmpty
                    ? widget.controller.homeThemeName
                    : homeThemeName,
                homeThemeType.isEmpty
                    ? widget.controller.homeThemeType
                    : homeThemeType),
          );
        });
  }
}

