import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:health_care/models/dependents.dart';

class MedicalRecords {
  final DateTime createdAt;
  final DateTime date;
  final String dependentId;
  final Dependents? dependentProfile;
  final String description;
  final String documentLink;
  final String firstName;
  final String fullName;
  final String hospitalName;
  final int medicalId;
  final bool isForDependent;
  final String lastName;
  final String symptoms;
  final DateTime updateAt;
  final String userId;
  final String? id;

  MedicalRecords({
    required this.createdAt,
    required this.date,
    required this.dependentId,
    required this.dependentProfile,
    required this.description,
    required this.documentLink,
    required this.firstName,
    required this.fullName,
    required this.hospitalName,
    required this.medicalId,
    required this.isForDependent,
    required this.lastName,
    required this.symptoms,
    required this.updateAt,
    required this.userId,
    required this.id,
  });

  MedicalRecords copyWith({
    DateTime? createdAt,
    DateTime? date,
    String? dependentId,
    Dependents? dependentProfile,
    String? description,
    String? documentLink,
    String? firstName,
    String? fullName,
    String? hospitalName,
    int? medicalId,
    bool? isForDependent,
    String? lastName,
    String? symptoms,
    DateTime? updateAt,
    String? userId,
    String? id,
  }) {
    return MedicalRecords(
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      dependentId: dependentId ?? this.dependentId,
      dependentProfile: dependentProfile ?? this.dependentProfile,
      description: description ?? this.description,
      documentLink: documentLink ?? this.documentLink,
      firstName: firstName ?? this.firstName,
      fullName: fullName ?? this.fullName,
      hospitalName: hospitalName ?? this.hospitalName,
      medicalId: medicalId ?? this.medicalId,
      isForDependent: isForDependent ?? this.isForDependent,
      lastName: lastName ?? this.lastName,
      symptoms: symptoms ?? this.symptoms,
      updateAt: updateAt ?? this.updateAt,
      userId: userId ?? this.userId,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    final bangkokDate = date.toUtc().add(const Duration(hours: 7));
    final formatted = DateFormat('dd MMM yyyy HH:mm').format(bangkokDate);
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'date': formatted});
    result.addAll({'dependentId': dependentId});
    if (dependentProfile != null) {
      result.addAll({'dependentProfile': dependentProfile!.toMap()});
    }
    result.addAll({'description': description});
    result.addAll({'documentLink': documentLink});
    result.addAll({'firstName': firstName});
    result.addAll({'fullName': fullName});
    result.addAll({'hospitalName': hospitalName});
    result.addAll({'medicalId': medicalId});
    result.addAll({'isForDependent': isForDependent});
    result.addAll({'lastName': lastName});
    result.addAll({'symptoms': symptoms});
    result.addAll({'updateAt': updateAt.millisecondsSinceEpoch});
    result.addAll({'userId': userId});
    if (id != null) {
      result.addAll({'id': id});
    }

    return result;
  }

  factory MedicalRecords.fromMap(Map<String, dynamic> map) {
    return MedicalRecords(
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      dependentId: map['dependentId'] ?? '',
      dependentProfile: map['dependentProfile'] != null ? Dependents.fromMap(map['dependentProfile']) : null,
      description: map['description'] ?? '',
      documentLink: map['documentLink'] ?? '',
      firstName: map['firstName'] ?? '',
      fullName: map['fullName'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      medicalId: map['id']?.toInt() ?? 0,
      isForDependent: map['isForDependent'] ?? false,
      lastName: map['lastName'] ?? '',
      symptoms: map['symptoms'] ?? '',
      updateAt: map['updateAt'] != null ? DateTime.parse(map['updateAt']) : DateTime.now(),
      userId: map['userId'] ?? '',
      id: map['_id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MedicalRecords.fromJson(String source) => MedicalRecords.fromMap(json.decode(source));

  factory MedicalRecords.empty({String firstName = '', String lastName = '', String userId = ''}) {
    return MedicalRecords(
      createdAt: DateTime.now(),
      date: DateTime.now(),
      dependentId: '',
      dependentProfile: Dependents.empty(),
      description: '',
      documentLink: '',
      firstName: firstName,
      fullName: '$firstName $lastName',
      hospitalName: '',
      medicalId: 0,
      isForDependent: false,
      lastName: lastName,
      symptoms: '',
      updateAt: DateTime.now(),
      userId: userId,
      id: '',
    );
  }

  @override
  String toString() {
    return 'MedicalRecords(createdAt: $createdAt, date: $date, dependentId: $dependentId, dependentProfile: $dependentProfile, description: $description, documentLink: $documentLink, firstName: $firstName, fullName: $fullName, hospitalName: $hospitalName, medicalId: $medicalId, isForDependent: $isForDependent, lastName: $lastName, symptoms: $symptoms, updateAt: $updateAt, userId: $userId, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MedicalRecords &&
        other.createdAt == createdAt &&
        other.date == date &&
        other.dependentId == dependentId &&
        other.dependentProfile == dependentProfile &&
        other.description == description &&
        other.documentLink == documentLink &&
        other.firstName == firstName &&
        other.fullName == fullName &&
        other.hospitalName == hospitalName &&
        other.medicalId == medicalId &&
        other.isForDependent == isForDependent &&
        other.lastName == lastName &&
        other.symptoms == symptoms &&
        other.updateAt == updateAt &&
        other.userId == userId &&
        other.id == id;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        date.hashCode ^
        dependentId.hashCode ^
        dependentProfile.hashCode ^
        description.hashCode ^
        documentLink.hashCode ^
        firstName.hashCode ^
        fullName.hashCode ^
        hospitalName.hashCode ^
        medicalId.hashCode ^
        isForDependent.hashCode ^
        lastName.hashCode ^
        symptoms.hashCode ^
        updateAt.hashCode ^
        userId.hashCode ^
        id.hashCode;
  }
}
