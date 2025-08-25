import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide VerticalDivider;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/shared/patient_doctor_profile_header.dart';

class DoctorPateintProfileHeader extends StatefulWidget {
  final DoctorPatientProfileModel doctorPatientProfile;
  const DoctorPateintProfileHeader({super.key, required this.doctorPatientProfile});

  @override
  State<DoctorPateintProfileHeader> createState() => _DoctorPateintProfileHeaderState();
}

class _DoctorPateintProfileHeaderState extends State<DoctorPateintProfileHeader> {
  @override
  Widget build(BuildContext context) {
    final doctorPatientProfile = widget.doctorPatientProfile;
    final ThemeData theme = Theme.of(context);
    final Widget profileImageWidget = doctorPatientProfile.profileImage.isEmpty
        ? Image.asset('assets/images/default-avatar.png')
        : Image.network(doctorPatientProfile.profileImage);
    final Color statusColor = doctorPatientProfile.lastLogin.idle ?? false
        ? const Color(0xFFFFA812)
        : doctorPatientProfile.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);
    final String gender = doctorPatientProfile.gender;
    final String patientName = "$gender${gender != '' ? '. ' : ''}${doctorPatientProfile.fullName}";
    late String years = '--';
    late String months = '--';
    late String days = '--';
    if (doctorPatientProfile.dob is DateTime) {
      DateTime dob = doctorPatientProfile.dob;
      DateTime today = DateTime.now();
      DateTime b = DateTime(dob.year, dob.month, dob.day);
      int totalDays = today.difference(b).inDays;
      int y = totalDays ~/ 365;
      int m = (totalDays - y * 365) ~/ 30;
      int d = totalDays - y * 365 - m * 30;

      years = '$y';
      months = '$m';
      days = '$d';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      context.tr('patientIdHeader', args: ['#${doctorPatientProfile.patientsId}']),
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: theme.primaryColorLight),
                          left: BorderSide(color: theme.primaryColorLight),
                          right: BorderSide(color: theme.primaryColorLight),
                        ),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start, // important for vertical alignment
                          children: [
                            // Country Column
                            ProfileHeaderCellWidget(
                              iconWidget: Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Icon(
                                  Icons.cake,
                                  size: 18,
                                  color: theme.primaryColor,
                                ),
                              ),
                              titleWidget: Text(
                                '${context.tr('dob')}:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              mainTextWidget: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  doctorPatientProfile.dob is String
                                      ? '---- -- --'
                                      : DateFormat("dd MMM yyyy").format(
                                          doctorPatientProfile.dob.toLocal(),
                                        ),
                                ),
                              ),
                            ),
                            VerticalDivider(theme: theme),
                            // Speciality Column
                            ProfileHeaderCellWidget(
                              iconWidget: const SizedBox(width: 0),
                              titleWidget: Text(
                                '${context.tr('age')}:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              mainTextWidget: Text(
                                doctorPatientProfile.dob is String
                                    ? '---- -- --'
                                    : "$years ${context.tr('year')}, $months ${context.tr('monthFull')}, $days ${context.tr('daysFull')}",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: theme.primaryColorLight),
                          left: BorderSide(color: theme.primaryColorLight),
                          right: BorderSide(color: theme.primaryColorLight),
                        ),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start, // important for vertical alignment
                          children: [
                            // state Column
                            ProfileHeaderCellWidget(
                              iconWidget: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: FaIcon(FontAwesomeIcons.mapLocation, size: 13, color: theme.primaryColor),
                              ),
                              titleWidget: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  context.tr('city'),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              mainTextWidget: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: doctorPatientProfile.city.isEmpty ? '---' : doctorPatientProfile.city,
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                            VerticalDivider(theme: theme),
                            // city Column
                            ProfileHeaderCellWidget(
                              iconWidget: FaIcon(FontAwesomeIcons.mapLocation, size: 13, color: theme.primaryColor),
                              titleWidget: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  context.tr('state'),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              mainTextWidget: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: doctorPatientProfile.state.isEmpty ? '---' : doctorPatientProfile.state,
                                    ),
                                  ],
                                ),
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: theme.primaryColorLight),
                          bottom: BorderSide(color: theme.primaryColorLight),
                          left: BorderSide(color: theme.primaryColorLight),
                          right: BorderSide(color: theme.primaryColorLight),
                        ),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start, // important for vertical alignment
                          children: [
                            // Country Column
                            ProfileHeaderCellWidget(
                              iconWidget: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: FaIcon(FontAwesomeIcons.mapLocation, size: 13, color: theme.primaryColor),
                              ),
                              titleWidget: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  context.tr('country'),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              mainTextWidget: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: doctorPatientProfile.country.isEmpty ? '---' : doctorPatientProfile.country,
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                            VerticalDivider(theme: theme),
                            // Speciality Column
                            ProfileHeaderCellWidget(
                              iconWidget: Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Text(
                                  bloodGValues.firstWhere(
                                        (bg) => bg['title'] == doctorPatientProfile.bloodG,
                                        orElse: () => {'icon': '❓'},
                                      )['icon'] ??
                                      '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              titleWidget: Text(
                                '${context.tr('bloodG')}:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              mainTextWidget: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      doctorPatientProfile.bloodG,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: theme.primaryColorLight),
                          left: BorderSide(color: theme.primaryColorLight),
                          right: BorderSide(color: theme.primaryColorLight),
                        ),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start, // important for vertical alignment
                          children: [
                            // state Column
                            ProfileHeaderCellWidget(
                              iconWidget: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: FaIcon(FontAwesomeIcons.phone, size: 13, color: theme.primaryColor),
                              ),
                              titleWidget: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  context.tr('phone'),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              mainTextWidget: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: doctorPatientProfile.mobileNumber.isEmpty ? '---' : doctorPatientProfile.mobileNumber,
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                            VerticalDivider(theme: theme),
                            // city Column
                            ProfileHeaderCellWidget(
                              iconWidget: FaIcon(FontAwesomeIcons.envelope, size: 13, color: theme.primaryColor),
                              titleWidget: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  context.tr('userName'),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              mainTextWidget: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: doctorPatientProfile.userName,
                                    ),
                                  ],
                                ),
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            top: -75,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(child: profileImageWidget),
                ),
                Positioned(
                  top: 10,
                  right: MediaQuery.of(context).size.width / 2 - 75 + 20, // Aligns near top-right of avatar
                  child: AvatarGlow(
                    glowColor: statusColor,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primaryColor, width: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
