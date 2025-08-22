

import 'package:flutter/material.dart';
import 'package:flutter_slidable_panel/controllers/slide_controller.dart';
import 'package:health_care/models/doctors.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/favourite_service.dart';
import 'package:health_care/shared/animated_add_remove_favourite.dart';
import 'package:health_care/src/features/auth/login_screen.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class DoctorSearchFavIconWidget extends StatefulWidget {
  final Doctors singleDoctor;
  final SlideController slideController;
  const DoctorSearchFavIconWidget({
    super.key,
    required this.singleDoctor,
    required this.slideController,
  });

  @override
  State<DoctorSearchFavIconWidget> createState() => _DoctorSearchFavIconWidgetState();
}

class _DoctorSearchFavIconWidgetState extends State<DoctorSearchFavIconWidget> {
  late final AuthProvider authProvider;
  final FavouriteService favouriteService = FavouriteService();
  bool _isProvidersInitialized = false;
  bool isHeart = true;
  late String roleName = "";
  bool isFave = false;
  String patientId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
    roleName = authProvider.roleName;
    final userId = roleName == 'patient' ? authProvider.patientProfile?.userId : authProvider.doctorsProfile?.userId;

    final newPatientId = userId ?? '';
    final newIsFave = widget.singleDoctor.favIds.contains(newPatientId);

    if (patientId != newPatientId || isFave != newIsFave) {
      setState(() {
        patientId = newPatientId;
        isFave = newIsFave;
      });
    }
  }

  @override
  void didUpdateWidget(covariant DoctorSearchFavIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          isHeart = true;
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

  void addDoctorToFav(Doctors doctor, String patientId) {
    var doctorId = doctor.id;
    socket.off('addDocToFavReturn');
    socket.emit('addDocToFav', {'doctorId': doctorId, 'patientId': patientId});
    socket.on('addDocToFavReturn', (dynamic msg) {
      if (msg['status'] != 200) {
        favTaggleError(msg);
      }
    });
  }

  void removeDoctorToFav(Doctors doctor, String patientId) {
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
    final bool isLogin = authProvider.isLogin;
    return IconButton(
      onPressed:isLogin && roleName == 'doctors' ?  null : () {
        if (!isLogin) {
          favLoginError(context);
        } else {
          setState(() {
            isHeart = false;
          });
          if (!isFave) {
            addDoctorToFav(widget.singleDoctor, patientId);
          } else {
            removeDoctorToFav(widget.singleDoctor, patientId);
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
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedAddRemoveFavourite(
            isHeart: isHeart,
            size: 20,
            color: isLogin && roleName == 'doctors' ? Theme.of(context).disabledColor : Colors.pink,
            isLogin: isLogin,
            isFave: isFave,
          ),
          Text('${widget.singleDoctor.favIds.length}')
        ],
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

  void favTaggleError(Map<String, dynamic>msg) {
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
