import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide VerticalDivider;
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/shared/patient_doctor_profile_header.dart';
import 'package:health_care/shared/star_review_widget.dart';
import 'package:health_care/src/features/doctors/search/slideableWidgets/get_recommendation_percentage.dart';
import 'package:health_care/src/utils/calculate_average_rating.dart';

class BookingDoctorHeader extends StatelessWidget {
  const BookingDoctorHeader({
    super.key,
    required this.doctorProfile,
  });

  final BookingInformationDoctorProfile doctorProfile;

  @override
  Widget build(BuildContext context) {
    final Widget profileImageWidget =
        doctorProfile.profileImage.isEmpty ? Image.asset('assets/images/doctors_profile.jpg') : Image.network(doctorProfile.profileImage);
    final Color statusColor = doctorProfile.lastLogin.idle
        ? const Color(0xFFFFA812)
        : doctorProfile.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);
    final String speciality = doctorProfile.specialities.first.specialities;
    final String specialityImage = doctorProfile.specialities.first.image;

    final uri = Uri.parse(specialityImage);
    final imageIsSvg = uri.path.endsWith('.svg');
    List<double> rateArray = doctorProfile.rateArray;
    double averageRating = calculateAverageRating(rateArray);
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    "Dr. ${doctorProfile.fullName}",
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                                      text: doctorProfile.city.isEmpty ? '---' : doctorProfile.city,
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
                                    text: doctorProfile.state.isEmpty ? '---' : doctorProfile.state,
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
                                      text: doctorProfile.country.isEmpty ? '---' : doctorProfile.country,
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
                            iconWidget: const SizedBox(width: 0),
                            titleWidget: Text(
                              '${context.tr('speciality')}:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            mainTextWidget: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                          fadeInDuration: Duration.zero,
                                          fadeOutDuration: Duration.zero,
                                          errorWidget: (context, url, error) => Image.asset(
                                            'assets/images/default-avatar.png',
                                          ),
                                        ),
                                      ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    speciality,
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
                          // Country Column
                          ProfileHeaderCellWidget(
                            iconWidget: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: FaIcon(FontAwesomeIcons.thumbsUp, size: 13, color: theme.primaryColor),
                            ),
                            titleWidget: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                context.tr('feedBack'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            mainTextWidget: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: getRecommendationPercentageFromBookingInformation(doctorProfile),
                                    ),
                                    const TextSpan(text: '  '),
                                    TextSpan(
                                      text: "(${doctorProfile.recommendArray.length} ${context.tr('votes')})",
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
                            iconWidget: const SizedBox(width: 0),
                            titleWidget: Text(
                              '${context.tr('rates')}:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            mainTextWidget: StarReviewWidget(
                              rate: averageRating,
                              textColor: textColor,
                              starSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
