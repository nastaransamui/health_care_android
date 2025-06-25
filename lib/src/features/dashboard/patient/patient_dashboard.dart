import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/models/vital_signs.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/vital_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/vital_service.dart';
import 'package:health_care/shared/dashboard_link_card.dart';
import 'package:health_care/shared/dashboard_main_card_under_header.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/dashboard/patient/BMI/bmi_container.dart';
import 'package:health_care/src/features/dashboard/patient/information_scroll_view.dart';
import 'package:health_care/src/features/dashboard/patient/patient_dashboard_header.dart';
import 'package:health_care/src/features/dashboard/patient/vital_sign_scroll_view.dart';
import 'package:provider/provider.dart';

class PatientDashboard extends StatefulWidget {
  static const String routeName = '/patient/dashboard';
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final AuthService authService = AuthService();
  final VitalService vitalService = VitalService();
  final ScrollController scrollController = ScrollController();
  late final AuthProvider authProvider;
  late final VitalProvider vitalProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate(context) async {
    await authService.updateLiveAuth(context);
    vitalService.getVitalSignsData(context);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      vitalProvider = Provider.of<VitalProvider>(context, listen: false);
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
    return Consumer2<AuthProvider, VitalProvider>(
      builder: (context, authProvider, vitalProvider, child) {
        if (authProvider.patientProfile == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.push('/');
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final PatientUserProfile patientProfile = authProvider.patientProfile!.userProfile;

        final String userId = authProvider.patientProfile!.userId;
        final VitalSigns? vitalSigns = vitalProvider.vitalSign;
        final ThemeData theme = Theme.of(context);
        return ScaffoldWrapper(
          key: const Key('patientDashboard'),
          title: context.tr('patientDashboard'),
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
                      PatientDashboardHeader(patientProfile: patientProfile),
                      DashboardMainCardUnderHeader(
                        children: [
                          //Vital title
                          ListTile(
                            title: Text(context.tr('vitalSigns')),
                          ),
                          // VitalScrollView
                          VitalSignScrollView(userId: userId, vitalSigns: vitalSigns),
                          // BMI title
                          ListTile(
                            title: Text(context.tr('bmiStatus')),
                          ),
                          // BMI Card
                          BMIContainer(theme: theme, vitalSigns: vitalSigns, patientProfile: patientProfile),
                          // Information title
                          ListTile(
                            title: Text(context.tr('informations')),
                          ),
                          // InfomationScrollview
                          InformationScrollView(theme: theme),
                          // Link title
                          ListTile(
                            title: Text(context.tr('links')),
                          ),
                          // Link Cards
                          ...patientsDashboardLink.where((item) {
                            // Hide 'changePassword' if services (e.g. Google login) is present
                            if (item['name'] == 'changePassword' && patientProfile.services == "google") {
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
