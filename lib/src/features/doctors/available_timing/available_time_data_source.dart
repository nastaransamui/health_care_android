import 'package:flutter/material.dart';
import 'package:health_care/models/appointment_available_time.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AvailableTimeDataSource extends CalendarDataSource {
  final BuildContext context;
  AvailableTimeDataSource(List<AppointmentAvailableTimeModel> appointments, this.context) {
    this.appointments = appointments;
  }
  @override
  DateTime getStartTime(int index) => appointments![index].startDate;

  @override
  DateTime getEndTime(int index) => appointments![index].finishDate;

  @override
  String getSubject(int index) => appointments![index].title;

  @override
  Color getColor(int index) => Theme.of(context).primaryColorLight;

  @override
  bool isAllDay(int index) => false;

  AppointmentAvailableTimeModel getAppointment(int index) => appointments![index] as AppointmentAvailableTimeModel;
}
