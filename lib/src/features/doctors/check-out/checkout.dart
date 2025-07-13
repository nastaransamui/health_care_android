import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/booking_information_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/booking_information_service.dart';
import 'package:health_care/shared/dashboard_main_card_under_header.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/booking/booking_doctor_header.dart';
import 'package:health_care/src/features/doctors/booking/countdown_timer.dart';
import 'package:health_care/src/features/doctors/check-out/booking_bill_details.dart';
import 'package:health_care/src/features/doctors/check-out/booking_summary_card.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class CheckOut extends StatefulWidget {
  static const String routeName = '/doctors/check-out/';
  final String occupyId;
  const CheckOut({
    super.key,
    required this.occupyId,
  });

  @override
  State<CheckOut> createState() => _CheckoutState();
}

class _CheckoutState extends State<CheckOut> {
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  final BookingInformationService bookingInformationService = BookingInformationService();
  late final AuthProvider authProvider;
  late final BookingInformationProvider bookingInformationProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  bool _hasRedirected = false;
  bool isLoading = true;

  Future<void> getDataOnUpdate() async {
    final String roleName = authProvider.roleName;
    final String? patientId = roleName == 'patient' ? authProvider.patientProfile?.userId : authProvider.doctorsProfile?.userId;
    await bookingInformationService.findOccupyTimeForCheckout(
      context,
      widget.occupyId,
      patientId!,
      () {
        if (context.mounted) {
          setState(() => isLoading = false);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      bookingInformationProvider = Provider.of<BookingInformationProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('findOccupyTimeForCheckoutReturn');
    socket.off('reserveAppointmentReturn');
    // socket.off('createOccupyTimeReturn');
    // socket.off('deleteOccupyTimeReturn');
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookingInformationProvider, AuthProvider>(builder: (context, bookingInformationProvider, authProvider, child) {
      final OccupyTime? occupyTime = bookingInformationProvider.occupyTime;
      final ThemeData theme = Theme.of(context);
      final PatientUserProfile patientUserProfile = authProvider.patientProfile!.userProfile;
      final String roleName = authProvider.roleName;

      if (roleName.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.microtask(() {
            if (context.mounted) {
              final encodeddoctorId = base64.encode(utf8.encode(occupyTime!.doctorId.toString()));
              context.go(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
            }
          });
        });
      }
      if (isLoading) {
        return ScaffoldWrapper(
          title: context.tr('doctorsCheckout'),
          children: const Center(child: CircularProgressIndicator()),
        );
      }
      //Redirect if id is empty
      if (!isLoading && (occupyTime!.id.isEmpty) && !_hasRedirected) {
        _hasRedirected = true;
        Future.microtask(() {
          if (context.mounted) {
            context.push('/doctors/search');
          }
        });
      }

      if (occupyTime != null) {
        final BookingInformationDoctorProfile? doctorProfile = occupyTime.doctorProfile;
        return ScaffoldWrapper(
          title: context.tr('bookingInformation'),
          children: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  double per = 0;
                  if (scrollController.hasClients) {
                    per = (scrollController.offset / scrollController.position.maxScrollExtent);
                  }
                  if (per >= 0) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        setState(() {
                          scrollPercentage = 307 * per;
                        });
                      }
                    });
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookingDoctorHeader(
                        doctorProfile: doctorProfile!,
                      ),
                      DashboardMainCardUnderHeader(
                        children: [
                          Center(
                            child: CountdownTimer(
                              expireAt: occupyTime.expireAt,
                              doctorId: occupyTime.doctorId,
                            ),
                          ),
                          // Booking Summary
                          BookingSummaryCard(theme: theme, occupyTime: occupyTime),
                          // Billing Details
                          Padding(
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
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        context.tr('billingDetails'),
                                        style: TextStyle(fontSize: 20, color: theme.primaryColorLight),
                                      ),
                                    ),
                                    MyDivider(theme: theme),
                                    BookingBillDetails(
                                      patientUserProfile: patientUserProfile,
                                      occupyTime: occupyTime,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
