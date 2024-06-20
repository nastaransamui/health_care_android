import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care/providers/vital_provider.dart';
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

final EasyLogger logger = EasyLogger(
  name: 'NamePrefix',
  defaultLevel: LevelMessages.debug,
  enableBuildModes: [BuildMode.debug, BuildMode.profile, BuildMode.release],
  enableLevels: [
    LevelMessages.debug,
    LevelMessages.info,
    LevelMessages.error,
    LevelMessages.warning
  ],
);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // await prefs.remove('isLogin');
    // await prefs.remove('homeAccessToken');
    // await prefs.remove('profile');
    // await prefs.remove('roleName');
  initiateSocket(isLogin, profile, roleName, userData);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ClinicsProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => SpecialitiesProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => DoctorsProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => UserDataProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => DeviceProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => AuthProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => VitalProvider(),
      ),
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
