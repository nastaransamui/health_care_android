import 'dart:developer';

import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/users.dart';

// enum DoctorPaymentStatus {
//   pending("Pending"),
//   paid("Paid"),
//   awaitingRequest("Awaiting Request");

//   final String value;
//   const DoctorPaymentStatus(this.value);

//   static DoctorPaymentStatus fromString(String value) {
//     return DoctorPaymentStatus.values.firstWhere(
//       (e) => e.value == value,
//       orElse: () => DoctorPaymentStatus.pending,
//     );
//   }
// }

class AppointmentReservation {
  final String id;
  final int appointmentId;
  final TimeType timeSlot;
  final DateTime selectedDate;
  final String dayPeriod;
  final String doctorId;
  final DateTime startDate;
  final DateTime finishDate;
  final String slotId;
  final String patientId;
  final String paymentToken;
  final String paymentType;
  final String invoiceId;
  final String doctorPaymentStatus;
  final dynamic paymentDate;
  final DateTime createdDate;
  final PatientUserProfile patientProfile;

  AppointmentReservation({
    required this.id,
    required this.appointmentId,
    required this.timeSlot,
    required this.selectedDate,
    required this.dayPeriod,
    required this.doctorId,
    required this.startDate,
    required this.finishDate,
    required this.slotId,
    required this.patientId,
    required this.paymentToken,
    required this.paymentType,
    required this.invoiceId,
    required this.doctorPaymentStatus,
    this.paymentDate,
    required this.createdDate,
    required this.patientProfile,
  });

  factory AppointmentReservation.fromJson(Map<String, dynamic> json) {
    dynamic rawProfile = json['patientProfile'];

    PatientUserProfile profile = PatientUserProfile.empty();

    if (rawProfile != null) {
      if (rawProfile is String) {
        try {
          profile = PatientUserProfile.fromJson(rawProfile); // it's a JSON string
        } catch (e) {
          log('Error parsing patientProfile JSON string: $e');
        }
      } else if (rawProfile is Map<String, dynamic>) {
        try {
          profile = PatientUserProfile.fromMap(rawProfile);
        } catch (e) {
          log('Error parsing patientProfile map: $e');
        }
      } else {
        log('Unexpected patientProfile type: ${rawProfile.runtimeType}');
      }
    }
    return AppointmentReservation(
      id: json['_id'],
      appointmentId: json['id'],
      timeSlot: TimeType.fromJson(json['timeSlot']),
      selectedDate: DateTime.parse(json['selectedDate']),
      dayPeriod: json['dayPeriod'],
      doctorId: json['doctorId'],
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
      slotId: json['slotId'],
      patientId: json['patientId'],
      paymentToken: json['paymentToken'],
      paymentType: json['paymentType'],
      invoiceId: json['invoiceId'],
      doctorPaymentStatus: json['doctorPaymentStatus'],
      paymentDate: json['paymentDate'] != "" ? DateTime.parse(json['paymentDate']) : null,
      createdDate: DateTime.parse(json['createdDate']),
      patientProfile: profile,
    );
  }

  factory AppointmentReservation.empty() {
    return AppointmentReservation(
      id: '',
      appointmentId: 0,
      timeSlot: TimeType(
        active: false,
        bookingsFee: 0,
        bookingsFeePrice: 0,
        currencySymbol: '',
        isReserved: false,
        period: '',
        price: 0,
        reservations: [],
        total: 0,
      ),
      selectedDate: DateTime.now(),
      dayPeriod: '',
      doctorId: '',
      startDate: DateTime.now(),
      finishDate: DateTime.now(),
      slotId: '',
      patientId: '',
      paymentToken: '',
      paymentType: '',
      invoiceId: '',
      doctorPaymentStatus: '',
      createdDate: DateTime.now(),
      patientProfile: PatientUserProfile.empty(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': appointmentId,
      'timeSlot': timeSlot.toJson(),
      'selectedDate': selectedDate.toIso8601String(),
      'dayPeriod': dayPeriod,
      'doctorId': doctorId,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'slotId': slotId,
      'patientId': patientId,
      'paymentToken': paymentToken,
      'paymentType': paymentType,
      'invoiceId': invoiceId,
      'doctorPaymentStatus': doctorPaymentStatus,
      'paymentDate': paymentDate?.toIso8601String() ?? "",
      'createdDate': createdDate.toIso8601String(),
      'patientProfile': patientProfile.toJson(),
    };
  }

  factory AppointmentReservation.fromMap(Map<String, dynamic> map) {
    return AppointmentReservation(
      id: map['_id'],
      appointmentId: map['id'] ?? 0, // Default to 0 if null
      timeSlot: TimeType.fromMap(map['timeSlot'] ?? {}),
      selectedDate: map['selectedDate'] != null ? DateTime.parse(map['selectedDate']) : DateTime.now(),
      dayPeriod: map['dayPeriod'] ?? '', // Default to empty string if null
      doctorId: map['doctorId'] ?? '', // Default to empty string if null
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : DateTime.now(),
      finishDate: map['finishDate'] != null ? DateTime.parse(map['finishDate']) : DateTime.now(),
      slotId: map['slotId'] ?? '', // Default to empty string if null
      patientId: map['patientId'] ?? '', // Default to empty string if null
      paymentToken: map['paymentToken'] ?? '', // Default to empty string if null
      paymentType: map['paymentType'] ?? '', // Default to empty string if null
      invoiceId: map['invoiceId'] ?? '', // Default to empty string if null
      doctorPaymentStatus: map['doctorPaymentStatus'] ?? "Pending", // Default to pending if null
      paymentDate: map['paymentDate'],
      createdDate: map['createdDate'] != null ? DateTime.parse(map['createdDate']) : DateTime.now(),
      patientProfile: PatientUserProfile.fromMap(map['patientProfile']),
    );
  }

  @override
  String toString() {
    return 'AppointmentReservation(id: $id, appointmentId: $appointmentId, timeSlot: $timeSlot, selectedDate: $selectedDate, dayPeriod: $dayPeriod, doctorId: $doctorId, startDate: $startDate, finishDate: $finishDate, slotId: $slotId, patientId: $patientId, paymentToken: $paymentToken, paymentType: $paymentType, invoiceId: $invoiceId, doctorPaymentStatus: $doctorPaymentStatus, paymentDate: $paymentDate, createdDate: $createdDate, patientProfile: $patientProfile)';
  }
}
