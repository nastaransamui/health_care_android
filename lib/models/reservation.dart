import 'dart:convert';

import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/users.dart';

class Reservation {
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
  final DoctorUserProfile doctorProfile;
  final PatientUserProfile patientProfile;

  Reservation({
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
    required this.paymentDate,
    required this.createdDate,
    required this.doctorProfile,
    required this.patientProfile,
  });

  Reservation copyWith({
    String? id,
    int? appointmentId,
    TimeType? timeSlot,
    DateTime? selectedDate,
    String? dayPeriod,
    String? doctorId,
    DateTime? startDate,
    DateTime? finishDate,
    String? slotId,
    String? patientId,
    String? paymentToken,
    String? paymentType,
    String? invoiceId,
    String? doctorPaymentStatus,
    dynamic paymentDate,
    DateTime? createdDate,
    DoctorUserProfile? doctorProfile,
    PatientUserProfile? patientProfile,
  }) {
    return Reservation(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      timeSlot: timeSlot ?? this.timeSlot,
      selectedDate: selectedDate ?? this.selectedDate,
      dayPeriod: dayPeriod ?? this.dayPeriod,
      doctorId: doctorId ?? this.doctorId,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      slotId: slotId ?? this.slotId,
      patientId: patientId ?? this.patientId,
      paymentToken: paymentToken ?? this.paymentToken,
      paymentType: paymentType ?? this.paymentType,
      invoiceId: invoiceId ?? this.invoiceId,
      doctorPaymentStatus: doctorPaymentStatus ?? this.doctorPaymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      createdDate: createdDate ?? this.createdDate,
      doctorProfile: doctorProfile ?? this.doctorProfile,
      patientProfile: patientProfile ?? this.patientProfile,
    );
  }


  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['_id'] ?? '',
      appointmentId: map['id']?.toInt() ?? 0,
      timeSlot: TimeType.fromMap(map['timeSlot'] ?? {}),
      selectedDate: map['selectedDate'] != null ? DateTime.parse(map['selectedDate']) : DateTime.now(),
      dayPeriod: map['dayPeriod'] ?? '',
      doctorId: map['doctorId'] ?? '',
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : DateTime.now(),
      finishDate: map['finishDate'] != null ? DateTime.parse(map['finishDate']) : DateTime.now(),
      slotId: map['slotId'] ?? '',
      patientId: map['patientId'] ?? '',
      paymentToken: map['paymentToken'] ?? '',
      paymentType: map['paymentType'] ?? '',
      invoiceId: map['invoiceId'] ?? '',
      doctorPaymentStatus: map['doctorPaymentStatus'] ?? "Awaiting Request",
      paymentDate: (map['paymentDate'] is String && map['paymentDate'].isNotEmpty) ?DateTime.tryParse(map['paymentDate'].trim()) : '' ,
      createdDate: map['createdDate'] != null ? DateTime.parse(map['createdDate']) : DateTime.now(),
      doctorProfile: DoctorUserProfile.fromMap(map['doctorProfile']),
      patientProfile: PatientUserProfile.fromMap(map['patientProfile']),
    );
  }


  factory Reservation.fromJson(String source) => Reservation.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Reservation(id: $id, appointmentId: $appointmentId, timeSlot: $timeSlot, selectedDate: $selectedDate, dayPeriod: $dayPeriod, doctorId: $doctorId, startDate: $startDate, finishDate: $finishDate, slotId: $slotId, patientId: $patientId, paymentToken: $paymentToken, paymentType: $paymentType, invoiceId: $invoiceId, doctorPaymentStatus: $doctorPaymentStatus, paymentDate: $paymentDate, createdDate: $createdDate, doctorProfile: $doctorProfile, patientProfile: $patientProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Reservation &&
      other.id == id &&
      other.appointmentId == appointmentId &&
      other.timeSlot == timeSlot &&
      other.selectedDate == selectedDate &&
      other.dayPeriod == dayPeriod &&
      other.doctorId == doctorId &&
      other.startDate == startDate &&
      other.finishDate == finishDate &&
      other.slotId == slotId &&
      other.patientId == patientId &&
      other.paymentToken == paymentToken &&
      other.paymentType == paymentType &&
      other.invoiceId == invoiceId &&
      other.doctorPaymentStatus == doctorPaymentStatus &&
      other.paymentDate == paymentDate &&
      other.createdDate == createdDate &&
      other.doctorProfile == doctorProfile &&
      other.patientProfile == patientProfile;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      appointmentId.hashCode ^
      timeSlot.hashCode ^
      selectedDate.hashCode ^
      dayPeriod.hashCode ^
      doctorId.hashCode ^
      startDate.hashCode ^
      finishDate.hashCode ^
      slotId.hashCode ^
      patientId.hashCode ^
      paymentToken.hashCode ^
      paymentType.hashCode ^
      invoiceId.hashCode ^
      doctorPaymentStatus.hashCode ^
      paymentDate.hashCode ^
      createdDate.hashCode ^
      doctorProfile.hashCode ^
      patientProfile.hashCode;
  }
}
