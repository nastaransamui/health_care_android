// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/router.dart';
// import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/silver_scaffold_wrapper.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/stream_socket.dart';
import 'package:health_care/theme_config.dart';

class MyApp extends StatefulWidget {
  final StreamSocket streamSocket;
  const MyApp({super.key, required this.streamSocket});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  // This widget is the root of your application.
  late final AnimationController _controller = AnimationController(vsync: this);
  String homeThemeName = '';
  String homeThemeType = '';
  String homeActivePage = '';
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: streamSocket.getResponse,
        initialData: '',
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            if (data!.isNotEmpty) {
              var response = jsonDecode(data);
              homeThemeName = response['homeThemeName'];
              homeThemeType = response['homeThemeType'];
              homeActivePage = response['homeActivePage'];
            }
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            restorationScopeId: 'health_care',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: themDataLive(homeThemeName, homeThemeType),
            onGenerateRoute: (settings) => generateRoute(settings),
            home: snapshot.hasData
                ? AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, Widget? child) {
                      return Builder(
                        builder: (context) {
                          switch (homeActivePage) {
                            case 'general_0':
                              return const General0Page();
                            case 'general_1':
                              return const General1Page();
                            case 'general_2':
                              return const General2Page();
                            default:
                            return const Default();
                          }
                          
                        }
                      );
                    },
                    // child: const MyHomePage(),
                  )
                : const LoadingScreen(),
          );
        });
  }
}

class Default extends StatefulWidget {
  static const String routeName = '/';
  const Default({
    super.key,
  });


  @override
  State<Default> createState() => _DefaultState();
}

class _DefaultState extends State<Default> {
  @override
  Widget build(BuildContext context) {
    return const SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Default'),
        ],
      ),
    );
  }
}

class General0Page extends StatefulWidget {
    static const String routeName = '/';
  const General0Page({
    super.key,
  });


  @override
  State<General0Page> createState() => _General0PageState();
}

class _General0PageState extends State<General0Page> {
  @override
  Widget build(BuildContext context) {
    return const SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('General 0 Page'),
        ],
      ),
    );
  }
}


class General1Page extends StatefulWidget {
    static const String routeName = '/';
  const General1Page({
    super.key,
  });


  @override
  State<General1Page> createState() => _General1PageState();
}

class _General1PageState extends State<General1Page> {
  @override
  Widget build(BuildContext context) {
    return const SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('General 1 Page'),
        ],
      ),
    );
  }
}


class General2Page extends StatefulWidget {
    static const String routeName = '/';
  const General2Page({
    super.key,
  });


  @override
  State<General2Page> createState() => _General2PageState();
}

class _General2PageState extends State<General2Page> {
  @override
  Widget build(BuildContext context) {
    return const SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('General 2 Page'),
        ],
      ),
    );
  }
}