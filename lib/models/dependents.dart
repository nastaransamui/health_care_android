import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

class Dependents {
  final String bloodG;
  final DateTime createdAt;
  final dynamic dob;
  final String firstName;
  final String fullName;
  final String gender;
  final int dependentId;
  final bool isActive;
  final String lastName;
  final List<String> medicalRecordsArray;
  final String profileImage;
  final String relationShip;
  final DateTime updateAt;
  final String userId;
  final String? id;

  Dependents({
    required this.bloodG,
    required this.createdAt,
    required this.dob,
    required this.firstName,
    required this.fullName,
    required this.gender,
    required this.dependentId,
    required this.isActive,
    required this.lastName,
    required this.medicalRecordsArray,
    required this.profileImage,
    required this.relationShip,
    required this.updateAt,
    required this.userId,
    required this.id,
  });

  Dependents copyWith({
    String? bloodG,
    DateTime? createdAt,
    dynamic dob,
    String? firstName,
    String? fullName,
    String? gender,
    int? dependentId,
    bool? isActive,
    String? lastName,
    List<String>? medicalRecordsArray,
    String? profileImage,
    String? relationShip,
    DateTime? updateAt,
    String? userId,
    String? id,
  }) {
    return Dependents(
      bloodG: bloodG ?? this.bloodG,
      createdAt: createdAt ?? this.createdAt,
      dob: dob ?? this.dob,
      firstName: firstName ?? this.firstName,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dependentId: dependentId ?? this.dependentId,
      isActive: isActive ?? this.isActive,
      lastName: lastName ?? this.lastName,
      medicalRecordsArray: medicalRecordsArray ?? this.medicalRecordsArray,
      profileImage: profileImage ?? this.profileImage,
      relationShip: relationShip ?? this.relationShip,
      updateAt: updateAt ?? this.updateAt,
      userId: userId ?? this.userId,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    final formattedCreatedAt = DateFormat('dd MMM yyyy HH:mm').format(createdAt.toUtc().add(const Duration(hours: 7)));
    final formattedUpdateAt = DateFormat('dd MMM yyyy HH:mm').format(updateAt.toUtc().add(const Duration(hours: 7)));
    final formattedDob = dob == '' ? '' : DateFormat('dd MMM yyyy').format(dob.toUtc().add(const Duration(hours: 7)));
    result.addAll({'bloodG': bloodG});
    result.addAll({'createdAt': formattedCreatedAt});
    result.addAll({'dob': formattedDob});
    result.addAll({'firstName': firstName});
    result.addAll({'fullName': fullName});
    result.addAll({'gender': gender});
    result.addAll({'dependentId': dependentId});
    result.addAll({'isActive': isActive});
    result.addAll({'lastName': lastName});
    result.addAll({'medicalRecordsArray': medicalRecordsArray});
    result.addAll({'profileImage': profileImage});
    result.addAll({'relationShip': relationShip});
    result.addAll({'updateAt': formattedUpdateAt});
    result.addAll({'userId': userId});
    if (id != null) {
      result.addAll({'id': id});
    }

    return result;
  }

  factory Dependents.fromMap(Map<String, dynamic> map) {
    return Dependents(
      bloodG: map['bloodG'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      dob: map['dob'] == '' ? '' : DateTime.parse(map['dob']),
      firstName: map['firstName'] ?? '',
      fullName: map['fullName'] ?? '',
      gender: map['gender'] ?? '',
      dependentId: map['id']?.toInt() ?? 0,
      isActive: map['isActive'] ?? false,
      lastName: map['lastName'] ?? '',
      medicalRecordsArray: List<String>.from(map['medicalRecordsArray']),
      profileImage: map['profileImage'] ?? '',
      relationShip: map['relationShip'] ?? '',
      updateAt: map['updateAt'] != null ? DateTime.parse(map['updateAt']) : DateTime.now(),
      userId: map['userId'] ?? '',
      id: map['_id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Dependents.fromJson(String source) => Dependents.fromMap(json.decode(source));

  factory Dependents.empty({String userId = ''}) {
    return Dependents(
      bloodG: '',
      createdAt: DateTime.now(),
      dob: '',
      firstName: '',
      fullName: '',
      gender: '',
      dependentId: 0,
      isActive: true,
      lastName: '',
      medicalRecordsArray: [],
      profileImage: '',
      relationShip: '',
      updateAt: DateTime.now(),
      userId: userId,
      id: '',
    );
  }

  @override
  String toString() {
    return 'Dependents(bloodG: $bloodG, createdAt: $createdAt, dob: $dob, firstName: $firstName, fullName: $fullName, gender: $gender, dependentId: $dependentId, isActive: $isActive, lastName: $lastName, medicalRecordsArray: $medicalRecordsArray, profileImage: $profileImage, relationShip: $relationShip, updateAt: $updateAt, userId: $userId, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Dependents &&
        other.bloodG == bloodG &&
        other.createdAt == createdAt &&
        other.dob == dob &&
        other.firstName == firstName &&
        other.fullName == fullName &&
        other.gender == gender &&
        other.dependentId == dependentId &&
        other.isActive == isActive &&
        other.lastName == lastName &&
        listEquals(other.medicalRecordsArray, medicalRecordsArray) &&
        other.profileImage == profileImage &&
        other.relationShip == relationShip &&
        other.updateAt == updateAt &&
        other.userId == userId &&
        other.id == id;
  }

  @override
  int get hashCode {
    return bloodG.hashCode ^
        createdAt.hashCode ^
        dob.hashCode ^
        firstName.hashCode ^
        fullName.hashCode ^
        gender.hashCode ^
        dependentId.hashCode ^
        isActive.hashCode ^
        lastName.hashCode ^
        medicalRecordsArray.hashCode ^
        profileImage.hashCode ^
        relationShip.hashCode ^
        updateAt.hashCode ^
        userId.hashCode ^
        id.hashCode;
  }
}
