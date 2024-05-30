import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:provider/provider.dart';

class PatientDashboard extends StatefulWidget {
  static const String routeName = '/patient_dashboard';
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    // authService.updateLiveAuth(context);
  }

  @override
  void dispose() {
    super.dispose(); // Always call super.dispose() at the end.
  }

  @override
  Widget build(BuildContext context) {
    // var isLogin = Provider.of<AuthProvider>(context).isLogin;
    var patientProfile = Provider.of<AuthProvider>(context).patientProfile;
    // var doctorsProfile = Provider.of<AuthProvider>(context).doctorsProfile;
    // var roleName = Provider.of<AuthProvider>(context).roleName;

    // debugPrint('$patientProfile,');
    // if (!isLogin || patientProfile == null) {
    //    Navigator.pushNamed(context, '/');
    // }

    return ScaffoldWrapper(
      title: context.tr('patient_dashboard'),
      children: SingleChildScrollView(
        child: Text(patientProfile.toString()),
      ),
    );
  }
}
