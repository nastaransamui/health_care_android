import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FourCardPateintDoctorLottie extends StatefulWidget {
  const FourCardPateintDoctorLottie({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<FourCardPateintDoctorLottie> createState() => _FourCardPateintDoctorLottieState();
}

class _FourCardPateintDoctorLottieState extends State<FourCardPateintDoctorLottie> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final String lottieAsset = widget.title == 'drPatientappointment'
        ? "assets/images/doctorPatientProfileAppointment.json"
        : widget.title == 'drPatientprescription'
            ? "assets/images/doctorPatientProfilePrescription.json"
            : widget.title == 'drPatientmedicalRecord'
                ? 'assets/images/doctorPatientProfileMedicalRecord.json'
                : 'assets/images/doctorPatientProfileBill.json';
    Color lighten(Color color, [double amount = 0.2]) {
      final hsl = HSLColor.fromColor(color);
      final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
      return hslLight.toColor();
    }

    Color darken(Color color, [double amount = 0.1]) {
      final hsl = HSLColor.fromColor(color);
      final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
      return hslDark.toColor();
    }

    LottieDelegates drPatientappointmentDeligates = LottieDelegates(values: [
      ValueDelegate.colorFilter(
        ['Cyan Solid 1', '**'],
        value: ColorFilter.mode(
          theme.brightness == Brightness.dark ? Colors.black87 : Colors.white70,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 21', "Group 1", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 21', "Group 2", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColorLight, 0.3),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 21', "Group 3", '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 21', "Group 4", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 21', "Group 5", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 19', '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 18', '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 10', "Group 2", '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 9', "Group 3", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 9', "Group 4", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 9', "Group 7", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 9', "Group 8", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 9', "Group 9", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 9', "Group 10", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColorLight, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 8', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 7', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 6', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 5', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 3', "Group 1", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 3', "Group 2", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 3', "Group 3", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 3', "Group 4", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 3', "Group 5", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 3', "Group 6", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 4', "Group 1", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 4', "Group 2", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 4', "Group 3", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Appointment booking Lottie JSON animation', 'OBJECTS 2', '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
    ]);
    LottieDelegates drPatientprescriptionDeligates = LottieDelegates(values: [
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 17', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 16', '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 15', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 14', '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 13', "Group 2", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 12', '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 11', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 7', 'Group 8', '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 7', 'Group 9', '**'],
        value: ColorFilter.mode(
          theme.disabledColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 9', "Group 2", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Pre-comp 1', 'Layer 18', "Group 2", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Logo', 'Group 1', '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['head', "Group 1", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.color(
        ['Layer 6', 'Group 5', 'Group 1', 'Group 1', '**'],
        value: textColor,
      ),
      ValueDelegate.color(
        ['Layer 6', 'Group 5', 'Group 1', 'Group 2', '**'],
        value: lighten(theme.primaryColorLight, 0.3),
      ),
      ValueDelegate.color(
        ['Layer 6', 'Group 5', 'Group 2', '**'],
        value: theme.primaryColorLight,
      ),
      ValueDelegate.color(
        ['Layer 6', 'Group 5', 'Group 3', '**'],
        value: darken(theme.primaryColorLight, 0.2),
      ),
      ValueDelegate.colorFilter(
        ["Layer 8", "Group 6", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.3),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ["Layer 8", "Group 11", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ["Layer 8", "Group 12", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ["Layer 8", "Group 13", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Hand 1-a', '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.3),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 5', "Group 1", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 5', "Group 2", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 5', "Group 12", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.3),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 5', "Group 14", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 5', "Group 16", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 5', "Group 17", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 5', "Group 18", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.3),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 4', '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColorLight, 0.3),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 3', '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColorLight, 0.3),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 2', '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColorLight, 0.3),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Layer 1', '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColorLight, 0.3),
          BlendMode.src,
        ),
      ),
    ]);
    LottieDelegates drPatientmedicalRecordDeligates = LottieDelegates(values: [
      ValueDelegate.colorFilter(
        ['L_Hand Outlines', "Group 3", '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Head Outlines', "Group 3", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Head Outlines', "Group 4", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Head Outlines', "Group 5", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Head Outlines', "Group 6", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Head Outlines', "Group 7", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Body Outlines', "Group 1", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.4),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Body Outlines', "Group 2", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.4),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Body Outlines', "Group 6", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Body Outlines', "Group 8", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Body Outlines', "Group 9", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines", "Group 51", '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines", "Group 102", '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines", "Group 103", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines", "Group 104", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines", "Group 105", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines", "Group 106", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines", "Group 107", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines", "Group 108", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines", "Group 1", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines", "Group 2", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines", "Group 3", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines", "Group 4", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines", "Group 5", '**'],
        value: const ColorFilter.mode(
          Colors.pink,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines", "Group 6", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines", "Group 7", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 2", "Group 51", '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 2", "Group 102", '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 2", "Group 103", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 2", "Group 104", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 2", "Group 105", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 2", "Group 106", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 2", "Group 107", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 2", "Group 108", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 2", "Group 1", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 2", "Group 2", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 2", "Group 3", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 2", "Group 4", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 2", "Group 5", '**'],
        value: const ColorFilter.mode(
          Colors.pink,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 2", "Group 6", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 2", "Group 7", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 3", "Group 51", '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 3", "Group 102", '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 3", "Group 103", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 3", "Group 104", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 3", "Group 105", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 3", "Group 106", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 3", "Group 107", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Doctor text Outlines 3", "Group 108", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 3", "Group 1", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 3", "Group 2", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 3", "Group 3", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 3", "Group 4", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 3", "Group 5", '**'],
        value: const ColorFilter.mode(
          Colors.pink,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 3", "Group 6", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Texts', "Love text Outlines 3", "Group 7", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['cahat box Outlines', "Group 1", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['stethoscope Outlines', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Circle Outlines 6', "Group 3", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColorLight, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['DNA Outlines', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Circle Outlines 2', "Group 3", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColorLight, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Heart Outlines', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Circle Outlines 3', "Group 3", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColorLight, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Tablet Outlines', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Circle Outlines', "Group 3", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColorLight, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Briefcase Outlines', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Circle Outlines 4', "Group 3", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColorLight, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Injection Outlines', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Circle Outlines 5', "Group 3", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColorLight, 0.2),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ["Hand Outlines", "Group 15", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ["Hand Outlines", "Group 14", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ["Hand Outlines", "Group 13", '**'],
        value: ColorFilter.mode(
          darken(theme.primaryColor, 0.1),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ["Hand Outlines", "Group 11", '**'],
        value: ColorFilter.mode(
          theme.canvasColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ["Pre-comp 1", '**'],
        value: ColorFilter.mode(
          lighten(theme.primaryColor, 0.6),
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ["Circle 2 Outlines", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
    ]);
    LottieDelegates doctorPatientProfileBillDeligates = LottieDelegates(values: [
      ValueDelegate.colorFilter(
        ['Check_Icon 2', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Shape Layer 7', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['Shape Layer 6', '**'],
        value: ColorFilter.mode(
          theme.primaryColorLight,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['HAnd_Mobile', "Mobile", "Group 1", "Group 1", '**'],
        value: ColorFilter.mode(
          textColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ['HAnd_Mobile', "Mobile", "Group 1", "Group 2", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
      ValueDelegate.colorFilter(
        ["Debit card", "Back", '**'],
        value: ColorFilter.mode(
          theme.primaryColor,
          BlendMode.src,
        ),
      ),
    ]);
    LottieDelegates wholeDeligate = widget.title == 'drPatientappointment'
        ? drPatientappointmentDeligates
        : widget.title == 'drPatientprescription'
            ? drPatientprescriptionDeligates
            : widget.title == 'drPatientmedicalRecord'
                ? drPatientmedicalRecordDeligates
                : doctorPatientProfileBillDeligates;
    return Lottie.asset(
      lottieAsset,
      animate: true,
      delegates: wholeDeligate,
      fit: BoxFit.contain,
    );
  }
}
