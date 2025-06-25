
import 'package:flutter/material.dart';

import 'package:health_care/models/users.dart';
import 'package:health_care/models/vital_signs.dart';
import 'package:health_care/src/features/dashboard/patient/BMI/b_m_i_main_card.dart';


class BMIContainer extends StatelessWidget {
  const BMIContainer({
    super.key,
    required this.theme,
    required this.vitalSigns,
    required this.patientProfile,
  });

  final ThemeData theme;
  final VitalSigns? vitalSigns;
  final PatientUserProfile patientProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: BMIMainCard(theme: theme, vitalSigns: vitalSigns, patientProfile: patientProfile),
    );
  }
}
