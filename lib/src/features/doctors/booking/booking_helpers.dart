import 'package:easy_localization/easy_localization.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/models/doctors_time_slot.dart';

bool disablePastTimeBooking(String date, String time) {
  // Extract the start time from "HH:mm - HH:mm" format
  final startTime = time.split(' - ')[0]; // e.g., "17:00"

  // Parse input date (e.g., "July 3, 2025")
  final parsedDate = DateFormat('MMMM d, yyyy').parse(date);

  // Extract hour and minute from "HH:mm"
  final timeParts = startTime.split(':');
  final hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);

  // Combine date and time
  final dateTime = DateTime(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
    hour,
    minute,
  );

  return dateTime.isAfter(DateTime.now());
}

bool isTimeSlotBooked(TimeType newTimeslot, DateTime calendarValue, String period) {
  if (newTimeslot.reservations.isEmpty) return false;

  final selectedDay = DateFormat('dd MMM yyyy').format(calendarValue);

  for (final reservation in newTimeslot.reservations) {
    final reservationDay = DateFormat('dd MMM yyyy').format(reservation.selectedDate);

    if (reservationDay == selectedDay && reservation.timeSlot.period == period) {
      return true;
    }
  }

  return false;
}

bool isTimeSlotOccupied(List<OccupyTime> occupyList, TimeType newTimeslot, DateTime calendarValue) {
  return occupyList.any((occupy) => occupy.timeSlot.period == newTimeslot.period && isSameDay(occupy.selectedDate, calendarValue));
}

bool patientHasOccupiedTimeFunction(List<OccupyTime> occupyTimes, String patientId, DateTime selectedDate, String period) {
  return occupyTimes.where((a) => isSameDay(a.selectedDate, selectedDate) && a.dayPeriod == period).any((a) => a.patientId == patientId);
}

List<String> getOccupiedIdsByPatient(List<OccupyTime> occupyTimes, String patientId) {
  return occupyTimes
      .where((a) => a.patientId == patientId)
      .map((a) => a.id) // assuming `id` is non-nullable or has null check
      .whereType<String>()
      .toList();
}

String getAllDayPeriodCombinations(List<OccupyTime> occupyTimes) {
  return occupyTimes.map((a) => "${DateFormat('dd MMM yyyy').format(a.selectedDate)} ${a.timeSlot.period}").join(', ');
}

bool isExactOccupyMatch(List<OccupyTime> occupyTimes, DateTime calendarValue, String period) {
  final current = "${DateFormat('dd MMM yyyy').format(calendarValue)} $period";
  final allCombinations = occupyTimes.map((a) => "${DateFormat('dd MMM yyyy').format(a.selectedDate)} ${a.timeSlot.period}").toList();
  return allCombinations.contains(current);
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
