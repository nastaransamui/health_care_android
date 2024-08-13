import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/constants/navigator_key.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/src/commons/not_found_error.dart';
import 'package:health_care/src/features/auth/forgot_screen.dart';
import 'package:health_care/src/features/auth/login_screen.dart';
import 'package:health_care/src/features/auth/reset_password.dart';
import 'package:health_care/src/features/auth/signup_screen.dart';
import 'package:health_care/src/features/auth/verify_email.dart';
import 'package:health_care/src/features/blog/blog_screen.dart';
import 'package:health_care/src/features/dashboard/doctor_dashboard.dart';
import 'package:health_care/src/features/dashboard/patient_dashboard.dart';
import 'package:health_care/src/features/doctors/profile/doctors_search_profile.dart';
import 'package:health_care/src/features/doctors/search/doctor_search.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/features/pharmacy/pharmacy_screen.dart';

import 'package:go_router/go_router.dart';
import 'package:health_care/src/features/profile/doctors_dashboard_profile.dart';
import 'package:health_care/src/features/profile/patients_dashboard_profile.dart';
import 'package:health_care/src/landing/clinics/cardio_home.dart';
import 'package:health_care/src/landing/default.dart';
import 'package:health_care/src/landing/general_0_page.dart';
import 'package:health_care/src/landing/general_1_page.dart';
import 'package:health_care/src/landing/general_2_page.dart';
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
              case 'default':
                return const Default();
              default:
                return const LoadingScreen();
            }
          }),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Change the opacity of the screen using a Curve based on the the animation's
            // value
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/patient/dashboard',
      name: 'patientDashboard',
      builder: (context, state) => const PatientDashboard(),
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        if (isLogin) {
          if (roleName == 'doctors') {
            return '/doctors/dashboard';
          } else if (roleName == 'patient') {
            return '/patient/dashboard';
          } else {
            return null;
          }
        } else {
          return null;
        }
      },
    ),
    GoRoute(
      path: '/doctors/dashboard',
      name: 'doctorsDashboard',
      builder: (context, state) => const DoctorDashboard(),
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        if (isLogin) {
          if (roleName == 'doctors') {
            return '/doctors/dashboard';
          } else if (roleName == 'patient') {
            return '/patient/dashboard';
          } else {
            return '/';
          }
        } else {
          return '/';
        }
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/profile',
      name: 'doctorsDashboardProfile',
      builder: (context, state) {
        DoctorsProfile? doctorProfile;
        doctorProfile = Provider.of<AuthProvider>(context).doctorsProfile;
        var homeActivePage = Provider.of<ThemeProvider>(context).homeActivePage;
        if (doctorProfile != null) {
          return DoctorsDashboardProfile(doctorProfile: doctorProfile);
        } else {
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
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;

        if (isLogin) {
          if (roleName == 'doctors') {
            return '/doctors/dashboard/profile';
          } else if (roleName == 'patient') {
            return '/patient/dashboard/profile';
          } else {
            return '/';
          }
        } else {
          return '/';
        }
      },
    ),
    GoRoute(
      path: '/patient/dashboard/profile',
      name: 'patientsDashboardProfile',
      builder: (context, state) {
        PatientsProfile? patientProfile;
        patientProfile = Provider.of<AuthProvider>(context).patientProfile;
        var homeActivePage = Provider.of<ThemeProvider>(context).homeActivePage;
        if (patientProfile != null) {
          return PatientsDashboardProfile(patientProfile: patientProfile);
        } else {
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
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;

        if (isLogin) {
          if (roleName == 'doctors') {
            return '/doctors/dashboard/profile';
          } else if (roleName == 'patient') {
            return '/patient/dashboard/profile';
          } else {
            return '/';
          }
        } else {
          return '/';
        }
      },
    ),
    //Clinics
    GoRoute(
      path: '/cardiohome',
      name: 'cardiohome',
      builder: (context, state) => const CardioHome(),
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
          return '/';
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
        return const SignupScreen();
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
    ),
    GoRoute(
      path: '/doctors/profile/:id',
      name: 'doctorsSearchProfile',
      builder: (context, state) {
        return DoctorsSearchProfile(
          pathParameters: state.pathParameters,
        );
      },
      redirect: (context, state) {
        final DoctorsService doctorsService = DoctorsService();
        String? doctorId;
        DoctorUserProfile? doctor;
        var urlDec = Uri.decodeComponent(state.pathParameters['id']!);
        doctorId = encrypter.decrypt64(urlDec, iv: iv);
        doctorsService.findUserById(context, doctorId);
        doctor = Provider.of<DoctorsProvider>(context, listen: false).singleDoctor;
        if (doctor != null) {
          return state.namedLocation(
            'doctorsSearchProfile',
            pathParameters: state.pathParameters,
          );
        } else {
          return '/doctors/search';
        }
      },
    ),
    GoRoute(
      path: '/loading',
      name: 'loading',
      builder: (context, state) {
        return const LoadingScreen();
      },
    ),
    GoRoute(
      path: '/reset-password/:token',
      name: 'resetPassword',
      builder: (context, state) {
        return ResetPassword(
          pathParameters: state.pathParameters,
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        if (!isLogin) {
          return state.namedLocation('resetPassword', pathParameters: state.pathParameters);
        } else {
          if (roleName == 'doctors') {
            return '/';
          } else {
            return '/patient/dashboard';
          }
        }
      },
    ),
    GoRoute(
      path: '/verify-email/:token',
      name: 'verifyEmail',
      builder: (context, state) {
        return VerifyEmail(
          pathParameters: state.pathParameters,
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        if (!isLogin) {
          return state.namedLocation('verifyEmail', pathParameters: state.pathParameters);
        } else {
          if (roleName == 'doctors') {
            return '/';
          } else {
            return '/patient/dashboard';
          }
        }
      },
    )
  ],
  errorBuilder: (context, state) {
    return const SafeArea(
      child: NotFound404Error(),
    );
  },
);
