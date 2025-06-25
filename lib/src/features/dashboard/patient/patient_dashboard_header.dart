import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/users.dart';

class PatientDashboardHeader extends StatefulWidget {
  final PatientUserProfile patientProfile;
  const PatientDashboardHeader({
    super.key,
    required this.patientProfile,
  });

  @override
  State<PatientDashboardHeader> createState() => _PatientDashboardHeaderState();
}

class _PatientDashboardHeaderState extends State<PatientDashboardHeader> {
  @override
  Widget build(BuildContext context) {
    final PatientUserProfile patientProfile = widget.patientProfile;
    final ThemeData theme = Theme.of(context);
    final Widget profileImageWidget =
        patientProfile.profileImage.isEmpty ? Image.asset('assets/images/default-avatar.png') : Image.network(patientProfile.profileImage);
    final String gender = patientProfile.gender;
    final String patientName = "$gender${gender != '' ? '. ' : ''}${patientProfile.fullName}";
    late String years = '--';
    late String months = '--';
    late String days = '--';
    if (patientProfile.dob is DateTime) {
      DateTime dob = patientProfile.dob;
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
                      context.tr('patientIdHeader', args: ['#${patientProfile.patientsId}']),
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cake,
                              size: 18,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              " ${patientProfile.dob is String ? '---- -- --' : DateFormat("dd MMM yyyy").format(patientProfile.dob.toLocal())}",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        Text(
                          "$years ${context.tr('year')}, $months ${context.tr('monthFull')}, $days ${context.tr('daysFull')}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColor),
                            const SizedBox(width: 5),
                            Text('${context.tr('city')} '),
                            Text(patientProfile.city == '' ? '---' : patientProfile.city),
                          ],
                        ),
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColor),
                            const SizedBox(width: 5),
                            Text('${context.tr('state')} '),
                            Text(patientProfile.state == '' ? '---' : patientProfile.state),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColor),
                            const SizedBox(width: 5),
                            Text('${context.tr('country')} '),
                            Text(patientProfile.country == '' ? '---' : patientProfile.country),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FaIcon(FontAwesomeIcons.phone, size: 13, color: theme.primaryColor),
                        const SizedBox(width: 5),
                        Text('${context.tr('mobileNumber')} '),
                        Text(patientProfile.mobileNumber == '' ? '---' : patientProfile.mobileNumber),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    Divider(
                      color: theme.primaryColor,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
