import 'dart:convert';

import 'package:flutter/foundation.dart';

class Patients {
  final String accessToken;
  final String userId;
  final String services;
  final String roleName;
  final PatientUserProfile userProfile;

  Patients({
    required this.accessToken,
    required this.userId,
    required this.services,
    required this.roleName,
    required this.userProfile,
  });

  Patients copyWith({
    String? accessToken,
    String? userId,
    String? services,
    String? roleName,
    PatientUserProfile? userProfile,
  }) {
    return Patients(
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
      services: services ?? this.services,
      roleName: roleName ?? this.roleName,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'accessToken': accessToken});
    result.addAll({'userId': userId});
    result.addAll({'services': services});
    result.addAll({'roleName': roleName});
    result.addAll({'userProfile': userProfile.toMap()});
  
    return result;
  }

  factory Patients.fromMap(Map<String, dynamic> map) {
    return Patients(
      accessToken: map['accessToken'] ?? '',
      userId: map['user_id'] ?? '',
      services: map['services'] ?? '',
      roleName: map['roleName'] ?? '',
      userProfile: PatientUserProfile.fromMap(map['userProfile']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Patients.fromJson(String source) => Patients.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Patients(accessToken: $accessToken, userId: $userId, services: $services, roleName: $roleName, userProfile: $userProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Patients &&
      other.accessToken == accessToken &&
      other.userId == userId &&
      other.services == services &&
      other.roleName == roleName &&
      other.userProfile == userProfile;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
      userId.hashCode ^
      services.hashCode ^
      roleName.hashCode ^
      userProfile.hashCode;
  }
}

class PatientUserProfile {
  final String createdAt;
  final String firstName;
  final String lastName;
  final String dob;
  final String bloodG;
  final String userName;
  final String mobileNumber;
  final String profileImage;
  final String gender;
  final String address1;
  final String address2;
  final String updatedAt;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isActive;
  final List<dynamic> invoiceIds;
  final List<dynamic> reviewsArray;
  final List<dynamic> rateArray;
  final String lastUpdate;
  final bool online;

  PatientUserProfile({
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.bloodG,
    required this.userName,
    required this.mobileNumber,
    required this.profileImage,
    required this.gender,
    required this.address1,
    required this.address2,
    required this.updatedAt,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.isActive,
    required this.invoiceIds,
    required this.reviewsArray,
    required this.rateArray,
    required this.lastUpdate,
    required this.online,
  });

  PatientUserProfile copyWith({
    String? createdAt,
    String? firstName,
    String? lastName,
    String? dob,
    String? bloodG,
    String? userName,
    String? mobileNumber,
    String? profileImage,
    String? gender,
    String? address1,
    String? address2,
    String? updatedAt,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isActive,
    List<dynamic>? invoiceIds,
    List<dynamic>? reviewsArray,
    List<dynamic>? rateArray,
    String? lastUpdate,
    bool? online,
  }) {
    return PatientUserProfile(
      createdAt: createdAt ?? this.createdAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      bloodG: bloodG ?? this.bloodG,
      userName: userName ?? this.userName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      profileImage: profileImage ?? this.profileImage,
      gender: gender ?? this.gender,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      updatedAt: updatedAt ?? this.updatedAt,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isActive: isActive ?? this.isActive,
      invoiceIds: invoiceIds ?? this.invoiceIds,
      reviewsArray: reviewsArray ?? this.reviewsArray,
      rateArray: rateArray ?? this.rateArray,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      online: online ?? this.online,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'createdAt': createdAt});
    result.addAll({'firstName': firstName});
    result.addAll({'lastName': lastName});
    result.addAll({'dob': dob});
    result.addAll({'bloodG': bloodG});
    result.addAll({'userName': userName});
    result.addAll({'mobileNumber': mobileNumber});
    result.addAll({'profileImage': profileImage});
    result.addAll({'gender': gender});
    result.addAll({'address1': address1});
    result.addAll({'address2': address2});
    result.addAll({'updatedAt': updatedAt});
    result.addAll({'city': city});
    result.addAll({'state': state});
    result.addAll({'zipCode': zipCode});
    result.addAll({'country': country});
    result.addAll({'isActive': isActive});
    result.addAll({'invoiceIds': invoiceIds});
    result.addAll({'reviewsArray': reviewsArray});
    result.addAll({'rateArray': rateArray});
    result.addAll({'lastUpdate': lastUpdate});
    result.addAll({'online': online});
  
    return result;
  }

  factory PatientUserProfile.fromMap(Map<String, dynamic> map) {
    return PatientUserProfile(
      createdAt: map['createdAt'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dob: map['dob'] ?? '',
      bloodG: map['bloodG'] ?? '',
      userName: map['userName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      profileImage: map['profileImage'] ?? '',
      gender: map['gender'] ?? '',
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      country: map['country'] ?? '',
      isActive: map['isActive'] ?? false,
      invoiceIds: List<dynamic>.from(map['invoice_ids']),
      reviewsArray: List<dynamic>.from(map['reviews_array']),
      rateArray: List<dynamic>.from(map['rate_array']),
      lastUpdate: map['lastUpdate'] ?? '',
      online: map['online'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientUserProfile.fromJson(String source) => PatientUserProfile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PatientUserProfile(createdAt: $createdAt, firstName: $firstName, lastName: $lastName, dob: $dob, bloodG: $bloodG, userName: $userName, mobileNumber: $mobileNumber, profileImage: $profileImage, gender: $gender, address1: $address1, address2: $address2, updatedAt: $updatedAt, city: $city, state: $state, zipCode: $zipCode, country: $country, isActive: $isActive, invoiceIds: $invoiceIds, reviewsArray: $reviewsArray, rateArray: $rateArray, lastUpdate: $lastUpdate, online: $online)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PatientUserProfile &&
      other.createdAt == createdAt &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.dob == dob &&
      other.bloodG == bloodG &&
      other.userName == userName &&
      other.mobileNumber == mobileNumber &&
      other.profileImage == profileImage &&
      other.gender == gender &&
      other.address1 == address1 &&
      other.address2 == address2 &&
      other.updatedAt == updatedAt &&
      other.city == city &&
      other.state == state &&
      other.zipCode == zipCode &&
      other.country == country &&
      other.isActive == isActive &&
      listEquals(other.invoiceIds, invoiceIds) &&
      listEquals(other.reviewsArray, reviewsArray) &&
      listEquals(other.rateArray, rateArray) &&
      other.lastUpdate == lastUpdate &&
      other.online == online;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      dob.hashCode ^
      bloodG.hashCode ^
      userName.hashCode ^
      mobileNumber.hashCode ^
      profileImage.hashCode ^
      gender.hashCode ^
      address1.hashCode ^
      address2.hashCode ^
      updatedAt.hashCode ^
      city.hashCode ^
      state.hashCode ^
      zipCode.hashCode ^
      country.hashCode ^
      isActive.hashCode ^
      invoiceIds.hashCode ^
      reviewsArray.hashCode ^
      rateArray.hashCode ^
      lastUpdate.hashCode ^
      online.hashCode;
  }
}
