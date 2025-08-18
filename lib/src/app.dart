// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/navigator_key.dart';
import 'package:health_care/providers/theme_load_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/router.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/services/clinics_service.dart';
import 'package:health_care/services/device_service.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/services/specialities_service.dart';
import 'package:health_care/services/theme_service.dart';
import 'package:health_care/src/utils/show_update_notification.dart';
import 'package:health_care/stream_socket.dart';
import 'package:health_care/theme_config.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';

class MyApp extends StatefulWidget {
  final StreamSocket streamSocket;
  final ThemeLoadProvider themeLoadProvider;
  const MyApp({
    super.key,
    required this.streamSocket,
    required this.themeLoadProvider,
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
  final ChatService chatService = ChatService();
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
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
      FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) async {
          final data = message.data;

          // Delay to ensure MaterialApp is mounted
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final currentContext = NavigationService.navigatorKey.currentContext;

            String? currentRoomId;
            if (currentContext != null && currentContext.mounted) {
              final state = GoRouter.of(currentContext).state;
              currentRoomId = state.pathParameters["encodedRoomId"];
            }

            if (data['type'] == 'voiceCall') {
              try {
                final params = jsonDecode(data['params']);
                if (currentContext != null && currentContext.mounted) {
                  chatService.handleIncomingVoiceCall(
                    currentContext,
                    data: params,
                    currentUserId: params['receiverId'],
                  );
                }
              } catch (e) {
                debugPrint('Failed to decode params: $e');
              }
            } else {
              final roomId = data['roomId'];
              final encodedRoomId = base64.encode(utf8.encode(roomId));

              // Show notification if no room open OR different room open
              if (currentRoomId == null || currentRoomId != encodedRoomId) {
                await showChatNotification(message);
              }
            }
          });
        },
      );
      // FirebaseMessaging.onMessage.listen(
      //   (RemoteMessage message) async {
      //     // await showChatNotification(message);
      //     final currentContext = NavigationService.navigatorKey.currentContext;
      //     if (currentContext == null) return;
      //     if (currentContext.mounted) {
      //       final state = GoRouter.of(currentContext).state;
      //       final currentRoomId = state.pathParameters["encodedRoomId"];
      //       final data = message.data;
      //       if (data['type'] == 'voiceCall') {
      //         try {
      //           final params = jsonDecode(data['params']);
      //           debugPrint('Decoded params: $params');
      //           if (mounted) {
      //             chatService.handleIncomingVoiceCall(
      //               currentContext,
      //               data: params,
      //               currentUserId: params['receiverId'],
      //             );
      //           }
      //         } catch (e) {
      //           debugPrint('Failed to decode params: $e');
      //         }
      //       } else {
      //         final roomId = data['roomId'];
      //         final encodedRoomId = base64.encode(utf8.encode(roomId));
      //         //  Show notification only if no room is open
      //         if (currentRoomId == null) {
      //           await showChatNotification(message);
      //           // show notification if room open but different roome
      //         } else if (currentRoomId != encodedRoomId) {
      //           await showChatNotification(message);
      //         }
      //       }
      //     }
      //   },
      // );
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Navigate to relevant screen or show a dialog
        log('2${message.toString()}');
      });

      Future<void> checkInitialMessage() async {
        RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null) {
          log("App launched via notification: ${initialMessage.notification?.title}");
          // Handle deep link/navigation here
        }
      }

      checkInitialMessage();
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
          theme: themDataLive(homeThemeName.isEmpty ? widget.themeLoadProvider.homeThemeName : homeThemeName,
              homeThemeType.isEmpty ? widget.themeLoadProvider.homeThemeType : homeThemeType),
        );
      },
    );
  }
}
