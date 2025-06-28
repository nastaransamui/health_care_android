import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/doctor_patient_profile_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/doctor_pateint_profile_service.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/patient_profile/doctor_pateint_profile_header.dart';
import 'package:health_care/src/features/doctors/patient_profile/four_card_doctor_patient_profile.dart';
import 'package:health_care/src/features/doctors/patient_profile/last_two_appointment_patient_profile.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class DoctorPatientProfileWidget extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/patient-profile';
  final String mongoPatientUserId;
  const DoctorPatientProfileWidget({
    super.key,
    required this.mongoPatientUserId,
  });

  @override
  State<DoctorPatientProfileWidget> createState() => _DoctorPatientProfileWidgetState();
}

class _DoctorPatientProfileWidgetState extends State<DoctorPatientProfileWidget> {
  Map<String, dynamic>? rawDoctorPatientProfile;
  bool isLoading = true;
  String? error;
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  final DoctorPateintProfileService doctorPateintProfileService = DoctorPateintProfileService();
  late final AuthProvider authProvider;
  late final DoctorPatientProfileProvider doctorPatientProfileProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  bool _hasRedirected = false;

  Future<void> getDataOnUpdate() async {
    doctorPateintProfileService.findDocterPatientProfileById(context, widget.mongoPatientUserId);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    getDataOnUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      doctorPatientProfileProvider = Provider.of<DoctorPatientProfileProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    socket.off('findDocterPatientProfileByIdReturn');
    socket.off('updatefindDocterPatientProfileById');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorPatientProfileProvider>(
      builder: (context, doctorPatientProfileProvider, child) {
        final DoctorPatientProfileModel doctorPatientProfile = doctorPatientProfileProvider.patientProfile;
        final bool isLoading = doctorPatientProfileProvider.isLoading;
        final ThemeData theme = Theme.of(context);
        if (isLoading) {
          return ScaffoldWrapper(title: context.tr('patientProfile'), children: const Center(child: CircularProgressIndicator()));
        }
        //Redirect if id is empty
        if ((doctorPatientProfile.id?.isEmpty ?? true) && !_hasRedirected) {
          _hasRedirected = true;
          Future.microtask(() {
            if (context.mounted) {
              context.push('/doctors/dashboard');
            }
          });
        }
        return ScaffoldWrapper(
          title: context.tr('patientProfile'),
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
                      FadeinWidget(
                        isCenter: true,
                        child: DoctorPateintProfileHeader(doctorPatientProfile: doctorPatientProfile),
                      ),
                      FadeinWidget(
                        isCenter: true,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0.0),
                                topRight: Radius.circular(0.0),
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: [
                                  LastTwoAppointmentPatientProfile(doctorPatientProfile: doctorPatientProfile, theme: theme),
                                  FourCardDoctorPatientProfile(
                                    doctorPatientProfile: doctorPatientProfile,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
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
