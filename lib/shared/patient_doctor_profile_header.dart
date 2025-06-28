import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/users.dart';

class PatientDoctorProfileHeader extends StatefulWidget {
  final DoctorUserProfile doctorUserProfile;

  const PatientDoctorProfileHeader({
    super.key,
    required this.doctorUserProfile,
  });

  @override
  State<PatientDoctorProfileHeader> createState() => _PatientDoctorProfileHeaderState();
}

class _PatientDoctorProfileHeaderState extends State<PatientDoctorProfileHeader> {
  @override
  Widget build(BuildContext context) {
    final doctorUserProfile = widget.doctorUserProfile;
    final ThemeData theme = Theme.of(context);
    final Widget profileImageWidget =
        doctorUserProfile.profileImage.isEmpty ? Image.asset('assets/images/doctors_profile.jpg') : Image.network(doctorUserProfile.profileImage);
    final String speciality = doctorUserProfile.specialities.first.specialities;
    final String specialityImage = doctorUserProfile.specialities.first.image;

    final uri = Uri.parse(specialityImage);
    final imageIsSvg = uri.path.endsWith('.svg');
    final Color statusColor = doctorUserProfile.lastLogin.idle ?? false
        ? const Color(0xFFFFA812)
        : doctorUserProfile.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);
    final String doctorName = "Dr. ${doctorUserProfile.fullName}";
    late String years = '--';
    late String months = '--';
    late String days = '--';
    if (doctorUserProfile.dob is DateTime) {
      DateTime dob = doctorUserProfile.dob;
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
                      doctorName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      context.tr('doctorIdHeader', args: ['#${doctorUserProfile.doctorsId}']),
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
                              " ${doctorUserProfile.dob is String ? '---- -- --' : DateFormat("dd MMM yyyy").format(doctorUserProfile.dob.toLocal())}",
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
                            Text(doctorUserProfile.city == '' ? '---' : doctorUserProfile.city),
                          ],
                        ),
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColor),
                            const SizedBox(width: 5),
                            Text('${context.tr('state')} '),
                            Text(doctorUserProfile.state == '' ? '---' : doctorUserProfile.state),
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
                            Text(doctorUserProfile.country == '' ? '---' : doctorUserProfile.country),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            imageIsSvg
                                ? SvgPicture.network(
                                    specialityImage,
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.fitHeight,
                                  )
                                : SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CachedNetworkImage(
                                      imageUrl: specialityImage,
                                      fadeInDuration: const Duration(milliseconds: 0),
                                      fadeOutDuration: const Duration(milliseconds: 0),
                                      errorWidget: (ccontext, url, error) {
                                        return Image.asset(
                                          'assets/images/default-avatar.png',
                                        );
                                      },
                                    ),
                                  ),
                            const SizedBox(width: 5),
                            Text(
                              speciality,
                              style: const TextStyle(fontSize: 12),
                            )
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
                        Text(doctorUserProfile.mobileNumber == '' ? '---' : doctorUserProfile.mobileNumber),
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
