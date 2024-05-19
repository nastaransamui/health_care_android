import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:health_care/models/doctors.dart';
import 'package:health_care/models/specialities.dart';

class PatientsProfile {
  final String accessToken;
  final String userId;
  final String services;
  final String roleName;
  final PatientUserProfile userProfile;

  PatientsProfile({
    required this.accessToken,
    required this.userId,
    required this.services,
    required this.roleName,
    required this.userProfile,
  });

  PatientsProfile copyWith({
    String? accessToken,
    String? userId,
    String? services,
    String? roleName,
    PatientUserProfile? userProfile,
  }) {
    return PatientsProfile(
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

  factory PatientsProfile.fromMap(Map<String, dynamic> map) {
    return PatientsProfile(
      accessToken: map['accessToken'] ?? '',
      userId: map['user_id'] ?? '',
      services: map['services'] ?? '',
      roleName: map['roleName'] ?? '',
      userProfile: PatientUserProfile.fromMap(map['userProfile']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientsProfile.fromJson(String source) =>
      PatientsProfile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Patients(accessToken: $accessToken, userId: $userId, services: $services, roleName: $roleName, userProfile: $userProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatientsProfile &&
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
  final bool idle;
  final LastLogin lastLogin;

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
    required this.idle,
    required this.lastLogin,
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
    bool? idle,
    LastLogin? lastLogin,
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
      idle: idle ?? this.idle,
      lastLogin: lastLogin ?? this.lastLogin,
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
    result.addAll({'idle': idle});
    result.addAll({'lastLogin': lastLogin.toMap()});

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
      idle: map['idle'] ?? false,
      lastLogin: LastLogin.fromMap(map['lastLogin']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientUserProfile.fromJson(String source) =>
      PatientUserProfile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PatientUserProfile(createdAt: $createdAt, firstName: $firstName, lastName: $lastName, dob: $dob, bloodG: $bloodG, userName: $userName, mobileNumber: $mobileNumber, profileImage: $profileImage, gender: $gender, address1: $address1, address2: $address2, updatedAt: $updatedAt, city: $city, state: $state, zipCode: $zipCode, country: $country, isActive: $isActive, invoiceIds: $invoiceIds, reviewsArray: $reviewsArray, rateArray: $rateArray, lastUpdate: $lastUpdate, online: $online, idle: $idle, lastLogin: $lastLogin)';
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
        other.online == online &&
        other.idle == idle &&
        other.lastLogin == lastLogin;
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
        online.hashCode ^
        idle.hashCode ^
        lastLogin.hashCode;
  }
}

class LastLogin {
  final String date;
  final String ipAddr;
  final String userAgent;

  LastLogin({
    required this.date,
    required this.ipAddr,
    required this.userAgent,
  });

  LastLogin copyWith({
    String? date,
    String? ipAddr,
    String? userAgent,
  }) {
    return LastLogin(
      date: date ?? this.date,
      ipAddr: ipAddr ?? this.ipAddr,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'date': date});
    result.addAll({'ipAddr': ipAddr});
    result.addAll({'userAgent': userAgent});

    return result;
  }

  factory LastLogin.fromMap(Map<String, dynamic> map) {
    return LastLogin(
      date: map['date'] ?? '',
      ipAddr: map['ipAddr'] ?? '',
      userAgent: map['userAgent'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory LastLogin.fromJson(String source) =>
      LastLogin.fromMap(json.decode(source));

  @override
  String toString() =>
      'LastLogin(date: $date, ipAddr: $ipAddr, userAgent: $userAgent)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LastLogin &&
        other.date == date &&
        other.ipAddr == ipAddr &&
        other.userAgent == userAgent;
  }

  @override
  int get hashCode => date.hashCode ^ ipAddr.hashCode ^ userAgent.hashCode;
}

class DoctorsProfile {
  final String accessToken;
  final String userId;
  final String services;
  final String roleName;
  final DoctorUserProfile userProfile;

  DoctorsProfile({
    required this.accessToken,
    required this.userId,
    required this.services,
    required this.roleName,
    required this.userProfile,
  });

  DoctorsProfile copyWith({
    String? accessToken,
    String? userId,
    String? services,
    String? roleName,
    DoctorUserProfile? userProfile,
  }) {
    return DoctorsProfile(
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

  factory DoctorsProfile.fromMap(Map<String, dynamic> map) {
    return DoctorsProfile(
      accessToken: map['accessToken'] ?? '',
      userId: map['user_id'] ?? '',
      services: map['services'] ?? '',
      roleName: map['roleName'] ?? '',
      userProfile: DoctorUserProfile.fromMap(map['userProfile']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DoctorsProfile.fromJson(String source) => DoctorsProfile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Doctors(accessToken: $accessToken, userId: $userId, services: $services, roleName: $roleName, userProfile: $userProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is DoctorsProfile &&
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

class DoctorUserProfile {
  final String createdAt;
  final String userName;
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String gender;
  final String dob;
  final String clinicName;
  final String clinicAddress;
  final String aboutMe;
  final List<ClinicImages> clinicImages;
  final String profileImage;
  final String roleName;
  final String services;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final List<dynamic> pricing;
  final List<dynamic> specialitiesServices;
  final List<Specialities> specialities;
  final List<Education> educations;
  final List<Experinces> experinces;
  final List<Award> awards;
  final List<Memberships> memberships;
  final List<dynamic> socialMedia;
  final List<Registrations> registrations;
  final String accessToken;
  final bool isActive;
  final List<dynamic> invoiceIds;
  final List<dynamic> reviewsArray;
  final List<dynamic> rateArray;
  final List<dynamic> timeSlotId;
  final List<dynamic> patientsId;
  final List<dynamic> favsId;
  final List<dynamic> reservationsId;
  final List<dynamic> prescriptionsId;
  final String lastUpdate;
  final String id;
  final LastLogin lastLogin;
  final bool online;
  final bool idle;

  DoctorUserProfile({
    required this.createdAt,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.gender,
    required this.dob,
    required this.clinicName,
    required this.clinicAddress,
    required this.aboutMe,
    required this.clinicImages,
    required this.profileImage,
    required this.roleName,
    required this.services,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.pricing,
    required this.specialitiesServices,
    required this.specialities,
    required this.educations,
    required this.experinces,
    required this.awards,
    required this.memberships,
    required this.socialMedia,
    required this.registrations,
    required this.accessToken,
    required this.isActive,
    required this.invoiceIds,
    required this.reviewsArray,
    required this.rateArray,
    required this.timeSlotId,
    required this.patientsId,
    required this.favsId,
    required this.reservationsId,
    required this.prescriptionsId,
    required this.lastUpdate,
    required this.id,
    required this.lastLogin,
    required this.online,
    required this.idle,
  });

  DoctorUserProfile copyWith({
    String? createdAt,
    String? userName,
    String? firstName,
    String? lastName,
    String? mobileNumber,
    String? gender,
    String? dob,
    String? clinicName,
    String? clinicAddress,
    String? aboutMe,
    List<ClinicImages>? clinicImages,
    String? profileImage,
    String? roleName,
    String? services,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    List<dynamic>? pricing,
    List<dynamic>? specialitiesServices,
    List<Specialities>? specialities,
    List<Education>? educations,
    List<Experinces>? experinces,
    List<Award>? awards,
    List<Memberships>? memberships,
    List<dynamic>? socialMedia,
    List<Registrations>? registrations,
    String? accessToken,
    bool? isActive,
    List<dynamic>? invoiceIds,
    List<dynamic>? reviewsArray,
    List<dynamic>? rateArray,
    List<dynamic>? timeSlotId,
    List<dynamic>? patientsId,
    List<dynamic>? favsId,
    List<dynamic>? reservationsId,
    List<dynamic>? prescriptionsId,
    String? lastUpdate,
    String? id,
    LastLogin? lastLogin,
    bool? online,
    bool? idle,
  }) {
    return DoctorUserProfile(
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      aboutMe: aboutMe ?? this.aboutMe,
      clinicImages: clinicImages ?? this.clinicImages,
      profileImage: profileImage ?? this.profileImage,
      roleName: roleName ?? this.roleName,
      services: services ?? this.services,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      pricing: pricing ?? this.pricing,
      specialitiesServices: specialitiesServices ?? this.specialitiesServices,
      specialities: specialities ?? this.specialities,
      educations: educations ?? this.educations,
      experinces: experinces ?? this.experinces,
      awards: awards ?? this.awards,
      memberships: memberships ?? this.memberships,
      socialMedia: socialMedia ?? this.socialMedia,
      registrations: registrations ?? this.registrations,
      accessToken: accessToken ?? this.accessToken,
      isActive: isActive ?? this.isActive,
      invoiceIds: invoiceIds ?? this.invoiceIds,
      reviewsArray: reviewsArray ?? this.reviewsArray,
      rateArray: rateArray ?? this.rateArray,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      patientsId: patientsId ?? this.patientsId,
      favsId: favsId ?? this.favsId,
      reservationsId: reservationsId ?? this.reservationsId,
      prescriptionsId: prescriptionsId ?? this.prescriptionsId,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      id: id ?? this.id,
      lastLogin: lastLogin ?? this.lastLogin,
      online: online ?? this.online,
      idle: idle ?? this.idle,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'createdAt': createdAt});
    result.addAll({'userName': userName});
    result.addAll({'firstName': firstName});
    result.addAll({'lastName': lastName});
    result.addAll({'mobileNumber': mobileNumber});
    result.addAll({'gender': gender});
    result.addAll({'dob': dob});
    result.addAll({'clinicName': clinicName});
    result.addAll({'clinicAddress': clinicAddress});
    result.addAll({'aboutMe': aboutMe});
    result
        .addAll({'clinicImages': clinicImages.map((x) => x.toMap()).toList()});
    result.addAll({'profileImage': profileImage});
    result.addAll({'roleName': roleName});
    result.addAll({'services': services});
    result.addAll({'address1': address1});
    result.addAll({'address2': address2});
    result.addAll({'city': city});
    result.addAll({'state': state});
    result.addAll({'zipCode': zipCode});
    result.addAll({'country': country});
    result.addAll({'pricing': pricing});
    result.addAll({'specialitiesServices': specialitiesServices});
    result
        .addAll({'specialities': specialities.map((x) => x.toMap()).toList()});
    result.addAll({'educations': educations.map((x) => x.toMap()).toList()});
    result.addAll({'experinces': experinces.map((x) => x.toMap()).toList()});
    result.addAll({'awards': awards.map((x) => x.toMap()).toList()});
    result.addAll({'memberships': memberships.map((x) => x.toMap()).toList()});
    result.addAll({'socialMedia': socialMedia});
    result.addAll(
        {'registrations': registrations.map((x) => x.toMap()).toList()});
    result.addAll({'accessToken': accessToken});
    result.addAll({'isActive': isActive});
    result.addAll({'invoiceIds': invoiceIds});
    result.addAll({'reviewsArray': reviewsArray});
    result.addAll({'rateArray': rateArray});
    result.addAll({'timeSlotId': timeSlotId});
    result.addAll({'patientsId': patientsId});
    result.addAll({'favsId': favsId});
    result.addAll({'reservationsId': reservationsId});
    result.addAll({'prescriptionsId': prescriptionsId});
    result.addAll({'lastUpdate': lastUpdate});
    result.addAll({'id': id});
    result.addAll({'lastLogin': lastLogin.toMap()});
    result.addAll({'online': online});
    result.addAll({'idle': idle});

    return result;
  }

  factory DoctorUserProfile.fromMap(Map<String, dynamic> map) {
    return DoctorUserProfile(
      createdAt: map['createdAt'] ?? '',
      userName: map['userName'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      gender: map['gender'] ?? '',
      dob: map['dob'] ?? '',
      clinicName: map['clinicName'] ?? '',
      clinicAddress: map['clinicAddress'] ?? '',
      aboutMe: map['aboutMe'] ?? '',
      clinicImages: List<ClinicImages>.from(
          map['clinicImages']?.map((x) => ClinicImages.fromMap(x))),
      profileImage: map['profileImage'] ?? '',
      roleName: map['roleName'] ?? '',
      services: map['services'] ?? '',
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      country: map['country'] ?? '',
      pricing: List<dynamic>.from(map['pricing']),
      specialitiesServices: List<dynamic>.from(map['specialitiesServices']),
      specialities: List<Specialities>.from(
          map['specialities']?.map((x) => Specialities.fromMap(x))),
      educations: List<Education>.from(
          map['educations']?.map((x) => Education.fromMap(x))),
      experinces: List<Experinces>.from(
          map['experinces']?.map((x) => Experinces.fromMap(x))),
      awards: List<Award>.from(map['awards']?.map((x) => Award.fromMap(x))),
      memberships: List<Memberships>.from(
          map['memberships']?.map((x) => Memberships.fromMap(x))),
      socialMedia: List<dynamic>.from(map['socialMedia']),
      registrations: List<Registrations>.from(
          map['registrations']?.map((x) => Registrations.fromMap(x))),
      accessToken: map['accessToken'] ?? '',
      isActive: map['isActive'] ?? false,
      invoiceIds: List<dynamic>.from(map['invoice_ids']),
      reviewsArray: List<dynamic>.from(map['reviews_array']),
      rateArray: List<dynamic>.from(map['rate_array']),
      timeSlotId: List<dynamic>.from(map['timeSlotId']),
      patientsId: List<dynamic>.from(map['patients_id']),
      favsId: List<dynamic>.from(map['favs_id']),
      reservationsId: List<dynamic>.from(map['reservations_id']),
      prescriptionsId: List<dynamic>.from(map['prescriptions_id']),
      lastUpdate: map['lastUpdate'] ?? '',
      id: map['id'] ?? '',
      lastLogin: LastLogin.fromMap(map['lastLogin']),
      online: map['online'] ?? false,
      idle: map['idle'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory DoctorUserProfile.fromJson(String source) =>
      DoctorUserProfile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DoctorUserProfile(createdAt: $createdAt, userName: $userName, firstName: $firstName, lastName: $lastName, mobileNumber: $mobileNumber, gender: $gender, dob: $dob, clinicName: $clinicName, clinicAddress: $clinicAddress, aboutMe: $aboutMe, clinicImages: $clinicImages, profileImage: $profileImage, roleName: $roleName, services: $services, address1: $address1, address2: $address2, city: $city, state: $state, zipCode: $zipCode, country: $country, pricing: $pricing, specialitiesServices: $specialitiesServices, specialities: $specialities, educations: $educations, experinces: $experinces, awards: $awards, memberships: $memberships, socialMedia: $socialMedia, registrations: $registrations, accessToken: $accessToken, isActive: $isActive, invoiceIds: $invoiceIds, reviewsArray: $reviewsArray, rateArray: $rateArray, timeSlotId: $timeSlotId, patientsId: $patientsId, favsId: $favsId, reservationsId: $reservationsId, prescriptionsId: $prescriptionsId, lastUpdate: $lastUpdate, id: $id, lastLogin: $lastLogin, online: $online, idle: $idle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DoctorUserProfile &&
        other.createdAt == createdAt &&
        other.userName == userName &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.mobileNumber == mobileNumber &&
        other.gender == gender &&
        other.dob == dob &&
        other.clinicName == clinicName &&
        other.clinicAddress == clinicAddress &&
        other.aboutMe == aboutMe &&
        listEquals(other.clinicImages, clinicImages) &&
        other.profileImage == profileImage &&
        other.roleName == roleName &&
        other.services == services &&
        other.address1 == address1 &&
        other.address2 == address2 &&
        other.city == city &&
        other.state == state &&
        other.zipCode == zipCode &&
        other.country == country &&
        listEquals(other.pricing, pricing) &&
        listEquals(other.specialitiesServices, specialitiesServices) &&
        listEquals(other.specialities, specialities) &&
        listEquals(other.educations, educations) &&
        listEquals(other.experinces, experinces) &&
        listEquals(other.awards, awards) &&
        listEquals(other.memberships, memberships) &&
        listEquals(other.socialMedia, socialMedia) &&
        listEquals(other.registrations, registrations) &&
        other.accessToken == accessToken &&
        other.isActive == isActive &&
        listEquals(other.invoiceIds, invoiceIds) &&
        listEquals(other.reviewsArray, reviewsArray) &&
        listEquals(other.rateArray, rateArray) &&
        listEquals(other.timeSlotId, timeSlotId) &&
        listEquals(other.patientsId, patientsId) &&
        listEquals(other.favsId, favsId) &&
        listEquals(other.reservationsId, reservationsId) &&
        listEquals(other.prescriptionsId, prescriptionsId) &&
        other.lastUpdate == lastUpdate &&
        other.id == id &&
        other.lastLogin == lastLogin &&
        other.online == online &&
        other.idle == idle;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        userName.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        mobileNumber.hashCode ^
        gender.hashCode ^
        dob.hashCode ^
        clinicName.hashCode ^
        clinicAddress.hashCode ^
        aboutMe.hashCode ^
        clinicImages.hashCode ^
        profileImage.hashCode ^
        roleName.hashCode ^
        services.hashCode ^
        address1.hashCode ^
        address2.hashCode ^
        city.hashCode ^
        state.hashCode ^
        zipCode.hashCode ^
        country.hashCode ^
        pricing.hashCode ^
        specialitiesServices.hashCode ^
        specialities.hashCode ^
        educations.hashCode ^
        experinces.hashCode ^
        awards.hashCode ^
        memberships.hashCode ^
        socialMedia.hashCode ^
        registrations.hashCode ^
        accessToken.hashCode ^
        isActive.hashCode ^
        invoiceIds.hashCode ^
        reviewsArray.hashCode ^
        rateArray.hashCode ^
        timeSlotId.hashCode ^
        patientsId.hashCode ^
        favsId.hashCode ^
        reservationsId.hashCode ^
        prescriptionsId.hashCode ^
        lastUpdate.hashCode ^
        id.hashCode ^
        lastLogin.hashCode ^
        online.hashCode ^
        idle.hashCode;
  }
}
