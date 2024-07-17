import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class DoctorsSearchProfile extends StatefulWidget {
  final Map<String, String> pathParameters;
  const DoctorsSearchProfile({
    super.key,
    required this.pathParameters,
  });

  @override
  State<DoctorsSearchProfile> createState() => _DoctorsSearchProfileState();
}

class _DoctorsSearchProfileState extends State<DoctorsSearchProfile> {
  final DoctorsService doctorsService = DoctorsService();
  String? doctorId;
  DoctorUserProfile? doctor;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    doctor = Provider.of<DoctorsProvider>(context).singleDoctor;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr('goBack'),
          ),
        ),
        bottomNavigationBar: const BottomBar(
          showLogin: true,
        ),
        //Remove this center
        body: Center(
          child: SingleChildScrollView(
            child: AnimatedCrossFade(
              firstChild: SizedBox(
                height: 150,
                width: 150,
                child: LoadingIndicator(
                    indicatorType: Indicator.ballRotateChase,
                    colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
                    strokeWidth: 2.0,
                    pathBackgroundColor: null),
              ),
              secondChild: SingleChildScrollView(
                child: Text('$doctor'),
              ),
              crossFadeState: doctor == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 1000),
            ),
          ),
        ),
      ),
    );
  }
}
