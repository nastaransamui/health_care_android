import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/src/app.dart';
import 'package:health_care/src/commons/not_found_error.dart';
import 'package:health_care/src/features/auth/forgot_screen.dart';
import 'package:health_care/src/features/auth/login_screen.dart';
import 'package:health_care/src/features/auth/signup_screen.dart';
import 'package:health_care/src/features/blog/blog_screen.dart';
import 'package:health_care/src/features/dashboard/patient_dashboard.dart';
import 'package:health_care/src/features/doctors/search/doctor_search.dart';
import 'package:health_care/src/features/pharmacy/pharmacy_screen.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// GoRouter configuration
final router = GoRouter(
  observers: [BotToastNavigatorObserver()],
  navigatorKey: NavigationService.navigatorKey,
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) {
        var homeActivePage = Provider.of<ThemeProvider>(context).homeActivePage;

        return CustomTransitionPage(
          key: state.pageKey,
          child: Builder(builder: (context) {
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
          }),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Change the opacity of the screen using a Curve based on the the animation's
            // value
            return FadeTransition(
              opacity:
                  CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/patient_dashboard',
      name: 'patient_dashboard',
      builder: (context, state) => const PatientDashboard(),
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        if (isLogin) {
          return '/patient_dashboard';
        } else {
          return null;
        }
      },
    ),
    GoRoute(
      path: '/pharmacy',
      name: 'pharmacy',
      builder: (context, state) => const PharmacyScreen(),
    ),
    GoRoute(
      path: '/blog',
      name: 'blog',
      builder: (context, state) => const BlogScreen(),
    ),
    GoRoute(
      path: '/contact',
      name: 'contact',
      builder: (context, state) => const NotFound404Error(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        return LoginScreen();
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        if (!isLogin) {
          return '/login';
        } else {
          return '/login';
        }
      },
    ),
    GoRoute(
      path: '/forgot',
      name: 'forgot',
      builder: (context, state) {
        return ForgotScreen();
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        if (!isLogin) {
          return '/forgot';
        } else {
          return '/';
        }
      },
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) {
        return SignupScreen();
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        if (!isLogin) {
          return '/signup';
        } else {
          return '/';
        }
      },
    ),
    GoRoute(
      path: '/doctors/search',
      name: 'doctorsSearch',
      builder: (context, state) {
        return DoctorSearch(queryParameters: state.uri.queryParameters);
      },
    )
  ],
  errorBuilder: (context, state) {
    return const SafeArea(
      child: NotFound404Error(),
    );
  },
);

// Route<dynamic> generateRoute(RouteSettings routeSettings) {
//   switch (routeSettings.name) {
//     case PatientDashboard.routeName:
//       return MaterialPageRoute(
//         settings: routeSettings,
//         builder: (_) => const PatientDashboard(),
//       );
//     case PharmacyScreen.routeName:
//       return MaterialPageRoute(
//         settings: routeSettings,
//         builder: (_) => const PharmacyScreen(),
//       );
//     case BlogScreen.routeName:
//       return MaterialPageRoute(
//         settings: routeSettings,
//         builder: (_) => const BlogScreen(),
//       );
//     default:
//       return MaterialPageRoute(
//         settings: routeSettings,
//         builder: (_) => const SafeArea(
//           child: NotFound404Error(),
//         ),
//       );
//   }
// }
