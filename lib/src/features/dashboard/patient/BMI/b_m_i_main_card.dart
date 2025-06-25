import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/models/vital_signs.dart';
import 'package:health_care/src/features/dashboard/patient/BMI/b_m_i_screen.dart';
import 'package:pretty_gauge/pretty_gauge.dart';

class BMIMainCard extends StatelessWidget {
  const BMIMainCard({
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
    return Card(
      color: theme.canvasColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 5.0,
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(0),
      child: InkWell(
        splashColor: Theme.of(context).primaryColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BMIScreen(
                vitalSigns: vitalSigns,
                patientProfile: patientProfile,
              ),
            ),
          );
        },
        child: Column(
          children: [
            SizedBox(
              height: 45,
              child: ListTile(
                title: Center(
                  child: Text(
                    context.tr('bmiStatus'),
                  ),
                ),
              ),
            ),
            Expanded(
              // height: 100,
              child: PrettyGauge(
                gaugeSize: 210,
                minValue: 0,
                maxValue: 40,
                segments: [
                  GaugeSegment('UnderWeight', 18.5, Colors.red),
                  GaugeSegment('Normal', 6.4, Colors.green),
                  GaugeSegment('OverWeight', 5, Colors.orange),
                  GaugeSegment('Obese', 10.1, Colors.pink),
                ],
                valueWidget: const Text(
                  "",
                  style: TextStyle(fontSize: 40),
                ),
                currentValue: 0.5,
                needleColor: Theme.of(context).primaryColorLight,
                startMarkerStyle: const TextStyle(
                  fontSize: 10,
                ),
                endMarkerStyle: const TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 20),
                height: 50,
                width: 140,
                child: Center(
                  child: Text(
                    context.tr("bmi"),
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto_Condensed',
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
