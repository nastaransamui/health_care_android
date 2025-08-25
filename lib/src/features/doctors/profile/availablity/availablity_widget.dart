import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/star_review_widget.dart';
import 'package:health_care/src/features/doctors/profile/availablity/availablity_time_show.dart';
import 'package:health_care/src/features/doctors/search/doctor_card.dart';

class AvailablityWidget extends StatelessWidget {
  const AvailablityWidget({
    super.key,
    required this.doctorUserProfile,
  });

  final DoctorUserProfile doctorUserProfile;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    double doctorStarRate = doctorUserProfile.rateArray.isEmpty
        ? 0
        : doctorUserProfile.rateArray.reduce((acc, number) => acc + number) / doctorUserProfile.rateArray.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: -4),
          title: Text("${context.tr('clinicName')}: "),
        ),
        Text(
          doctorUserProfile.clinicName.isEmpty ? '--' : doctorUserProfile.clinicName,
          style: TextStyle(
            color: theme.primaryColorLight,
            fontSize: 20,
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: -4),
          title: Text("${context.tr('speciality')}: "),
        ),
        Text(
          doctorUserProfile.specialities.first.description,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            StarReviewWidget(
              rate: doctorStarRate,
              textColor: textColor,
              starSize: 12,
            ),
            const SizedBox(width: 10),
            Text(
              "(${doctorUserProfile.recommendArray.length} ${context.tr('votes')})",
            )
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            FaIcon(FontAwesomeIcons.mapLocationDot, size: 12, color: Theme.of(context).primaryColor),
            const SizedBox(width: 5),
            Text(
              doctorUserProfile.clinicAddress.isEmpty ? '--' : doctorUserProfile.clinicAddress,
            ),
          ],
        ),
        const SizedBox(height: 15),
        ClinicImagesWidget(clinicImages: doctorUserProfile.clinicImages),
        const SizedBox(height: 15),
        AvailablityTimeShow(doctorUserProfile: doctorUserProfile),
      ],
    );
  }
}
