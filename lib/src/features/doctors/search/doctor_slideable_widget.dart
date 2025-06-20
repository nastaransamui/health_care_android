import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable_panel/flutter_slidable_panel.dart';
import 'package:badges/badges.dart' as badges;
import 'package:health_care/models/doctors.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/src/features/doctors/search/doctor_card.dart';
import 'package:health_care/stream_socket.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DoctorSlideableWidget extends StatefulWidget {
  final int index;
  final List<Doctors> doctors;
  const DoctorSlideableWidget({
    super.key,
    required this.doctors,
    required this.index,
  });

  @override
  State<DoctorSlideableWidget> createState() => _DoctorSlideableWidgetState();
}

class _DoctorSlideableWidgetState extends State<DoctorSlideableWidget> with TickerProviderStateMixin {
  final SlideController _slideController = SlideController(
    usePreActionController: true,
    usePostActionController: true,
  );

  var height = 200.0;
  bool isFavIconLoading = false;
  late final AnimationController _heartController = AnimationController(
    vsync: this,
    lowerBound: 0.75,
    upperBound: 1,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);
  late final Animation<double> _scaleAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(_heartController);

  @override
  void didChangeDependencies() {
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    height = useMobileLayout ? 200 : 300;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _heartController.dispose();
    socket.off('addDocToFavReturn');
    super.dispose();
  }

  void addDoctorToFav(Doctors doctor, String patientId) {
    var doctorId = doctor.id;
    setState(() {
      isFavIconLoading = true;
    });
    socket.emit('addDocToFav', {'doctorId': doctorId, 'patientId': patientId});
    socket.on('addDocToFavReturn', (dynamic msg) {
      if (msg['status'] != 200) {
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
            _slideController.toggleAction(0);
            if (!context.mounted) return;
            setState(
              () {
                isFavIconLoading = false;
              },
            );
          },
        );
      } else {
        doctor.favIds.add(patientId);
         if (!context.mounted) return;
        setState(
          () {
            isFavIconLoading = false;
          },
        );
        _slideController.toggleAction(0);
      }
    });
  }

  void removeDoctorToFav(Doctors doctor, String patientId) {
    var doctorId = doctor.id;
    setState(() {
      isFavIconLoading = true;
    });
    socket.emit('removeDocFromFav', {'doctorId': doctorId, 'patientId': patientId});
    socket.on('removeDocFromFavReturn', (dynamic msg) {
      if (msg['status'] != 200) {
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
            _slideController.toggleAction(0);
            setState(
              () {
                isFavIconLoading = false;
              },
            );
          },
        );
      } else {
        doctor.favIds.remove(patientId);
        setState(
          () {
            isFavIconLoading = false;
          },
        );
        _slideController.toggleAction(0);
      }
    });
  }

  void increaseHight(useMobileLayout) {
    setState(() {
      height = useMobileLayout ? 280.0 : 350.0;
    });
  }

  void decreaseHight(useMobileLayout) {
    setState(() {
      height = useMobileLayout ? 200.0 : 300.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var isLogin = Provider.of<AuthProvider>(context).isLogin;
    var patientProfile = Provider.of<AuthProvider>(context).patientProfile;
    var doctorsProfile = Provider.of<AuthProvider>(context).doctorsProfile;
    var roleName = Provider.of<AuthProvider>(context).roleName;
    var index = widget.index;
    var doctors = widget.doctors;

    Doctors singleDoctor = doctors[index];

    bool isFave = false;
    String patientId = "";
    if (isLogin) {
      if (roleName == 'patient') {
        isFave = singleDoctor.favIds.contains(patientProfile?.userId);
        patientId = patientProfile!.userId;
      } else if (roleName == 'doctors') {
        isFave = singleDoctor.favIds.contains(doctorsProfile?.userId);
        patientId = doctorsProfile!.userId;
      }
    }
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    return SlidablePanel(
      controller: _slideController,
      maxSlideThreshold:useMobileLayout? 0.5 : 0.2,
      axis: Axis.horizontal,
      preActionLayout: ActionLayout.spaceEvenly(ActionMotion.drawer),
      onSlideStart: () {
        // print("onSlideStart: $index");
      },
      preActions: [
        IconButton(
          onPressed: () {
            bool favOpen = _slideController.hasExpandedAt(0);
            if (!favOpen) {
              _slideController.toggleAction(0);
            } else {
              if (!isLogin) {
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
                        context.tr('favLoginError'),
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    );
                  },
                ).whenComplete(
                  () => _slideController.toggleAction(0),
                );
              } else {
                if (!isFave) {
                  addDoctorToFav(singleDoctor, patientId);
                } else {
                  removeDoctorToFav(singleDoctor, patientId);
                }
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
          icon: isFavIconLoading
              ? SizedBox(
                  height: 30,
                  width: 30,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballRotateChase,
                    colors: [Theme.of(context).primaryColorLight, Colors.pink],
                    strokeWidth: 2.0,
                    pathBackgroundColor: null,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Icon(
                        isLogin
                            ? isFave
                                ? Icons.favorite
                                : Icons.favorite_border
                            : Icons.favorite_outline,
                      ),
                    ),
                    Text('${singleDoctor.favIds.length}')
                  ],
                ),
        ),
        TextButton(
            onPressed: () async {
              _slideController.toggleAction(1);
              final result = await Share.share('check out my website https://health-care.duckdns.org/');
              if (result.status == ShareResultStatus.dismissed) {
                _slideController.toggleAction(1);
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).primaryColorLight,
              shape: const RoundedRectangleBorder(),
              splashFactory: NoSplash.splashFactory,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.share), Text('')],
            )),
      ],
      postActions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(18), right: Radius.circular(18)),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Icon(Icons.thumb_up_sharp),
                    Text(getRecommendationPercentage(singleDoctor)),
                    Text(
                      "(${singleDoctor.recommendArray.length} ${context.tr('votes')})",
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.maxFinite, 30),
                    elevation: 5.0,
                    foregroundColor: Theme.of(context).primaryColor,
                    animationDuration: const Duration(milliseconds: 1000),
                    backgroundColor: Theme.of(context).primaryColorLight,
                    shadowColor: Theme.of(context).primaryColorLight,
                  ),
                  onPressed: singleDoctor.timeslots!.isEmpty ? null : () {},
                  child: Text(
                    context.tr('bookAppointment'),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.maxFinite, 30),
                    elevation: 5.0,
                    foregroundColor: Theme.of(context).primaryColor,
                    animationDuration: const Duration(milliseconds: 1000),
                    backgroundColor: Theme.of(context).primaryColor,
                    shadowColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: singleDoctor.timeslots!.isEmpty ? null : () {},
                  child: Text(
                    context.tr('onlineConsult'),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
      child: GestureDetector(
        onTap: () {
          _slideController.dismiss();
        },
        child: badges.Badge(
          stackFit: StackFit.passthrough,
          badgeContent: Text(
            (singleDoctor.doctorsId).toString(),
            style: const TextStyle(fontSize: 12),
          ),
          position: badges.BadgePosition.custom(start: 20, bottom: 10),
          badgeStyle: badges.BadgeStyle(
            badgeColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(3),
          ),
          child: AnimatedContainer(
            height: height,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DoctorCard(
                singleDoctor: singleDoctor,
                height: height,
                increaseHight: increaseHight,
                decreaseHight: decreaseHight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// Assuming singleDoctor.recommendArray is a List<int> where 1 means a recommendation
String getRecommendationPercentage(singleDoctor) {
  if (singleDoctor.recommendArray != null && singleDoctor.recommendArray.isNotEmpty) {
    int count = singleDoctor.recommendArray.where((vote) => vote == 1).length;
    double percentage = (count / singleDoctor.recommendArray.length) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  } else {
    return '0%';
  }
}