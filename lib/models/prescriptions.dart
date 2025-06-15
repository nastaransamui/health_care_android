import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:health_care/models/users.dart';

class Prescriptions {
  final DateTime createdAt;
  final String doctorId;
  final DoctorUserProfile doctorProfile;
  final int prescriptionId;
  final String patientId;
  final List<PrescriptionDetails> prescriptionsArray;
  final DateTime updateAt;
  final String id;
  final PatientUserProfile patientProfile;

  Prescriptions({
    required this.id,
    required this.prescriptionId,
    required this.doctorId,
    required this.patientId,
    required this.createdAt,
    required this.updateAt,
    required this.patientProfile,
    required this.doctorProfile,
    required this.prescriptionsArray,
  });

  Prescriptions copyWith({
    String? id,
    int? prescriptionId,
    String? doctorId,
    String? patientId,
    DateTime? createdAt,
    DateTime? updateAt,
    PatientUserProfile? patientProfile,
    DoctorUserProfile? doctorProfile,
    List<PrescriptionDetails>? prescriptionsArray,
  }) {
    return Prescriptions(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      createdAt: createdAt ?? this.createdAt,
      updateAt: updateAt ?? this.updateAt,
      patientProfile: patientProfile ?? this.patientProfile,
      doctorProfile: doctorProfile ?? this.doctorProfile,
      prescriptionsArray: prescriptionsArray ?? this.prescriptionsArray,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'prescriptionId': prescriptionId});
    result.addAll({'doctorId': doctorId});
    result.addAll({'patientId': patientId});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'updateAt': updateAt.millisecondsSinceEpoch});
    result.addAll({'patientProfile': patientProfile.toMap()});
    result.addAll({'doctorProfile': doctorProfile.toMap()});
    result.addAll({'prescriptionsArray': prescriptionsArray.map((x) => x.toMap()).toList()});

    return result;
  }

  factory Prescriptions.fromMap(Map<String, dynamic> map) {
    return Prescriptions(
      id: map['_id'] ?? '',
      prescriptionId: map['id']?.toInt() ?? 0,
      doctorId: map['doctorId'] ?? '',
      patientId: map['patientId'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updateAt: DateTime.tryParse(map['updateAt'] ?? '') ?? DateTime.now(),
      patientProfile: map['patientProfile'] != null ? PatientUserProfile.fromMap(map['patientProfile']) : PatientUserProfile.empty(),
      doctorProfile: DoctorUserProfile.fromMap(map['doctorProfile']),
      prescriptionsArray: List<PrescriptionDetails>.from(
        (map['prescriptionsArray'] ?? []).map(
          (x) => PrescriptionDetails.fromMap(x),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Prescriptions.fromJson(String source) => Prescriptions.fromMap(json.decode(source));
  factory Prescriptions.empty() {
    return Prescriptions(
      id: '',
      prescriptionId: 0,
      doctorId: '',
      patientId: '',
      createdAt: DateTime.now(),
      updateAt: DateTime.now(),
      patientProfile: PatientUserProfile.empty(),
      doctorProfile: DoctorUserProfile.empty(),
      prescriptionsArray: [PrescriptionDetails.empty()],
    );
  }
  @override
  String toString() {
    return 'Prescriptions(id: $id, prescriptionId: $prescriptionId, doctorId: $doctorId, patientId: $patientId, createdAt: $createdAt, updateAt: $updateAt, patientProfile: $patientProfile, doctorProfile: $doctorProfile, prescriptionsArray: $prescriptionsArray)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Prescriptions &&
        other.id == id &&
        other.prescriptionId == prescriptionId &&
        other.doctorId == doctorId &&
        other.patientId == patientId &&
        other.createdAt == createdAt &&
        other.updateAt == updateAt &&
        other.patientProfile == patientProfile &&
        other.doctorProfile == doctorProfile &&
        listEquals(other.prescriptionsArray, prescriptionsArray);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        prescriptionId.hashCode ^
        doctorId.hashCode ^
        patientId.hashCode ^
        createdAt.hashCode ^
        updateAt.hashCode ^
        patientProfile.hashCode ^
        doctorProfile.hashCode ^
        prescriptionsArray.hashCode;
  }
}

class PrescriptionDetails {
  final String uniqueId;
  String description;
  String medicine;
  String medicineId;
  int quantity;

  PrescriptionDetails({
    required this.description,
    required this.medicine,
    required this.medicineId,
    required this.quantity,
    String? uniqueId,
  }) : uniqueId = uniqueId ?? const Uuid().v4();

  PrescriptionDetails copyWith({
    String? description,
    String? medicine,
    String? medicineId,
    int? quantity,
  }) {
    return PrescriptionDetails(
      description: description ?? this.description,
      medicine: medicine ?? this.medicine,
      medicineId: medicineId ?? this.medicineId,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'description': description});
    result.addAll({'medicine': medicine});
    result.addAll({'medicineId': medicineId});
    result.addAll({'quantity': quantity});

    return result;
  }

  factory PrescriptionDetails.fromMap(Map<String, dynamic> map) {
    return PrescriptionDetails(
      description: map['description'] ?? '',
      medicine: map['medicine'] ?? '',
      medicineId: map['medicine_id'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'medicine': medicine,
      'medicine_id': medicineId,
      'quantity': quantity,
    };
  }

  factory PrescriptionDetails.fromJson(String source) => PrescriptionDetails.fromMap(json.decode(source));

  factory PrescriptionDetails.empty() {
    return PrescriptionDetails(description: '', medicine: '', medicineId: '', quantity: 0);
  }
  @override
  String toString() {
    return 'PrescriptionDetails(description: $description, medicine: $medicine, medicineId: $medicineId, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PrescriptionDetails &&
        other.description == description &&
        other.medicine == medicine &&
        other.medicineId == medicineId &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return description.hashCode ^ medicine.hashCode ^ medicineId.hashCode ^ quantity.hashCode;
  }
}
