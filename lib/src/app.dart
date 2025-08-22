
import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/navigator_key.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/providers/auth_provider.dart';
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
import 'package:health_care/shared/chat/chat_helpers/end_voice_call.dart';
import 'package:health_care/src/utils/show_update_notification.dart';
import 'package:health_care/stream_socket.dart';
import 'package:health_care/theme_config.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            if (data['type'] == 'endVoiceCall') {
              final params = jsonDecode(data['params']);
              try {
                var authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (params['callerData'] != null && params['receiverData'] != null) {
                  final MessageType messageData = MessageType.fromMap(params['messageData']);
                  final ChatUserType callerData = ChatUserType.fromMap(params['callerData']);
                  final ChatUserType receiverData = ChatUserType.fromMap(params['receiverData']);
                  final String? currentUserId =
                      authProvider.roleName == "doctors" ? authProvider.doctorsProfile?.userId : authProvider.patientProfile?.userId;

                  if (currentUserId != null) {
                    if (currentContext != null && currentContext.mounted) {
                      String? currentRoomId;
                      try {
                        final state = GoRouter.of(currentContext).state;
                        currentRoomId = state.pathParameters["encodedRoomId"];
                      } catch (e) {
                        log("GoRouter not ready yet: $e");
                      }
                      if (currentRoomId == null) endVoiceCall(currentContext, messageData, callerData, receiverData, currentUserId, false);
                    }
                  }
                }
              } catch (e) {
                log("data['type'] == 'endVoiceCall'1: $e ");
              }
            }
            if (data['type'] == 'voiceCall') {
              try {
                final params = jsonDecode(data['params']);
                if (currentContext != null && currentContext.mounted) {
                  if (currentRoomId == null) {
                    chatService.handleIncomingVoiceCall(
                      currentContext,
                      data: params,
                      currentUserId: params['receiverId'],
                    );
                  }
                }
              } catch (e) {
                debugPrint('Failed to decode params: $e');
              }
            }
            if (data['roomId'] != null) {
              final roomId = data['roomId'];
              final encodedRoomId = base64.encode(utf8.encode(roomId));

              // Show notification if no room open OR different room open
              if (currentRoomId == null || currentRoomId != encodedRoomId) {
                await showChatNotification(message);
              }
            }
            if (data['type'] == 'update') {
              // Local notification about app update
              if (mounted) await showUpdateDialog(context);
              return;
            }
          });
        },
      );

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        final data = message.data;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final currentContext = NavigationService.navigatorKey.currentContext;

          String? currentRoomId;
          if (currentContext != null && currentContext.mounted) {
            final state = GoRouter.of(currentContext).state;
            currentRoomId = state.pathParameters["encodedRoomId"];
          }
          if (data['type'] == 'endVoiceCall') {
            final params = jsonDecode(data['params']);
            try {
              var authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (params['callerData'] != null && params['receiverData'] != null) {
                final MessageType messageData = MessageType.fromMap(params['messageData']);
                final ChatUserType callerData = ChatUserType.fromMap(params['callerData']);
                final ChatUserType receiverData = ChatUserType.fromMap(params['receiverData']);
                final String? currentUserId =
                    authProvider.roleName == "doctors" ? authProvider.doctorsProfile?.userId : authProvider.patientProfile?.userId;

                if (currentUserId != null) {
                  if (currentContext != null && currentContext.mounted) {
                    if (currentRoomId == null) endVoiceCall(currentContext, messageData, callerData, receiverData, currentUserId, false);
                  }
                }
              }
            } catch (e) {
              log("data['type'] == 'endVoiceCall'2: $e");
            }
          }
          if (data['type'] == 'voiceCall') {
            try {
              final params = jsonDecode(data['params']);
              if (currentContext != null && currentContext.mounted) {
                if (currentRoomId == null) {
                  chatService.handleIncomingVoiceCall(
                    currentContext,
                    data: params,
                    currentUserId: params['receiverId'],
                  );
                }
              }
            } catch (e) {
              debugPrint('Failed to decode params: $e');
            }
          }
          if (data['roomId'] != null) {
            final roomId = data['roomId'];
            final encodedRoomId = base64.encode(utf8.encode(roomId));
            // Show notification if no room open OR different room open
            if (currentRoomId == null || currentRoomId != encodedRoomId) {
              // await showChatNotification(message);
              try {
                BuildContext context = NavigationService.navigatorKey.currentContext!;
                final roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
                if (roleName == 'patient') {
                  context.push('/patient/dashboard/patient-chat/single/$encodedRoomId');
                } else {
                  context.push('/doctors/dashboard/doctors-chat/single/$encodedRoomId');
                }
              } catch (e) {
                log('onMessageOpenedApp error: $e');
              }
            }
          }
          if (message.notification?.title == 'Update Available') {
            // Local notification about app update
            if (currentContext != null) await showUpdateDialog(currentContext);
            return;
          }
        });
      });

      Future<void> checkInitialMessage() async {
        RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage == null) return;

        final currentContext = NavigationService.navigatorKey.currentContext;
        final data = initialMessage.data;
        if (initialMessage.notification?.title == 'Update Available') {
          // Local notification about app update
          if (currentContext != null && currentContext.mounted) await showUpdateDialog(currentContext);
          return;
        }
        final messageId = initialMessage.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
        final uniqueKey = '${data['roomId']}_$messageId';

        final prefs = await SharedPreferences.getInstance();
        final lastHandledKey = prefs.getString('last_handled_message_id');
        if (lastHandledKey == null || uniqueKey == lastHandledKey) {
          return;
        }

        if (currentContext == null || !currentContext.mounted) return;
        String? currentRoomId;
        try {
          final state = GoRouter.of(currentContext).state;
          currentRoomId = state.pathParameters["encodedRoomId"];
        } catch (e) {
          log("GoRouter not ready yet: $e");
        }
        switch (data['type']) {
          case 'endVoiceCall':
            _handleEndVoiceCall(currentContext, data, currentRoomId);
            break;

          case 'voiceCall':
            _handleIncomingVoiceCall(currentContext, data);
            break;

          default:
            final roomId = data['roomId'];
            final encodedRoomId = base64.encode(utf8.encode(roomId));
            if (currentRoomId == null || currentRoomId != encodedRoomId) {
              await showChatNotification(initialMessage);
            }
        }
        await prefs.setString('last_handled_message_id', uniqueKey);
      }

      checkInitialMessage();
    });
  }

  void _handleEndVoiceCall(BuildContext context, Map<String, dynamic> data, String? currentRoomId) {
    try {
      final params = jsonDecode(data['params']);
      final authProvider = Provider.of<AuthProvider>(
        NavigationService.navigatorKey.currentContext!,
        listen: false,
      );

      final messageData = MessageType.fromMap(params['messageData']);
      final callerData = ChatUserType.fromMap(params['callerData']);
      final receiverData = ChatUserType.fromMap(params['receiverData']);
      final currentUserId = authProvider.roleName == "doctors" ? authProvider.doctorsProfile?.userId : authProvider.patientProfile?.userId;

      if (currentUserId != null) {
        if (currentRoomId == null) endVoiceCall(context, messageData, callerData, receiverData, currentUserId, false);
      }
    } catch (e) {
      log("Failed to handle endVoiceCall: $e");
    }
  }

  void _handleIncomingVoiceCall(BuildContext context, Map<String, dynamic> data) {
    try {
      final params = jsonDecode(data['params']);
      chatService.handleIncomingVoiceCall(
        context,
        data: params,
        currentUserId: params['receiverId'],
      );
    } catch (e) {
      debugPrint('Failed to decode params: $e');
    }
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