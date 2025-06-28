import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/favourites_provider.dart';
import 'package:health_care/services/favourite_service.dart';
import 'package:health_care/shared/animated_add_remove_favourite.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:timezone/timezone.dart' as tz;

class PatientsFavouriteShowBox extends StatefulWidget {
  final DoctorUserProfile doctorFavProfile;
  final PatientsProfile patientProfile;
  final VoidCallback getDataOnUpdate;
  final FavouritesProvider favouritesProvider;
  const PatientsFavouriteShowBox({
    super.key,
    required this.doctorFavProfile,
    required this.getDataOnUpdate,
    required this.patientProfile,
    required this.favouritesProvider,
  });

  @override
  State<PatientsFavouriteShowBox> createState() => _PatientsFavouriteShowBoxState();
}

class _PatientsFavouriteShowBoxState extends State<PatientsFavouriteShowBox> {
  bool isHeart = true;
  final FavouriteService favouriteService = FavouriteService();
  @override
  Widget build(BuildContext context) {
    final DoctorUserProfile doctorProfile = widget.doctorFavProfile;
    final PatientsProfile patientsProfile = widget.patientProfile;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
    final bangkok = tz.getLocation('Asia/Bangkok');
    late String years = '--';
    late String months = '--';
    late String days = '--';
    if (doctorProfile.dob is DateTime) {
      DateTime dob = doctorProfile.dob;
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
    final String doctorName = "Dr. ${doctorProfile.fullName}";
    final String profileImage = doctorProfile.profileImage;
    final String? doctorId = doctorProfile.id;
    final LastLogin lastLogin = doctorProfile.lastLogin;
    final DateTime lastLoginDate = lastLogin.date;
    final encodedId = base64.encode(utf8.encode(doctorId.toString()));
    Color statusColor = doctorProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : doctorProfile.online
            ? const Color(0xFF44B700)
            : Colors.pinkAccent;

    final String speciality = doctorProfile.specialities.first.specialities;
    final String specialityImage = doctorProfile.specialities.first.image;

    final uri = Uri.parse(specialityImage);
    final imageIsSvg = uri.path.endsWith('.svg');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
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
                  ProfileImage(theme: theme, encodedId: encodedId, profileImage: profileImage, statusColor: statusColor),
                  const SizedBox(width: 20),
                  BesideProfile(
                      encodedId: encodedId,
                      doctorName: doctorName,
                      theme: theme,
                      widget: widget,
                      doctorProfile: doctorProfile,
                      dateTimeFormat: dateTimeFormat,
                      lastLoginDate: lastLoginDate,
                      bangkok: bangkok),
                ],
              ),
              MyDivider(theme: theme),
              SpecialitiesRow(imageIsSvg: imageIsSvg, specialityImage: specialityImage, speciality: speciality, widget: widget),
              MyDivider(theme: theme),
              BirthdayRow(theme: theme, doctorProfile: doctorProfile, years: years, months: months, days: days, widget: widget),
              MyDivider(theme: theme),
              CityRow(theme: theme, doctorProfile: doctorProfile, widget: widget),
              MyDivider(theme: theme),
              StateRow(theme: theme, doctorProfile: doctorProfile, widget: widget),
              MyDivider(theme: theme),
              CountryRow(theme: theme, doctorProfile: doctorProfile, widget: widget),
              MyDivider(theme: theme),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isHeart = false;
                      });

                      socket.emit('removeDocFromFav', {
                        'doctorId': doctorId,
                        'patientId': patientsProfile.userId,
                      });

                      socket.once('removeDocFromFavReturn', (dynamic msg) async {
                        if (!mounted) return;

                        if (msg['status'] != 200) {
                          if (!mounted) return;

                          await showModalBottomSheet(
                            context: context,
                            useSafeArea: true,
                            isDismissible: true,
                            showDragHandle: true,
                            barrierColor: Theme.of(context).cardColor.withAlpha((0.8 * 255).round()),
                            constraints: BoxConstraints(
                              maxHeight: double.infinity,
                              minWidth: MediaQuery.of(context).size.width,
                              minHeight: MediaQuery.of(context).size.height / 5,
                            ),
                            scrollControlDisabledMaxHeightRatio: 1,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  msg['message'],
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              );
                            },
                          );

                          if (!mounted) return;

                          setState(() {
                            isHeart = true; // failed to remove, reset back
                          });
                        } else {
                          patientsProfile.userProfile.favsId.remove(doctorId);
                          widget.favouritesProvider.setLoading(true);
                        }
                      });
                    },
                    child: AnimatedAddRemoveFavourite(
                      isHeart: isHeart,
                      color: Colors.pink,
                      size: 20,
                    ),
                  ),
                ],
              ),
              ButtonRow(encodedId: encodedId, textColor: textColor),
            ],
          ),
        ),
      ),
    );
  }
}

class ButtonRow extends StatelessWidget {
  const ButtonRow({
    super.key,
    required this.encodedId,
    required this.textColor,
  });

  final String encodedId;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 35,
              child: GradientButton(
                onPressed: () {
                  context.push(
                    Uri(path: '/doctors/profile/$encodedId').toString(),
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
            ),
          ),
        ],
      ),
    );
  }
}

class CountryRow extends StatelessWidget {
  const CountryRow({
    super.key,
    required this.theme,
    required this.doctorProfile,
    required this.widget,
  });

  final ThemeData theme;
  final DoctorUserProfile doctorProfile;
  final PatientsFavouriteShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                const SizedBox(width: 5),
                Text('${context.tr('country')} '),
                Text(
                  doctorProfile.country == '' ? '---' : doctorProfile.country,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SortIconWidget(columnName: 'profile.country', getDataOnUpdate: widget.getDataOnUpdate)
        ],
      ),
    );
  }
}

class StateRow extends StatelessWidget {
  const StateRow({
    super.key,
    required this.theme,
    required this.doctorProfile,
    required this.widget,
  });

  final ThemeData theme;
  final DoctorUserProfile doctorProfile;
  final PatientsFavouriteShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                const SizedBox(width: 3),
                Text('${context.tr('state')} '),
                Text(
                  doctorProfile.state == '' ? '---' : doctorProfile.state,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          ),
          const SizedBox(width: 3),
          SortIconWidget(columnName: 'profile.state', getDataOnUpdate: widget.getDataOnUpdate),
        ],
      ),
    );
  }
}

class CityRow extends StatelessWidget {
  const CityRow({
    super.key,
    required this.theme,
    required this.doctorProfile,
    required this.widget,
  });

  final ThemeData theme;
  final DoctorUserProfile doctorProfile;
  final PatientsFavouriteShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                const SizedBox(width: 5),
                Text('${context.tr('city')} '),
                Text(
                  doctorProfile.city == '' ? '---' : doctorProfile.city,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SortIconWidget(columnName: 'profile.city', getDataOnUpdate: widget.getDataOnUpdate)
        ],
      ),
    );
  }
}

class BirthdayRow extends StatelessWidget {
  const BirthdayRow({
    super.key,
    required this.theme,
    required this.doctorProfile,
    required this.years,
    required this.months,
    required this.days,
    required this.widget,
  });

  final ThemeData theme;
  final DoctorUserProfile doctorProfile;
  final String years;
  final String months;
  final String days;
  final PatientsFavouriteShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.cake,
                  size: 14,
                  color: theme.primaryColorLight,
                ),
                const SizedBox(width: 3),
                Text('${context.tr('dob')} :'),
                Text(
                  " ${doctorProfile.dob is String ? '---- -- --' : DateFormat("dd MMM yyyy").format(doctorProfile.dob.toLocal())}",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 5),
                Text(
                  "$years ${context.tr('years')}, $months ${context.tr('month')}, $days ${context.tr('days')}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SortIconWidget(columnName: 'profile.dob', getDataOnUpdate: widget.getDataOnUpdate)
        ],
      ),
    );
  }
}

class SpecialitiesRow extends StatelessWidget {
  const SpecialitiesRow({
    super.key,
    required this.imageIsSvg,
    required this.specialityImage,
    required this.speciality,
    required this.widget,
  });

  final bool imageIsSvg;
  final String specialityImage;
  final String speciality;
  final PatientsFavouriteShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
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
          ),
          const SizedBox(width: 6),
          SortIconWidget(columnName: 'profile.specialities.0.specialities', getDataOnUpdate: widget.getDataOnUpdate),
        ],
      ),
    );
  }
}

class BesideProfile extends StatelessWidget {
  const BesideProfile({
    super.key,
    required this.encodedId,
    required this.doctorName,
    required this.theme,
    required this.widget,
    required this.doctorProfile,
    required this.dateTimeFormat,
    required this.lastLoginDate,
    required this.bangkok,
  });

  final String encodedId;
  final String doctorName;
  final ThemeData theme;
  final PatientsFavouriteShowBox widget;
  final DoctorUserProfile doctorProfile;
  final DateFormat dateTimeFormat;
  final DateTime lastLoginDate;
  final tz.Location bangkok;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.push(
                      Uri(path: '/doctors/profile/$encodedId').toString(),
                    );
                  },
                  child: Text(
                    doctorName,
                    style: TextStyle(
                      color: theme.primaryColorLight,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SortIconWidget(columnName: 'profile.fullName', getDataOnUpdate: widget.getDataOnUpdate)
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '#${doctorProfile.doctorsId}',
                  style: TextStyle(color: theme.primaryColorLight),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              const SizedBox(width: 6),
              SortIconWidget(columnName: 'profile.id', getDataOnUpdate: widget.getDataOnUpdate)
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.clock, size: 13, color: theme.primaryColorLight),
                    const SizedBox(width: 5),
                    Text(context.tr('lastLogin'), style: const TextStyle(fontSize: 12)),
                    Text(
                      dateTimeFormat.format(tz.TZDateTime.from(lastLoginDate, bangkok)),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              SortIconWidget(columnName: 'status.lastLogin.date', getDataOnUpdate: widget.getDataOnUpdate)
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.theme,
    required this.encodedId,
    required this.profileImage,
    required this.statusColor,
  });

  final ThemeData theme;
  final String encodedId;
  final String profileImage;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          splashColor: theme.primaryColorLight,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          onTap: () {
            context.push(
              Uri(path: '/doctors/profile/$encodedId').toString(),
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
                        'assets/images/doctors_profile.jpg',
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
          bottom: 10,
          child: AvatarGlow(
            glowColor: statusColor,
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
        ),
      ],
    );
  }
}
