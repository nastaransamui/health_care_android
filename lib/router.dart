import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:health_care/constants/navigator_key.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/bank_provider.dart';
import 'package:health_care/providers/bill_provider.dart';
import 'package:health_care/providers/billing_provider.dart';
import 'package:health_care/providers/booking_information_provider.dart';
import 'package:health_care/providers/dependents_provider.dart';
import 'package:health_care/providers/doctor_patient_profile_provider.dart';
import 'package:health_care/providers/favourites_provider.dart';
import 'package:health_care/providers/invoice_provider.dart';
import 'package:health_care/providers/medical_records_provider.dart';
import 'package:health_care/providers/my_patients_provider.dart';
import 'package:health_care/providers/patient_appointment_provider.dart';
import 'package:health_care/providers/prescription_provider.dart';
import 'package:health_care/providers/rate_provider.dart';
import 'package:health_care/providers/reservation_provider.dart';
import 'package:health_care/providers/review_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/providers/time_schedule_provider.dart';
import 'package:health_care/providers/widget_injection_provider.dart';
import 'package:health_care/src/commons/not_found_error.dart';
import 'package:health_care/src/features/auth/change_password.dart';
import 'package:health_care/src/features/auth/forgot_screen.dart';
import 'package:health_care/src/features/auth/login_screen.dart';
import 'package:health_care/src/features/auth/reset_password.dart';
import 'package:health_care/src/features/auth/signup_screen.dart';
import 'package:health_care/src/features/auth/verify_email.dart';
import 'package:health_care/src/features/blog/blog_screen.dart';
import 'package:health_care/src/features/dashboard/doctor/doctor_dashboard.dart';
import 'package:health_care/src/features/dashboard/patient/patient_dashboard.dart';
import 'package:health_care/src/features/doctors/account/account.dart';
import 'package:health_care/src/features/doctors/appointments/appointments.dart';
import 'package:health_care/src/features/doctors/available_timing/doctors_available_timing.dart';
import 'package:health_care/src/features/doctors/billings/bill_add_widget.dart';
import 'package:health_care/src/features/doctors/billings/bill_edit_view_widget.dart';
import 'package:health_care/src/features/doctors/billings/doctors_billings.dart';
import 'package:health_care/src/features/doctors/booking/booking_page.dart';
import 'package:health_care/src/features/doctors/check-out/checkout.dart';
import 'package:health_care/src/features/doctors/dashboard_appointment/dash_appointment.dart';
import 'package:health_care/src/features/doctors/favourites/doctors_favourites.dart';
import 'package:health_care/src/features/doctors/invoice-view/invoice_view.dart';
import 'package:health_care/src/features/doctors/invoice/doctors_invoice.dart';
import 'package:health_care/src/features/doctors/my_patients/doctors_my_patients.dart';
import 'package:health_care/src/features/doctors/patient_profile/doctor_patient_profile_widget.dart';
import 'package:health_care/src/features/doctors/payment-success/payment_success.dart';
import 'package:health_care/src/features/doctors/prescriptions/prescription_edit_view_widget.dart';
import 'package:health_care/src/features/doctors/profile/doctors_search_profile.dart';
import 'package:health_care/src/features/doctors/reviews/doctors_reviews.dart';
import 'package:health_care/src/features/doctors/schedule/doctors_dashboard_schedule_timing.dart';
import 'package:health_care/src/features/doctors/search/doctor_search.dart';
import 'package:health_care/src/features/doctors/social_media_widget/social_media_widget.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/features/patients/appointments/patient_appointments.dart';
import 'package:health_care/src/features/patients/bill-view/bill_invoice.dart';
import 'package:health_care/src/features/patients/billings/patient_billings.dart';
import 'package:health_care/src/features/patients/check-out/bill_check_out.dart';
import 'package:health_care/src/features/patients/dependents/patients_dependents.dart';
import 'package:health_care/src/features/patients/favourites/patients_favourites.dart';
import 'package:health_care/src/features/patients/invoice/patient_invoice.dart';
import 'package:health_care/src/features/patients/medicalDetails/medical_details_widget.dart';
import 'package:health_care/src/features/patients/medicalDetails/single_medical_detail_widget.dart';
import 'package:health_care/src/features/patients/medicalRecords/patient_medical_records.dart';
import 'package:health_care/src/features/doctors/prescriptions/patient_prescriptions.dart';
import 'package:health_care/src/features/doctors/prescriptions/prescription_add_widget.dart';
import 'package:health_care/src/features/patients/payment-success/bill_payment_success.dart';
import 'package:health_care/src/features/patients/rates/patient_rates_widget.dart';
import 'package:health_care/src/features/patients/reviews/patient_reviews_widget.dart';
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
                return DashboardAppointments(
                  key: ValueKey(doctorProfile.userId),
                  isToday: false,
                );
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
                return DashboardAppointments(
                  key: ValueKey(doctorProfile.userId),
                  isToday: true,
                );
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
      path: '/doctors/dashboard/billings',
      name: 'doctorsBillings',
      builder: (context, state) {
        // Wrap the DoctorsInvoice widget with ChangeNotifierProvider
        return ChangeNotifierProvider(
          create: (context) => BillingProvider(),
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DoctorsBillings(key: ValueKey(doctorProfile.userId));
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
      path: '/doctors/dashboard/account',
      name: 'doctorsAccount',
      builder: (context, state) {
        // Wrap the DoctorsInvoice widget with ChangeNotifierProvider
        return ChangeNotifierProvider(
          create: (context) => BankProvider(),
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return Account(key: ValueKey(doctorProfile.userId));
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
      path: '/doctors/dashboard/reviews',
      name: 'doctorsReviews',
      builder: (context, state) {
        // Wrap the DoctorsInvoice widget with ChangeNotifierProvider
        return ChangeNotifierProvider(
          create: (context) => ReviewProvider(),
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final doctorProfile = authProvider.doctorsProfile;

              if (doctorProfile != null) {
                return DoctorsReviews(key: ValueKey(doctorProfile.userId));
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
      path: '/doctors/dashboard/socialMedia',
      name: 'socialMedia',
      builder: (context, state) {
        // return DoctorSearch(queryParameters: state.uri.queryParameters);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final doctorProfile = authProvider.doctorsProfile;

        if (doctorProfile != null) {
          return SocialMediaWidget(key: ValueKey(doctorProfile.userId));
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // Use innerContext here
              context.go('/');
            }
          });
          return const SizedBox.shrink();
        }
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
      path: '/doctors/dashboard/changePassword',
      name: 'changePassword',
      builder: (context, state) {
        // return DoctorSearch(queryParameters: state.uri.queryParameters);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final doctorProfile = authProvider.doctorsProfile;

        if (doctorProfile != null) {
          return ChangePassword(key: ValueKey(doctorProfile.userId));
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // Use innerContext here
              context.go('/');
            }
          });
          return const SizedBox.shrink();
        }
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
      path: '/doctors/dashboard/patient-profile/:encodedId',
      name: 'doctorsPatientProfile',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final mongoPatientUserId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (_) => DoctorPatientProfileProvider(),
          child: DoctorPatientProfileWidget(
            mongoPatientUserId: mongoPatientUserId,
          ),
        );
      },
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isLogin || authProvider.roleName != 'doctors' || authProvider.doctorsProfile == null) {
          return '/';
        }

        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';

        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/invoice-view/:encodedId',
      name: 'doctorsDashboardInvoiceView',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final reservationId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (context) => ReservationProvider(),
          child: Builder(
            builder: (innerContext) {
              return InvoiceView(reservationId: reservationId);
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        if (!isLogin) return '/';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    // doctor Bill view
    GoRoute(
      path: '/doctors/dashboard/bill-view/:encodedId',
      name: 'doctorsBillView',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final billingId = utf8.decode(base64.decode(encodedId));
        final encodedPatientId = state.uri.queryParameters['patientId'];
        final patientId = encodedPatientId != null ? utf8.decode(base64.decode(encodedPatientId)) : null;
        return ChangeNotifierProvider(
          create: (context) => BillProvider(),
          child: Builder(
            builder: (innerContext) {
              return BillInvoice(
                billingId: billingId,
                patientId: patientId,
              );
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),

    // patientDashoboard

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
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/appointments',
      name: 'patientAppointments',
      builder: (context, state) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => PatientAppointmentProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => WidgetInjectionProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => DoctorPatientProfileProvider(),
            )
          ],
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final patientProfile = authProvider.patientProfile;

              if (patientProfile != null) {
                return PatientAppointments(patientId: patientProfile.userId);
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
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/invoice',
      name: 'patientInvoices',
      builder: (context, state) {
        return ChangeNotifierProvider(create: (_) => PatientAppointmentProvider(), child: const PatientInvoice());
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/prescriptions',
      name: 'patientPrescriptions',
      builder: (context, state) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => PrescriptionProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => WidgetInjectionProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => DoctorPatientProfileProvider(),
            )
          ],
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final patientProfile = authProvider.patientProfile;

              if (patientProfile != null) {
                return PatientPrescriptions(patientId: patientProfile.userId);
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
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/see-prescription/:encodedId',
      name: 'patientSeePrescription',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final prescriptionMongoId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (_) => DoctorPatientProfileProvider(),
          child: PrescriptionEditViewWidget(
            prescriptionMongoId: prescriptionMongoId,
            viewType: 'view',
          ),
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/medicalRecords',
      name: 'patientMedicalRecords',
      builder: (context, state) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => MedicalRecordsProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => WidgetInjectionProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => DoctorPatientProfileProvider(),
            )
          ],
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final patientProfile = authProvider.patientProfile;

              if (patientProfile != null) {
                return PatientMedicalRecords(patientId: patientProfile.userId);
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
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/favourites',
      name: 'patientFavourites',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => FavouritesProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final patientProfile = authProvider.patientProfile;

              if (patientProfile != null) {
                return PatientsFavourites(key: ValueKey(patientProfile.userId));
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
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/dependent',
      name: 'patientDependent',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => DependentsProvider(), // InvoiceProvider is created ONLY when this route is built
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final patientProfile = authProvider.patientProfile;

              if (patientProfile != null) {
                return PatientsDependents(key: ValueKey(patientProfile.userId));
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
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/billings',
      name: 'patientBillings',
      builder: (context, state) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => BillingProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => WidgetInjectionProvider(),
            ),
          ],
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final patientProfile = authProvider.patientProfile;

              if (patientProfile != null) {
                return PatientBillings(patientId: patientProfile.userId);
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
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/review',
      name: 'patientReview',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => ReviewProvider(),
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final patientProfile = authProvider.patientProfile;

              if (patientProfile != null) {
                return const PatientReviewsWidget();
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
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/rates',
      name: 'patientRates',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => RateProvider(),
          child: Builder(
            // Using Builder to access the newly provided InvoiceProvider within the same build method
            builder: (innerContext) {
              // Use innerContext to get the InvoiceProvider from the local scope
              final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
              final patientProfile = authProvider.patientProfile;

              if (patientProfile != null) {
                return const PatientRatesWidget();
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
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/medicalDetails',
      name: 'patientMedicalDetails',
      builder: (context, state) {
        return Builder(
          // Using Builder to access the newly provided InvoiceProvider within the same build method
          builder: (innerContext) {
            // Use innerContext to get the InvoiceProvider from the local scope
            final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
            final patientProfile = authProvider.patientProfile;

            if (patientProfile != null) {
              return const MedicalDetailsWidget();
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
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    GoRoute(
      path: '/patient/dashboard/singleMedicalDetail',
      name: 'patientSingleMedicalDetail',
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        final title = state.uri.queryParameters['title'];
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';
        if (title == null || title.isEmpty) return '/patient/dashboard/medicalDetails';
        return null;
      },
      builder: (context, state) {
        return Builder(
          // Using Builder to access the newly provided InvoiceProvider within the same build method
          builder: (innerContext) {
            // Use innerContext to get the InvoiceProvider from the local scope
            final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
            final patientProfile = authProvider.patientProfile;
            final title = state.uri.queryParameters['title']!;
            if (patientProfile != null) {
              return SingleMedicalDetailWidget(title: title);
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
        );
      },
    ),
    GoRoute(
      path: '/patient/dashboard/changePassword',
      name: 'patientChangePassword',
      builder: (context, state) {
        return Builder(
          // Using Builder to access the newly provided InvoiceProvider within the same build method
          builder: (innerContext) {
            // Use innerContext to get the InvoiceProvider from the local scope
            final authProvider = Provider.of<AuthProvider>(innerContext, listen: false);
            final patientProfile = authProvider.patientProfile;

            if (patientProfile != null) {
              return ChangePassword(key: ValueKey(patientProfile.userId));
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
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),

    //Patient otherlinks
    GoRoute(
      path: '/patient/dashboard/see-billing/:encodedId',
      name: 'seeBillingPatient',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final billMongoId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (_) => DoctorPatientProfileProvider(),
          child: BillEditViewWidget(billMongoId: billMongoId, viewType: 'see', userType: 'patient'),
        );
      },
      redirect: (context, state) {
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        final patientProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
        if (!isLogin) return '/';
        if (roleName != 'patient') return '/';
        if (patientProfile == null) return '/';

        return null;
      },
    ),
    // /patient/dashboard/invoice-view/
    GoRoute(
      path: '/patient/dashboard/invoice-view/:encodedId',
      name: 'patientDashboardInvoiceView',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final reservationId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (context) => ReservationProvider(),
          child: Builder(
            builder: (innerContext) {
              return InvoiceView(reservationId: reservationId);
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        if (!isLogin) return '/';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    //Doctors otherLinks
    GoRoute(
      path: '/doctors/dashboard/add-prescription/:encodedId',
      name: 'addPrescription',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final mongoPatientUserId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (_) => DoctorPatientProfileProvider(),
          child: PrescriptionAddWidget(
            mongoPatientUserId: mongoPatientUserId,
            viewType: 'add',
          ),
        );
      },
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isLogin || authProvider.roleName != 'doctors' || authProvider.doctorsProfile == null) {
          return '/';
        }

        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';

        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/editprescription/:encodedId',
      name: 'editPrescription',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final prescriptionMongoId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (_) => DoctorPatientProfileProvider(),
          child: PrescriptionEditViewWidget(
            prescriptionMongoId: prescriptionMongoId,
            viewType: 'edit',
          ),
        );
      },
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isLogin || authProvider.roleName != 'doctors' || authProvider.doctorsProfile == null) {
          return '/';
        }

        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';

        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/add-billing/:encodedId',
      name: 'addBill',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final mongoPatientUserId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (_) => DoctorPatientProfileProvider(),
          child: BillAddWidget(
            mongoPatientUserId: mongoPatientUserId,
            viewType: 'add',
          ),
        );
      },
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isLogin || authProvider.roleName != 'doctors' || authProvider.doctorsProfile == null) {
          return '/';
        }

        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';

        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/edit-billing/:encodedId',
      name: 'editBilling',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final billMongoId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (_) => DoctorPatientProfileProvider(),
          child: BillEditViewWidget(billMongoId: billMongoId, viewType: 'edit', userType: 'doctors'),
        );
      },
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isLogin || authProvider.roleName != 'doctors' || authProvider.doctorsProfile == null) {
          return '/';
        }

        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';

        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    GoRoute(
      path: '/doctors/dashboard/see-billing/:encodedId',
      name: 'seeBilling',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final billMongoId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (_) => DoctorPatientProfileProvider(),
          child: BillEditViewWidget(billMongoId: billMongoId, viewType: 'see', userType: 'doctors'),
        );
      },
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isLogin || authProvider.roleName != 'doctors' || authProvider.doctorsProfile == null) {
          return '/';
        }

        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';

        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
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
      path: '/eyecarehome',
      name: 'eyecarehome',
      builder: (context, state) => const EyeCareHome(),
    ),

    //public links
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
      path: '/loading',
      name: 'loading',
      builder: (context, state) {
        return const LoadingScreen();
      },
    ),

    //  Authlinks
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
    ),

    //Doctors search and bookings link
    GoRoute(
      path: '/doctors/search',
      name: 'doctorsSearch',
      builder: (context, state) {
        return DoctorSearch(queryParameters: state.uri.queryParameters);
      },
    ),
    //Doctors profile
    GoRoute(
      path: '/doctors/profile/:encodedId',
      name: 'doctorsSearchProfile',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final doctorId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (context) => ReviewProvider(),
          child: Builder(
            builder: (innerContext) {
              return DoctorsSearchProfile(doctorId: doctorId);
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    //Doctors booking
    GoRoute(
      path: '/doctors/booking/:encodedId',
      name: 'doctorsBooking',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final doctorId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (context) => BookingInformationProvider(),
          child: Builder(
            builder: (innerContext) {
              return BookingPage(doctorId: doctorId);
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        // var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
        // var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        // if (!isLogin) return '/doctors/search';
        // if (roleName == 'doctors') return '/doctors/dashboard';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    //Doctors booking
    GoRoute(
      path: '/doctors/check-out/:encodedId',
      name: 'doctorsCheckout',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final occupyId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (context) => BookingInformationProvider(),
          child: Builder(
            builder: (innerContext) {
              return CheckOut(occupyId: occupyId);
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    // payment success doctors
    GoRoute(
      path: '/doctors/payment-success/:encodedId',
      name: 'doctorsPaymentSuccess',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final reservationId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (context) => ReservationProvider(),
          child: Builder(
            builder: (innerContext) {
              return PaymentSuccess(reservationId: reservationId);
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    // patient invoice view
    GoRoute(
      path: '/doctors/invoice-view/:encodedId',
      name: 'doctorsInvoiceView',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final reservationId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (context) => ReservationProvider(),
          child: Builder(
            builder: (innerContext) {
              return InvoiceView(reservationId: reservationId);
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    // patient Bill view
    GoRoute(
      path: '/patient/dashboard/bill-view/:encodedId',
      name: 'patientBillView',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final billingId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (context) => BillProvider(),
          child: Builder(
            builder: (innerContext) {
              return BillInvoice(billingId: billingId);
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    // patient Bill payment
    GoRoute(
      path: '/patient/check-out/:encodedId',
      name: 'patientBillCheckout',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final billingId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (context) => BillProvider(),
          child: Builder(
            builder: (innerContext) {
              return BillCheckOut(billingId: billingId);
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
    // patient Bill payment success
    GoRoute(
      path: '/patient/payment-success/:encodedId',
      name: 'patientBillSuccess',
      builder: (context, state) {
        final encodedId = state.pathParameters['encodedId']!;
        final billingId = utf8.decode(base64.decode(encodedId));

        return ChangeNotifierProvider(
          create: (context) => BillProvider(),
          child: Builder(
            builder: (innerContext) {
              return BillPaymentSuccess(billingId: billingId);
            },
          ),
        );
      },
      redirect: (context, state) {
        final encodedId = state.pathParameters['encodedId'];
        if (encodedId == null || encodedId.isEmpty) return '/';
        try {
          final decoded = utf8.decode(base64.decode(encodedId));
          if (decoded.isEmpty) return '/';
          return null;
        } catch (e) {
          return '/';
        }
      },
    ),
  ],
  errorBuilder: (context, state) {
    return const SafeArea(
      child: NotFound404Error(),
    );
  },
);
