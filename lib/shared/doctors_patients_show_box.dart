import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:timezone/timezone.dart' as tz;

class DoctorsPatientsShowBox extends StatefulWidget {
  final PatientUserProfile patientFavProfile;
  final VoidCallback getDataOnUpdate;
  const DoctorsPatientsShowBox({
    super.key,
    required this.patientFavProfile,
    required this.getDataOnUpdate,
  });

  @override
  State<DoctorsPatientsShowBox> createState() => _DoctorsPatientsShowBoxState();
}

class _DoctorsPatientsShowBoxState extends State<DoctorsPatientsShowBox> {
  @override
  Widget build(BuildContext context) {
    final PatientUserProfile patientProfile = widget.patientFavProfile;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
    final bangkok = tz.getLocation('Asia/Bangkok');
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
    final String gender = patientProfile.gender;
    final String patientName = "$gender${gender != '' ? '. ' : ''}${patientProfile.fullName}";
    final String profileImage = patientProfile.profileImage;
    final String? patientId = patientProfile.id;
    final LastLogin lastLogin = patientProfile.lastLogin;
    final DateTime lastLoginDate = lastLogin.date;
    final encodedId = base64.encode(utf8.encode(patientId.toString()));
    Color statusColor = patientProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : patientProfile.online
            ? const Color(0xFF44B700)
            : Colors.pinkAccent;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        color: theme.canvasColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        splashColor: theme.primaryColorLight,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        onTap: () {
                          context.push(
                            Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                          );
                        },
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: theme.primaryColorLight),
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: profileImage.isEmpty
                                  ? const AssetImage(
                                      'assets/images/default-avatar.png',
                                    ) as ImageProvider
                                  : CachedNetworkImageProvider(
                                      profileImage,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.primaryColor, width: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.push(
                                Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                              );
                            },
                            child: Text(
                              patientName,
                              style: TextStyle(
                                color: theme.primaryColorLight,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SortIconWidget(columnName: 'profile.fullName', getDataOnUpdate: widget.getDataOnUpdate)
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('#${patientProfile.patientsId}', style: TextStyle(color: theme.primaryColorLight)),
                          const SizedBox(width: 6),
                          SortIconWidget(columnName: 'profile.id', getDataOnUpdate: widget.getDataOnUpdate)
                        ],
                      ),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.clock, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text(context.tr('lastLogin'), style: const TextStyle(fontSize: 12)),
                          Text(
                            dateTimeFormat.format(tz.TZDateTime.from(lastLoginDate, bangkok)),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 6),
                          SortIconWidget(columnName: 'status.lastLogin.date', getDataOnUpdate: widget.getDataOnUpdate)
                        ],
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cake,
                        size: 14,
                        color: theme.primaryColorLight,
                      ),
                      const SizedBox(width: 3),
                      Text('${context.tr('dob')} :'),
                      Text(
                        " ${patientProfile.dob is String ? '---- -- --' : DateFormat("dd MMM yyyy").format(patientProfile.dob.toLocal())}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      SortIconWidget(columnName: 'profile.dob', getDataOnUpdate: widget.getDataOnUpdate)
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        bloodGValues.firstWhere(
                              (bg) => bg['title'] == patientProfile.bloodG,
                              orElse: () => {'icon': '❓'},
                            )['icon'] ??
                            '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 5),
                      Text('${context.tr('bloodG')} : '),
                      Text(patientProfile.bloodG),
                      const SizedBox(width: 6),
                      SortIconWidget(columnName: 'profile.bloodG', getDataOnUpdate: widget.getDataOnUpdate)
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.userClock,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text('${context.tr('age')} :'),
                      const SizedBox(width: 5),
                      Text(
                        "$years ${context.tr('years')}, $months ${context.tr('month')}, $days ${context.tr('days')}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                      const SizedBox(width: 5),
                      Text('${context.tr('city')} '),
                      Text(patientProfile.city == '' ? '---' : patientProfile.city),
                      const SizedBox(width: 6),
                      SortIconWidget(columnName: 'profile.city', getDataOnUpdate: widget.getDataOnUpdate)
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                      const SizedBox(width: 3),
                      Text('${context.tr('state')} '),
                      Text(patientProfile.state == '' ? '---' : patientProfile.state),
                      const SizedBox(width: 3),
                      SortIconWidget(columnName: 'profile.state', getDataOnUpdate: widget.getDataOnUpdate)
                    ],
                  ),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                      const SizedBox(width: 5),
                      Text('${context.tr('country')} '),
                      Text(patientProfile.country == '' ? '---' : patientProfile.country),
                      const SizedBox(width: 6),
                      SortIconWidget(columnName: 'profile.country', getDataOnUpdate: widget.getDataOnUpdate)
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    height: 40,
                    child: GradientButton(
                      onPressed: () {
                        context.push(
                          Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                        );
                      },
                      colors: [
                        Theme.of(context).primaryColorLight,
                        Theme.of(context).primaryColor,
                      ],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.eye, size: 13, color: textColor),
                          const SizedBox(width: 5),
                          Text(
                            context.tr("view"),
                            style: TextStyle(fontSize: 12, color: textColor),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

