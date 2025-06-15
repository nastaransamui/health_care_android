import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';

class DcoctorPateintProfileHeader extends StatefulWidget {
  final DoctorPatientProfileModel doctorPatientProfile;
  const DcoctorPateintProfileHeader({super.key, required this.doctorPatientProfile});

  @override
  State<DcoctorPateintProfileHeader> createState() => _DcoctorPateintProfileHeaderState();
}

class _DcoctorPateintProfileHeaderState extends State<DcoctorPateintProfileHeader> {
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
                      // 'PatientID : #${doctorPatientProfile.patientsId}',
                      context.tr('patientIdHeader', args: ['#${doctorPatientProfile.patientsId}']),
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
                              " ${doctorPatientProfile.dob is String ? '---- -- --' : DateFormat("dd MMM yyyy").format(doctorPatientProfile.dob.toLocal())}",
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
                            Text(doctorPatientProfile.city == '' ? '---' : doctorPatientProfile.city),
                          ],
                        ),
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColor),
                            const SizedBox(width: 5),
                            Text('${context.tr('state')} '),
                            Text(doctorPatientProfile.state == '' ? '---' : doctorPatientProfile.state),
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
                            Text(doctorPatientProfile.country == '' ? '---' : doctorPatientProfile.country),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              bloodGValues.firstWhere(
                                    (bg) => bg['title'] == doctorPatientProfile.bloodG,
                                    orElse: () => {'icon': '❓'},
                                  )['icon'] ??
                                  '',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 5),
                            Text('${context.tr('bloodG')} : '),
                            Text(doctorPatientProfile.bloodG),
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
                        Text(doctorPatientProfile.mobileNumber == '' ? '---' : doctorPatientProfile.mobileNumber),
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
                Positioned(
                  top: 10,
                  right: MediaQuery.of(context).size.width / 2 - 75 + 20, // Aligns near top-right of avatar
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
