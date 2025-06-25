import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/user_from_token_provider.dart';
import 'package:health_care/providers/vital_provider.dart';
import 'package:health_care/src/utils/is_app_updated.dart';
import 'package:health_care/src/utils/show_update_notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:health_care/controllers/theme_controller.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/clinics_provider.dart';
import 'package:health_care/providers/device_provider.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/providers/user_data_provider.dart';
import 'package:health_care/src/app.dart';
import 'package:health_care/stream_socket.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

final EasyLogger logger = EasyLogger(
  name: 'NamePrefix',
  defaultLevel: LevelMessages.debug,
  enableBuildModes: [BuildMode.debug, BuildMode.profile, BuildMode.release],
  enableLevels: [LevelMessages.debug, LevelMessages.info, LevelMessages.error, LevelMessages.warning],
);
final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid || Platform.isIOS) {
    final status = await Permission.notification.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      log('Notification permission denied');
    }
  } else {
    log('Notification permission not required or not supported on this platform');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notification settings
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  final linuxInit = LinuxInitializationSettings(
    defaultActionName: 'Open',
    defaultIcon: AssetsLinuxIcon('icons/app_icon.png'), // Relative to linux/my_application/data/
  );

  final initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
    linux: linuxInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload == 'open_play_store') {
        const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.healthCareApp';
        final uri = Uri.parse(playStoreUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    },
  );
  final updated = await isAppUpdated();
  if (updated) {
    await showUpdateNotification();
  }

  ///Prevent orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  ///Load Theme from shared_preferences
  final themeController = ThemeController();
  tz.initializeTimeZones();

  ///Load auth from shared_preferences

  await themeController.loadTheme();
  await dotenv.load(fileName: '.env');

  //Initial easy localization
  EasyLocalization.logger.enableBuildModes = [];
  await EasyLocalization.ensureInitialized();
  // await SharedPreferences.getInstance();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? profile = prefs.getString('profile');
  final bool? isLogin = prefs.getBool('isLogin');
  final String? roleName = prefs.getString('roleName');
  final String? userData = prefs.getString('userData');

  ///Manual logout by removes all prefs
  // await prefs.remove('isLogin');
  // await prefs.remove('homeAccessToken');
  // await prefs.remove('profile');
  // await prefs.remove('roleName');
  initiateSocket(isLogin, profile, roleName, userData);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClinicsProvider()),
        ChangeNotifierProvider(create: (_) => SpecialitiesProvider()),
        ChangeNotifierProvider(create: (_) => DoctorsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VitalProvider()),
        ChangeNotifierProvider(create: (_) => UserFromTokenProvider()),
        ChangeNotifierProvider(create: (_) => DataGridProvider()),
      ],
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('th', 'TH'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale(
          'en',
          'US',
        ),
        child: MyApp(
          controller: themeController,
          streamSocket: streamSocket,
        ),
      ),
    ),
  );
}
