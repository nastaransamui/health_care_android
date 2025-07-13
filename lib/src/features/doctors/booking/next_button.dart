import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/booking_information_service.dart';
import 'package:health_care/src/features/auth/login_screen.dart';
import 'package:health_care/src/features/loading_screen.dart';

class NextButton extends StatelessWidget {
  const NextButton({
    super.key,
    required this.authProvider,
    required this.bookingInformation,
    required this.occupyTime,
    required this.bookingInformationService,
    required this.onSetOccupy,
  });
  final AuthProvider authProvider;
  final BookingInformation bookingInformation;
  final OccupyTime? occupyTime;
  final BookingInformationService bookingInformationService;
  final void Function(OccupyTime?) onSetOccupy;
  Future<void> nextButtonClick(BuildContext context, OccupyTime occupyTime) async {
    if (occupyTime.id.isEmpty) {
      final occupyTimeJson = occupyTime.toJson();
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: true,
        context: context,
        builder: (context) => const LoadingScreen(),
      );
      String newOccupyId = await bookingInformationService.createOccupyTime(context, occupyTimeJson);
      if (newOccupyId.isNotEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          occupyTime.id = newOccupyId;
          onSetOccupy(occupyTime);
          Navigator.of(context).maybePop();
          final encodedOccupyId = base64.encode(utf8.encode(newOccupyId.toString()));
          context.push(Uri(path: '/doctors/check-out/$encodedOccupyId').toString());
        });
      }
    } else {
      final encodedOccupyId = base64.encode(utf8.encode(occupyTime.id.toString()));
      context.push(Uri(path: '/doctors/check-out/$encodedOccupyId').toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final String roleName = authProvider.roleName;
    final ThemeData theme = Theme.of(context);
    final String? patientId = roleName == 'patient' ? authProvider.patientProfile?.userId : authProvider.doctorsProfile?.userId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
      child: Container(
        height: roleName == 'doctors' ? 55 : 35,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor,
              theme.primaryColorLight,
            ],
          ),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(8),
            right: Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.all(1),
        child: GestureDetector(
          onTap: () async {
            if (roleName.isEmpty) {
              showModalBottomSheet(
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
            } else if (patientId != bookingInformation.doctorId && roleName != 'doctors') {
              if (occupyTime != null) {
                occupyTime?.patientId = patientId!;
                nextButtonClick(context, occupyTime!);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColorLight,
                  theme.primaryColor,
                ],
              ),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(7),
                right: Radius.circular(7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    roleName.isEmpty
                        ? context.tr('loginToContinue')
                        : patientId == bookingInformation.doctorId
                            ? context.tr('cantBookYourOwnReservation')
                            : roleName == 'doctors'
                                ? context.tr('cantReserveWithDoctorAccount')
                                : context.tr('next'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: roleName == 'doctors' && patientId != bookingInformation.doctorId ? 15 : 18,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: 3,
                  ),
                ),
                if (roleName.isNotEmpty && patientId != bookingInformation.doctorId && roleName != 'doctors') ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_circle_right_outlined,
                    color: Colors.black,
                    size: 18.0,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
