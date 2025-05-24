
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/models/users.dart';

class AppointmentAvailableTimeModel {
  final String id;
  final int appointmentId;
  final DateTime startDate;
  final DateTime finishDate;
  final String title;
  final PatientUserProfile patientProfile;
  final DateTime createdDate;
  final String patientId;
  final double total;
  final String currencySymbol;
  final String invoiceId;
  final String doctorPaymentStatus;

  AppointmentAvailableTimeModel({
    required this.id,
    required this.appointmentId,
    required this.startDate,
    required this.finishDate,
    required this.title,
    required this.patientProfile,
    required this.createdDate,
    required this.patientId,
    required this.total,
    required this.currencySymbol,
    required this.invoiceId,
    required this.doctorPaymentStatus,
  });

  factory AppointmentAvailableTimeModel.fromJson(AppointmentReservation json) {
    final timeSlot = json.timeSlot;
    final selectedDate = json.selectedDate;
    final period = timeSlot.period;
    final parts = period.split(' - ');

    final startTime = parts[0];
    final endTime = parts[1];

    final start = DateTime.parse('${selectedDate.toIso8601String().split('T')[0]}T$startTime:00');
    final end = DateTime.parse('${selectedDate.toIso8601String().split('T')[0]}T$endTime:00');

    return AppointmentAvailableTimeModel(
      id: json.id,
      appointmentId: json.appointmentId,
      startDate: start.toLocal(),
      finishDate: end.toLocal(),
      title: json.patientProfile.fullName,
      patientProfile: json.patientProfile,
      createdDate: json.createdDate.toLocal(),
      patientId: json.patientId,
      total: timeSlot.total,
      currencySymbol: timeSlot.currencySymbol,
      invoiceId: json.invoiceId,
      doctorPaymentStatus: json.doctorPaymentStatus,
    );
  }

  @override
  String toString() {
    return 'AppointmentAvailableTimeModel(id: $id, appointmentId: $appointmentId, startDate: $startDate, finishDate: $finishDate, title: $title, patientProfile: $patientProfile, startDate: $startDate, finishDate: $finishDate, createdDate: $createdDate, patientId: $patientId,  invoiceId: $invoiceId, doctorPaymentStatus: $doctorPaymentStatus,  createdDate: $createdDate, patientProfile: $patientProfile)';
  }
}
