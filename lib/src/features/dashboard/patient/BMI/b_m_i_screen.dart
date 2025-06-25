import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/models/vital_signs.dart';
import 'package:health_care/src/features/dashboard/patient/BMI/gender_widget.dart';
import 'package:health_care/src/features/dashboard/patient/BMI/score_screen.dart';
import 'package:health_care/src/features/dashboard/patient/BMI/slider_widget.dart';
import 'package:jiffy/jiffy.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class BMIScreen extends StatefulWidget {
  final VitalSigns? vitalSigns;
  final PatientUserProfile patientProfile;
  // final int age;
  // final String gender;
  const BMIScreen({
    super.key,
    required this.vitalSigns,
    required this.patientProfile,
    // required this.age,
    // required this.gender,
  });

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  int _gender = 0;
  int _height = 30;
  int _age = 1;
  int _weight = 3;
  bool _isFinished = false;
  double _bmiScore = 0;

  void calculateBmi() {
    _bmiScore = _weight / pow(_height / 100, 2);
  }

  @override
  Widget build(BuildContext context) {
    final PatientUserProfile patientProfile = widget.patientProfile;
    late String years = '--';

    DateTime? birthDate;

    if (patientProfile.dob is DateTime) {
      // If dob is already a DateTime object
      birthDate = patientProfile.dob as DateTime;
    } else if (patientProfile.dob is String && patientProfile.dob.isNotEmpty) {
      // If dob is a non-empty string, try to parse it
      try {
        // Assuming the string format is parsable by Jiffy, like "yyyy-MM-ddTHH:mm:ssZ"
        birthDate = Jiffy.parse(patientProfile.dob as String).dateTime;
        // ignore: empty_catches
      } catch (e) {}
    }

    if (birthDate != null) {
      DateTime today = DateTime.now();
      // Use the actual birthDate directly for calculation
      int totalDays = today.difference(birthDate).inDays;

      // Basic calculation for years, months, days.
      // Note: This is an approximation as months have different lengths.
      // For precise age, consider using a date utility package or more complex logic.
      int y = totalDays ~/ 365;

      years = '$y';
    }

    var vitalSigns = widget.vitalSigns;
    _age = years == '--' ? 1 : int.parse(years);
    if (vitalSigns != null) {
      dynamic vitalMap;
      vitalMap = vitalSigns.toMap();

      if (vitalMap['height'].length > 0) {
        var heightFromVital = vitalMap['height'][vitalMap['height'].length - 1]['value'];
        _height = heightFromVital;
      }
      if (vitalMap['weight'].length > 0) {
        var weightFromVital = vitalMap['weight'][vitalMap['weight'].length - 1]['value'];
        _weight = weightFromVital;
      }
    }
    if (_gender == 0) {
      _gender = widget.patientProfile.gender == 'Mr' ? 1 : 2;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(context.tr('bmiCalculator')),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColor),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  GenderWidget(
                    onChange: (genderVal) {
                      _gender = genderVal;
                    },
                    gender: _gender,
                  ),
                  SliderWidget(
                    value: _height,
                    name: "height",
                    unit: 'cm',
                    min: 20,
                    max: 240,
                    onChange: (heightVal) {
                      _height = heightVal;
                    },
                  ),
                  SliderWidget(
                    value: _age,
                    name: "age",
                    unit: 'years',
                    min: 1,
                    max: 110,
                    onChange: (ageVal) {
                      _age = ageVal;
                    },
                  ),
                  SliderWidget(
                    value: _weight,
                    name: "weight",
                    unit: 'Kg',
                    min: 3.0,
                    max: 240.0,
                    onChange: (weightVal) {
                      _weight = weightVal;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    child: SwipeableButtonView(
                      isFinished: _isFinished,
                      onFinish: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                              child: ScoreScreen(
                                bmiScore: _bmiScore,
                                age: _age,
                              ),
                              type: PageTransitionType.fade),
                        );

                        setState(() {
                          _isFinished = false;
                        });
                      },
                      onWaitingProcess: () {
                        //Calculate BMI here
                        calculateBmi();

                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _isFinished = true;
                          });
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                      buttonWidget: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.black,
                      ),
                      buttonText: context.tr('calculate'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        // bottomNavigationBar: const BottomBar(showLogin: true)),
      ),
    );
  }
}
