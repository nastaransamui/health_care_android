import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:health_care/controllers/theme_controller.dart';
import 'package:health_care/providers/clinics_provider.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/src/app.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

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

  ///Load Theme from shared_preferences
  final themeController = ThemeController();

  await themeController.loadTheme();

  //Initial easy localization
  EasyLocalization.logger.enableBuildModes = [];
  await EasyLocalization.ensureInitialized();
  
  initiateSocket();
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
      )
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
  ));
}
