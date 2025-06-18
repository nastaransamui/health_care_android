
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/appointment_available_time.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/available_time_service.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/features/doctors/available_timing/available_time_buttom_sheet.dart';
import 'package:health_care/src/features/doctors/available_timing/available_time_data_source.dart';
import 'package:health_care/stream_socket.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DoctorsAvailableTiming extends StatefulWidget {
  const DoctorsAvailableTiming({super.key});

  @override
  State<DoctorsAvailableTiming> createState() => _DoctorsAvailableTimingState();
}

class _DoctorsAvailableTimingState extends State<DoctorsAvailableTiming> {
  final CalendarController _calendarController = CalendarController();
  late final AppointmentProvider appointmentProvider;
  final AvailableTimeService availableTimeService = AvailableTimeService();
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  bool _isProvidersInitialized = false;
  DateTime initialStartDate = DateTime.now();
  CalendarView _lastView = CalendarView.day;
  bool _isFetchingData = false;

  final List<CalendarView> _allowedViews = <CalendarView>[
    CalendarView.day,
    CalendarView.week,
    CalendarView.month,
  ];

  Future<void> getDataOnUpdate(DateTime startDate, DateTime endDate, CalendarView currentView) async {
    appointmentProvider.setLoading(true);
    availableTimeService.getDoctorAvailableTime(context, startDate, endDate);
    initialStartDate = startDate;
    _lastView = currentView;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void initState() {
    authService.updateLiveAuth(context);
    _calendarController.view = CalendarView.day;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      _isProvidersInitialized = true;
      getDataOnUpdate(initialStartDate, initialStartDate, CalendarView.day);
    }
  }

  @override
  void dispose() {
   socket.off('getDoctorAvailableTimeReturn');
   _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, _) {
        final isLoading = appointmentProvider.isLoading;
        return ScaffoldWrapper(
          title: context.tr('availableTiming'),
          children: Column(
            children: [
              FadeinWidget(
                isCenter: true,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColorLight),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          context.tr("availableTiming"),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? Expanded(
                      child: Row(
                      children: [
                        Expanded(
                            child: Container(
                          color: theme.canvasColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                              ),
                            ),
                          ),
                        ))
                      ],
                    ))
                  : Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                                color: theme.canvasColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _getTimelineViewsCalendar(
                                    _calendarController,
                                    AvailableTimeDataSource(
                                      appointmentProvider.appointmentReservations
                                          .map((json) => AppointmentAvailableTimeModel.fromJson(json))
                                          .toList(),
                                      context,
                                    ),
                                    _onViewChanged,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _onViewChanged(ViewChangedDetails visibleDatesChangedDetails) {
    final DateTime startDate = visibleDatesChangedDetails.visibleDates.first;
    final DateTime endDate = visibleDatesChangedDetails.visibleDates.last;
    final int length = visibleDatesChangedDetails.visibleDates.length;

    final CalendarView currentView = length == 1
        ? CalendarView.day
        : length == 7
            ? CalendarView.week
            : CalendarView.month;

    // Avoid repeated updates if we're already fetching
    if (_isFetchingData) return;

    // Avoid repeating the same fetch if the start date and view are the same
    final bool isSameDay = initialStartDate.isAtSameDayAs(startDate);
    final bool isSameView = _lastView == currentView;

    if (isSameDay && isSameView) return;
    // Trigger fetch only when view or date actually changes
    _isFetchingData = true;
    getDataOnUpdate(startDate, endDate, currentView).whenComplete(() {
      _isFetchingData = false;
      initialStartDate = startDate; // update initial start
      _lastView = currentView; // update last known view
    });
  }

  /// Returns the Calendar widget based on the properties passed.
  SfCalendar _getTimelineViewsCalendar([
    CalendarController? calendarController,
    CalendarDataSource? calendarDataSource,
    ViewChangedCallback? viewChangedCallback,
  ]) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return SfCalendar(
      controller: calendarController,
      dataSource: calendarDataSource,
      allowedViews: _allowedViews,
      showNavigationArrow: false,
      showDatePickerButton: true,
      cellBorderColor: textColor,
      onViewChanged: viewChangedCallback,
      appointmentTimeTextFormat: 'HH:mm',
      monthViewSettings: const MonthViewSettings(
        numberOfWeeksInView: 6,
        showTrailingAndLeadingDates: false,
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        showAgenda: true,
      ),
      timeSlotViewSettings: TimeSlotViewSettings(
        timeFormat: 'HH:mm',
        minimumAppointmentDuration: const Duration(minutes: 15),
        timeInterval: const Duration(minutes: 60),
        timeTextStyle: TextStyle(fontSize: 13, color: textColor),
      ),
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.appointment && details.appointments != null && details.appointments!.isNotEmpty) {
          final appointment = details.appointments!.first;
          if (appointment is AppointmentAvailableTimeModel) {
            showModalBottomSheet(
              useSafeArea: true,
              showDragHandle: true,
              isScrollControlled: true,
              isDismissible: true,
              enableDrag: true,
              context: context,
              builder: (context) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    return AvailableTimeButtomSheet(
                      appointment: appointment,
                      scrollController: scrollController,
                    );
                  },
                );
              },
            );
          }
        }
      },
    );
  }
}
