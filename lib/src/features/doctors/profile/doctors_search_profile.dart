import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/shared/dashboard_main_card_under_header.dart';
import 'package:health_care/shared/patient_doctor_profile_header.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class DoctorsSearchProfile extends StatefulWidget {
  static const String routeName = '/doctors/profile';
  final String doctorId;
  const DoctorsSearchProfile({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorsSearchProfile> createState() => _DoctorsSearchProfileState();
}

class _DoctorsSearchProfileState extends State<DoctorsSearchProfile> {
  final DoctorsService doctorsService = DoctorsService();
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  late final DoctorsProvider doctorsProvider;
  late final AuthProvider authProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  bool _hasRedirected = false;
  bool isLoading = true;

  Future<void> getDataOnUpdate() async {
    await doctorsService.findUserById(
      context,
      widget.doctorId,
      () {
        if (context.mounted) {
          setState(() => isLoading = false);
        }
      },
    );
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
      doctorsProvider = Provider.of<DoctorsProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('findUserByIdReturn');
    socket.off('updateFindUserById');
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorsProvider>(
      builder: (context, doctorsProvider, child) {
        final DoctorUserProfile? doctorUserProfile = doctorsProvider.singleDoctor;
        if (isLoading) {
          return ScaffoldWrapper(
            title: context.tr('doctorsProfile'),
            children: const Center(child: CircularProgressIndicator()),
          );
        }
        //Redirect if id is empty
        if ((doctorUserProfile!.id?.isEmpty ?? true) && !_hasRedirected) {
          _hasRedirected = true;
          Future.microtask(() {
            if (context.mounted) {
              context.push('/doctors/search');
            }
          });
        }
        return ScaffoldWrapper(
          title: 'Dr. ${doctorUserProfile.fullName}',
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
                        PatientDoctorProfileHeader(doctorUserProfile: doctorUserProfile),
                        DashboardMainCardUnderHeader(
                          children: [
                            Text('$doctorUserProfile'),
                          ],
                        ),
                      ],
                    ),
                  )),
              ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
            ],
          ),
        );
      },
    );
  }
}
