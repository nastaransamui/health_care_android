import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/constants/navigator_key.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/favourites_provider.dart';
import 'package:health_care/providers/invoice_provider.dart';
import 'package:health_care/providers/my_patients_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/providers/time_schedule_provider.dart';
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
import 'package:health_care/src/features/doctors/appointments/appointments.dart';
import 'package:health_care/src/features/doctors/available_timing/doctors_available_timing.dart';
import 'package:health_care/src/features/doctors/dashboard_appointment/dash_appointment.dart';
import 'package:health_care/src/features/doctors/favourites/doctors_favourites.dart';
import 'package:health_care/src/features/doctors/invoice/doctors_invoice.dart';
import 'package:health_care/src/features/doctors/my_patients/doctors_my_patients.dart';
import 'package:health_care/src/features/doctors/profile/doctors_search_profile.dart';
import 'package:health_care/src/features/doctors/schedule/doctors_dashboard_schedule_timing.dart';
import 'package:health_care/src/features/doctors/search/doctor_search.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/features/pharmacy/pharmacy_screen.dart';

import 'package:go_router/go_router.dart';
import 'package:health_care/src/features/profile/doctors_dashboard_profile.dart';
import 'package:health_care/src/features/profile/patients_dashboard_profile.dart';
import 'package:health_care/src/landing/clinics/cardio_home.dart';
import 'package:health_care/src/landing/clinics/eye_care_home.dart';
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
    //Doctors Dashboard
    GoRoute(
      path: '/doctors/dashboard',
      name: 'doctorsDashboard',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => AppointmentProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DoctorDashboard(key: ValueKey(doctorProfile.userId));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (innerContext.mounted) {
                    // Use innerContext here
                    innerContext.go('/');
                  }
                });
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final doctorProfile = authProvider.doctorsProfile;

        if (doctorProfile != null) {
          return DoctorsDashboardProfile(doctorProfile: doctorProfile);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/');
            }
          });
          return const SizedBox.shrink();
        }
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final doctorProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
        if (!isLogin) return '/';
        if (roleName != 'doctors') return '/';
        if (doctorProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/appointments/this_week',
      name: 'dashboardAppointmentsThisWeek',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => AppointmentProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DashboardAppointments(key: ValueKey(doctorProfile.userId),isToday: false,);
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (innerContext.mounted) {
                    // Use innerContext here
                    innerContext.go('/');
                  }
                });
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final doctorProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
        if (!isLogin) return '/';
        if (roleName != 'doctors') return '/';
        if (doctorProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/appointments/today',
      name: 'dashboardAppointmentsToday',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => AppointmentProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DashboardAppointments(key: ValueKey(doctorProfile.userId),isToday: true,);
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (innerContext.mounted) {
                    // Use innerContext here
                    innerContext.go('/');
                  }
                });
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final doctorProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
        if (!isLogin) return '/';
        if (roleName != 'doctors') return '/';
        if (doctorProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/appointments',
      name: 'doctorAppointments',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => AppointmentProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DoctorAppointments(key: ValueKey(doctorProfile.userId));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (innerContext.mounted) {
                    // Use innerContext here
                    innerContext.go('/');
                  }
                });
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final doctorProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
        if (!isLogin) return '/';
        if (roleName != 'doctors') return '/';
        if (doctorProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/favourites',
      name: 'doctorFavourites',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => FavouritesProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DoctorsFavourites(key: ValueKey(doctorProfile.userId));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (innerContext.mounted) {
                    // Use innerContext here
                    innerContext.go('/');
                  }
                });
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final doctorProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
        if (!isLogin) return '/';
        if (roleName != 'doctors') return '/';
        if (doctorProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/my-patients',
      name: 'doctorMyPatients',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => MyPatientsProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DoctorsMyPatients(key: ValueKey(doctorProfile.userId));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (innerContext.mounted) {
                    // Use innerContext here
                    innerContext.go('/');
                  }
                });
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final doctorProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
        if (!isLogin) return '/';
        if (roleName != 'doctors') return '/';
        if (doctorProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/available-timing',
      name: 'doctorAvailableTiming',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => AppointmentProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DoctorsAvailableTiming(key: ValueKey(doctorProfile.userId));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.go('/');
                  }
                });
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final doctorProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
        if (!isLogin) return '/';
        if (roleName != 'doctors') return '/';
        if (doctorProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/schedule-timing',
      name: 'doctorsDashboardScheduleTiming',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => TimeScheduleProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DoctorsDashboardScheduleTiming(key: ValueKey(doctorProfile.userId), doctorProfile: doctorProfile);
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (innerContext.mounted) {
                    // Use innerContext here
                    innerContext.go('/');
                  }
                });
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final doctorProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
        if (!isLogin) return '/';
        if (roleName != 'doctors') return '/';
        if (doctorProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/invoice',
      name: 'doctorsInvoices',
      builder: (context, state) {
        // Wrap the DoctorsInvoice widget with ChangeNotifierProvider
        return ChangeNotifierProvider(
          create: (context) => InvoiceProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DoctorsInvoice(key: ValueKey(doctorProfile.userId));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (innerContext.mounted) {
                    // Use innerContext here
                    innerContext.go('/');
                  }
                });
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
      redirect: (context, state) {
        // Redirect logic remains the same, as AuthProvider is likely a global provider
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final doctorProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
        if (!isLogin) return '/';
        if (roleName != 'doctors') return '/';
        if (doctorProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/profile',
      name: 'patientsDashboardProfile',
      builder: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final patientProfile = authProvider.patientProfile;

        if (patientProfile != null) {
          return PatientsDashboardProfile(patientProfile: patientProfile);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/');
            }
          });
          return const SizedBox.shrink();
        }
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'doctors') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    //Clinics
    GoRoute(
      path: '/cardiohome',
      name: 'cardiohome',
      builder: (context, state) => const CardioHome(),
    ),
    GoRoute(
      path: '/eyecarehome',
      name: 'eyecarehome',
      builder: (context, state) => const EyeCareHome(),
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
        // DoctorUserProfile? doctor;
        var urlDec = Uri.decodeComponent(state.pathParameters['id']!);
        doctorId = encrypter.decrypt64(urlDec, iv: iv);
        doctorsService.findUserById(context, doctorId);
        // doctor = Provider.of<DoctorsProvider>(context, listen: false).singleDoctor;
        return state.namedLocation(
          'doctorsSearchProfile',
          pathParameters: state.pathParameters,
        );
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
