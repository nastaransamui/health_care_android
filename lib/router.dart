import 'package:flutter/material.dart';
import 'package:health_care/src/commons/not_found_error.dart';
import 'package:health_care/src/features/blog/blog_screen.dart';
import 'package:health_care/src/features/dashboard/patient_dashboard.dart';
import 'package:health_care/src/features/pharmacy/pharmacy_screen.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case PatientDashboard.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const PatientDashboard(),
      );
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
        builder: (_) => const SafeArea(
          child: NotFound404Error(),
        ),
      );
  }
}
