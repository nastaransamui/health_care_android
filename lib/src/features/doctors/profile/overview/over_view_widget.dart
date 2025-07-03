import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/src/features/doctors/profile/overview/award_map_widget.dart';
import 'package:health_care/src/features/doctors/profile/overview/education_map_widget.dart';
import 'package:health_care/src/features/doctors/profile/overview/experince_map_widget.dart';
import 'package:health_care/src/features/doctors/profile/overview/member_ships_map_widget.dart';
import 'package:health_care/src/features/doctors/profile/overview/registration_map_widget.dart';
import 'package:health_care/src/features/doctors/profile/overview/services_map_widget.dart';

class OverViewWidget extends StatelessWidget {
  const OverViewWidget({
    super.key,
    required this.doctorUserProfile,
  });

  final DoctorUserProfile doctorUserProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: -4),
          title: Text("${context.tr('aboutMe')}: "),
        ),
        Text(
          doctorUserProfile.aboutMe,
          textAlign: TextAlign.justify,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: 0),
          title: Text('${context.tr('educations')}:'),
        ),
        EducationMapWidget(doctorUserProfile: doctorUserProfile),
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: 0),
          title: Text('${context.tr('workAndExperince')}:'),
        ),
        ExperinceMapWidget(doctorUserProfile: doctorUserProfile),
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: 0),
          title: Text('${context.tr('awards')}:'),
        ),
        AwardMapWidget(doctorUserProfile: doctorUserProfile),
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: 0),
          title: Text('${context.tr('registration')}:'),
        ),
        RegistrationMapWidget(doctorUserProfile: doctorUserProfile),
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: 0),
          title: Text('${context.tr('memberships')}:'),
        ),
        MemberShipsMapWidget(doctorUserProfile: doctorUserProfile),
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: 0),
          title: Text('${context.tr('services')}:'),
        ),
        ServicesMapWidget(doctorUserProfile: doctorUserProfile),
      ],
    );
  }
}