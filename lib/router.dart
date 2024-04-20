import 'package:flutter/material.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/features/blog/blog_screen.dart';
import 'package:health_care/src/features/pharmacy/pharmacy_screen.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case PharmacyScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const PharmacyScreen(),
      );
    case BlogScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BlogScreen(),
      );
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('not Found'),
            ),
            body: const Center(child: Text('Screen does not exist')),
            bottomNavigationBar: const BottomBar(
              showLogin: true,
            ),
          ),
        ),
      );
  }
}
