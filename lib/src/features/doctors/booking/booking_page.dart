import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/booking_information_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/booking_information_service.dart';
import 'package:health_care/shared/dashboard_main_card_under_header.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/booking/booking_button_box.dart';
import 'package:health_care/src/features/doctors/booking/booking_calendar.dart';
import 'package:health_care/src/features/doctors/booking/booking_doctor_header.dart';
import 'package:health_care/src/features/doctors/booking/next_button.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class BookingPage extends StatefulWidget {
  static const String routeName = '/doctors/booking';
  final String doctorId;
  const BookingPage({
    super.key,
    required this.doctorId,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  final BookingInformationService bookingInformationService = BookingInformationService();
  late final AuthProvider authProvider;
  late final BookingInformationProvider bookingInformationProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  bool _hasRedirected = false;
  bool isLoading = true;
  DateTime? calendarValue;
  OccupyTime? occupyTime;
  Future<void> getDataOnUpdate() async {
    await bookingInformationService.getBookingPageInformation(
      context,
      widget.doctorId,
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
    occupyTime = null;
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
    socket.off('getBookingPageInformationReturn');
    socket.off('updateGetBookingPageInformation');
    socket.off('createOccupyTimeReturn');
    socket.off('deleteOccupyTimeReturn');
    scrollController.dispose();
    super.dispose();
  }

  void setCalendarValue(DateTime selectedDay) {
    setState(() {
      calendarValue = selectedDay;
    });
  }

  void onSetOccupy(OccupyTime? newOccupyTime) {
    setState(() {
      occupyTime = newOccupyTime;
    });
  }

  void onEntranceSetOccupyTime(BuildContext context, BookingInformation? bookingInformation) {
    if (bookingInformation == null) return;
    if (!context.mounted) return;
    if (bookingInformation.occupyTime.isEmpty) return;
    final String roleName = authProvider.roleName;
    final String? patientId = roleName == 'patient' ? authProvider.patientProfile?.userId : authProvider.doctorsProfile?.userId;
    if (patientId == null) return;
    OccupyTime? currentOccupy;
    try {
      currentOccupy = bookingInformation.occupyTime.firstWhere((occupy) => occupy.patientId == patientId);
    } catch (e) {
      currentOccupy = null;
    }
    if (currentOccupy != null) {
      if (occupyTime == null) {
        setState(() {
          occupyTime = currentOccupy;
        });
      }
      // do your logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookingInformationProvider, AuthProvider>(builder: (context, bookingInformationProvider, authProvider, child) {
      final BookingInformation? bookingInformation = bookingInformationProvider.bookingInformation;
      final ThemeData theme = Theme.of(context);
      final String roleName = authProvider.roleName;

      if (roleName.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.microtask(() {
            if (context.mounted) {
              final encodeddoctorId = base64.encode(utf8.encode(bookingInformation!.doctorId.toString()));
              context.go(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
            }
          });
        });
      }
      // Delay logic until after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onEntranceSetOccupyTime(context, bookingInformation);
      });
      if (isLoading) {
        return ScaffoldWrapper(
          title: context.tr('bookingInformation'),
          children: const Center(child: CircularProgressIndicator()),
        );
      }
      //Redirect if id is empty
      if (!isLoading && (bookingInformation!.id.isEmpty) && !_hasRedirected) {
        _hasRedirected = true;
        Future.microtask(() {
          if (context.mounted) {
            context.go('/doctors/search');
          }
        });
      }

      if (bookingInformation != null) {
        final BookingInformationDoctorProfile doctorProfile = bookingInformation.doctorProfile;

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
                        doctorProfile: doctorProfile,
                      ),
                      DashboardMainCardUnderHeader(
                        children: [
                          ListTile(
                            title: Text(context.tr('selectAvailableSlots')),
                          ),
                          BookingCalendar(
                            bookingInformation: bookingInformation,
                            setCalendarValue: setCalendarValue,
                          ),
                          calendarValue == null
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      context.tr('selectAvailableToContinue'),
                                      style: TextStyle(color: theme.primaryColorLight),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                      child: Text(
                                        DateFormat('MMMM d, yyyy').format(calendarValue!),
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: theme.primaryColorLight,
                                        ),
                                      ),
                                    ),
                                    ...bookingInformation.availableSlots
                                        .where(
                                          (slot) =>
                                              calendarValue!.isAfter(
                                                slot.startDate.subtract(
                                                  const Duration(days: 1),
                                                ),
                                              ) &&
                                              calendarValue!.isBefore(
                                                slot.finishDate.add(
                                                  const Duration(days: 1),
                                                ),
                                              ),
                                        )
                                        .map(
                                          // (slot) => _buildAvailableSlotUI(context, slot, calendarValue!, bookingInformation),
                                          (slot) => BookingButtonBox(
                                            slot: slot,
                                            calendarValue: calendarValue!,
                                            bookingInformation: bookingInformation,
                                            occupyTime: occupyTime,
                                            onSetOccupy: onSetOccupy,
                                            authProvider: authProvider,
                                          ),
                                        ),
                                    if (occupyTime != null)
                                      NextButton(
                                        authProvider: authProvider,
                                        bookingInformation: bookingInformation,
                                        occupyTime: occupyTime,
                                        bookingInformationService: bookingInformationService,
                                        onSetOccupy: onSetOccupy,
                                      ),
                                  ],
                                )
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
