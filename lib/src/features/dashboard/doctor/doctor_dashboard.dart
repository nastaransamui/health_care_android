
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/shared/dashboard_link_card.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/dashboard/doctor/appointment_scroll_view.dart';
import 'package:health_care/src/features/dashboard/doctor/patients_scroll_view.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/appointment_service.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/shared/dashboard_main_card_under_header.dart';
import 'package:health_care/shared/patient_doctor_profile_header.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:provider/provider.dart';

class DoctorDashboard extends StatefulWidget {
  static const String routeName = '/doctors/dashboard';
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  final AppointmentService appointmentService = AppointmentService();
  late AppointmentProvider appointmentProvider;
  late AuthProvider authProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  void getDataOnUpdate() async {
    await appointmentService.getDocDashAppointments(context, false);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose(); // Always call super.dispose() at the end.
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AppointmentProvider>(
      builder: (context, authProvider, vitalProvider, child) {
        if (authProvider.doctorsProfile == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.push('/');
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final DoctorUserProfile doctorProfile = authProvider.doctorsProfile!.userProfile;
        final ThemeData theme = Theme.of(context);
        return ScaffoldWrapper(
          title: context.tr('doctorDashboard'),
          children: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  double per = 0;
                  if (scrollController.hasClients) {
                    per = ((scrollController.offset / scrollController.position.maxScrollExtent));
                  }
                  if (per >= 0) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        setState(() {
                          scrollPercentage = 307 * per;
                        });
                      }
                    });
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      PatientDoctorProfileHeader(doctorUserProfile: doctorProfile),
                      DashboardMainCardUnderHeader(
                        children: [
                          ListTile(
                            title: Text(context.tr('patientsData')),
                          ),
                          PatientsScrollView(
                            doctorProfile: doctorProfile,
                            appointmentProvider: appointmentProvider,
                          ),
                          ListTile(
                            title: Text(context.tr('informations')),
                          ),
                          const AppointmentScrollView(),
                          ListTile(
                            title: Text(context.tr('links')),
                          ),
                          ...doctorsDashboardLink.where((item) {
                            // Hide 'changePassword' if services (e.g. Google login) is present
                            if (item['name'] == 'changePassword' && doctorProfile.services == "google") {
                              return false;
                            }
                            return true;
                          }).map(
                            (i) {
                              final element = i;
                              return DashboardLinkCard(theme: theme, element: element);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
            ],
          ),
        );
      },
    );
  }
}
