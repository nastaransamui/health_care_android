import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/app.dart';
import 'package:health_care/stream_socket.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initial easy localization
  await EasyLocalization.ensureInitialized();

  initiateSocket();

  runApp(
    EasyLocalization(
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
        streamSocket: streamSocket,
      ),
    ),
  );
}
