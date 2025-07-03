import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/favourite_service.dart';
import 'package:health_care/shared/animated_add_remove_favourite.dart';
import 'package:health_care/src/features/auth/login_screen.dart';
import 'package:health_care/src/features/doctors/search/slideableWidgets/get_recommendation_percentage.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class SearchProfileBookingBox extends StatefulWidget {
  final DoctorUserProfile doctorUserProfile;
  const SearchProfileBookingBox({
    super.key,
    required this.doctorUserProfile,
  });

  @override
  State<SearchProfileBookingBox> createState() => _SearchProfileBookingBoxState();
}

class _SearchProfileBookingBoxState extends State<SearchProfileBookingBox> {
  late final AuthProvider authProvider;
  final FavouriteService favouriteService = FavouriteService();
  bool _isProvidersInitialized = false;
  bool isHeart = true;
  late String roleName = "";
  bool isFave = false;
  String userId = '';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
    roleName = authProvider.roleName;
    final id = roleName == 'patient' ? authProvider.patientProfile?.userId : authProvider.doctorsProfile?.userId;

    final newPatientId = id ?? '';
    final newIsFave = widget.doctorUserProfile.favsId.contains(newPatientId);

    if (userId != newPatientId || isFave != newIsFave) {
      setState(() {
        userId = newPatientId;
        isFave = newIsFave;
      });
    }
  }

  @override
  void didUpdateWidget(covariant SearchProfileBookingBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        final newIsFave = widget.doctorUserProfile.favsId.contains(userId);
        setState(() {
          isHeart = true;
          isFave = newIsFave;
        });
      }
    });
  }

  @override
  void dispose() {
    socket.off('addDocToFavReturn');
    socket.off('removeDocFromFavReturn');
    super.dispose();
  }

  void addDoctorToFav(DoctorUserProfile doctor, String patientId) {
    var doctorId = doctor.id;
    socket.off('addDocToFavReturn');
    socket.emit('addDocToFav', {'doctorId': doctorId, 'patientId': patientId});
    socket.on('addDocToFavReturn', (dynamic msg) {
      if (msg['status'] != 200) {
        favTaggleError(msg);
      }
    });
  }

  void removeDoctorToFav(DoctorUserProfile doctor, String patientId) {
    var doctorId = doctor.id;
    socket.off('removeDocFromFavReturn');
    socket.emit('removeDocFromFav', {'doctorId': doctorId, 'patientId': patientId});
    socket.on('removeDocFromFavReturn', (dynamic msg) {
      if (msg['status'] != 200) {
        favTaggleError(msg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DoctorUserProfile doctorUserProfile = widget.doctorUserProfile;
    final timeslots = doctorUserProfile.timeslots;
    final averageHourlyPrice = (timeslots != null && timeslots.isNotEmpty) ? timeslots.first.averageHourlyPrice : null;
    final ThemeData theme = Theme.of(context);
    final String averageHour = (averageHourlyPrice != null) ? NumberFormat("#,##0", "en_US").format(averageHourlyPrice) : '--';
    final String currency = (doctorUserProfile.currency.isNotEmpty) ? doctorUserProfile.currency[0].currency : '';
    final bool isLogin = authProvider.isLogin;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.primaryColorLight),
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(FontAwesomeIcons.comment, size: 12, color: Theme.of(context).primaryColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text("${doctorUserProfile.reviewsArray.length} ${context.tr('feedBack')}"),
                ),
              ],
            ),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.thumbsUp, size: 12, color: Theme.of(context).primaryColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(getRecommendationPercentage(doctorUserProfile)),
                ),
                Text(
                  "(${doctorUserProfile.recommendArray.length} ${context.tr('votes')})",
                )
              ],
            ),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.moneyBill, size: 12, color: Theme.of(context).primaryColor),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(context.tr('averagePrice')),
                ),
                Text('$averageHour $currency'),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(double.maxFinite, 30),
                elevation: 5.0,
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).primaryColorLight,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(8),
                    right: Radius.circular(8),
                  ),
                ),
              ),
              onPressed: doctorUserProfile.timeslots!.isEmpty
                  ? null
                  : () {
                      final encodeddoctorId = base64.encode(utf8.encode(doctorUserProfile.id.toString()));
                      context.push(Uri(path: '/doctors/booking/$encodeddoctorId').toString());
                    },
              child: Text(
                context.tr('bookAppointment'),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            IconButton(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              onPressed: isLogin && roleName == 'doctors'
                  ? null
                  : () {
                      if (!isLogin) {
                        favLoginError(context);
                      } else {
                        setState(() {
                          isHeart = false;
                        });
                        if (!isFave) {
                          addDoctorToFav(doctorUserProfile, userId);
                        } else {
                          removeDoctorToFav(doctorUserProfile, userId);
                        }
                      }
                    },
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.all(0),
                foregroundColor: isFave ? Colors.pink[600] : Theme.of(context).primaryColorLight,
                splashFactory: NoSplash.splashFactory,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AnimatedAddRemoveFavourite(
                    isHeart: isHeart,
                    size: 20,
                    color: isLogin && roleName == 'doctors' ? Theme.of(context).disabledColor : Colors.pink,
                    isLogin: isLogin,
                    isFave: isFave,
                  ),
                  const SizedBox(width: 4),
                  Text('${doctorUserProfile.favsId.length}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> favLoginError(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      showDragHandle: true,
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height,
        child: LoginScreen(),
      ),
    );
  }

  void favTaggleError(msg) {
    showModalBottomSheet(
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
            style: const TextStyle(
              fontSize: 18.0,
            ),
          ),
        );
      },
    ).whenComplete(
      () {
        setState(() {
          isHeart = true;
        });
      },
    );
  }
}
