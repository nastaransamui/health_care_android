import 'dart:convert';


import 'package:health_care/models/doctors.dart';
import 'package:health_care/models/doctors_time_slot.dart';
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

  factory PatientsProfile.fromJson(String source) => PatientsProfile.fromMap(json.decode(source));

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
    return accessToken.hashCode ^ userId.hashCode ^ services.hashCode ^ roleName.hashCode ^ userProfile.hashCode;
  }
}

class PatientUserProfile {
  final String address1;
  final String address2;
  final List<String> billingsIds;
  final String bloodG;
  final String city;
  final String country;
  final DateTime createdAt;
  final List<String> dependentsArray;
  final dynamic dob;
  final List<String> doctorsId;
  final List<String> favsId;
  final String firstName;
  final String fullName;
  final String gender;
  final bool? idle;
  final List<String> invoiceIds;
  final bool isActive;
  final bool? isVerified;
  final LastLogin lastLogin;
  final String lastName;
  final DateTime lastUpdate;
  final List<String> medicalRecordsArray;
  final String mobileNumber;
  final bool online;
  final List<String> prescriptionsId;
  final String profileImage;
  final List<double> rateArray;
  final List<String> reservationsId;
  final List<String> reviewsArray;
  final String roleName;
  final String services;
  final String state;
  final String userName;
  final String zipCode;
  final String? id;
  final int patientsId;

  PatientUserProfile({
    required this.address1,
    required this.address2,
    required this.billingsIds,
    required this.bloodG,
    required this.city,
    required this.country,
    required this.createdAt,
    required this.dependentsArray,
    required this.dob,
    required this.doctorsId,
    required this.favsId,
    required this.firstName,
    required this.fullName,
    required this.gender,
    required this.idle,
    required this.invoiceIds,
    required this.isActive,
    required this.isVerified,
    required this.lastLogin,
    required this.lastName,
    required this.lastUpdate,
    required this.medicalRecordsArray,
    required this.mobileNumber,
    required this.online,
    required this.prescriptionsId,
    required this.profileImage,
    required this.rateArray,
    required this.reservationsId,
    required this.reviewsArray,
    required this.roleName,
    required this.services,
    required this.state,
    required this.userName,
    required this.zipCode,
    required this.id,
    required this.patientsId,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'address1': address1});
    result.addAll({'address2': address2});
    result.addAll({'billingsIds': billingsIds});
    result.addAll({'bloodG': bloodG});
    result.addAll({'city': city});
    result.addAll({'country': country});
    result.addAll({'createdAt': createdAt});
    result.addAll({'dependentsArray': dependentsArray});
    result.addAll({'dob': dob});
    result.addAll({'doctorsId': doctorsId});
    result.addAll({'favsId': favsId});
    result.addAll({'firstName': firstName});
    result.addAll({'fullName': fullName});
    result.addAll({'gender': gender});
    result.addAll({'idle': idle});
    result.addAll({'invoiceIds': invoiceIds});
    result.addAll({'isActive': isActive});
    result.addAll({'isVerified': isVerified});
    result.addAll({'lastLogin': lastLogin.toMap()});
    result.addAll({'lastName': lastName});
    result.addAll({'lastUpdate': lastUpdate});
    result.addAll({'medicalRecordsArray': medicalRecordsArray});
    result.addAll({'mobileNumber': mobileNumber});
    result.addAll({'online': online});
    result.addAll({'prescriptionsId': prescriptionsId});
    result.addAll({'profileImage': profileImage});
    result.addAll({'rateArray': rateArray});
    result.addAll({'reservationsId': reservationsId});
    result.addAll({'reviewsArray': reviewsArray});
    result.addAll({'roleName': roleName});
    result.addAll({'services': services});
    result.addAll({'state': state});
    result.addAll({'userName': userName});
    result.addAll({'zipCode': zipCode});
    result.addAll({'id': id});
    result.addAll({'patientsId': patientsId});

    return result;
  }

  factory PatientUserProfile.fromMap(Map<String, dynamic> map) {
    return PatientUserProfile(
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      billingsIds: List<String>.from(map['billingsIds'] ?? []),
      bloodG: map['bloodG'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      dependentsArray: List<String>.from(map['dependentsArray']?? []),
      dob: map['dob'] ?? '',
      doctorsId: List<String>.from(map['doctors_id']?? []),
      favsId: List<String>.from(map['favs_id']?? []),
      firstName: map['firstName'] ?? '',
      fullName: map['fullName'] ?? '',
      gender: map['gender'] ?? '',
      idle: map['idle'] ?? false,
      invoiceIds: List<String>.from(map['invoice_ids'] ?? []),
      isActive: map['isActive'] ?? false,
      isVerified: map['isVerified'] ?? false,
      lastLogin: map['lastLogin'] != null
    ? LastLogin.fromMap(map['lastLogin'])
    : LastLogin.defaultInstance(),
      lastName: map['lastName'] ?? '',
      lastUpdate: map['lastUpdate'] != null ? DateTime.parse(map['lastUpdate']) : DateTime.now(),
      medicalRecordsArray: List<String>.from(map['medicalRecordsArray']),
      mobileNumber: map['mobileNumber'] ?? '',
      online: map['online'] ?? false,
      prescriptionsId: List<String>.from(map['prescriptions_id']),
      profileImage: map['profileImage'] ?? '',
      rateArray: List<double>.from(map['rate_array']),
      reservationsId: List<String>.from(map['reservations_id']),
      reviewsArray: List<String>.from(map['reviews_array']),
      roleName: map['roleName'] ?? '',
      services: map['services'] ?? '',
      state: map['state'] ?? '',
      userName: map['userName'] ?? '',
      zipCode: map['zipCode'] ?? '',
      id: map['_id'] ?? '',
      patientsId: map['id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientUserProfile.fromJson(String source) => PatientUserProfile.fromMap(json.decode(source));



  PatientUserProfile copyWith({
    String? address1,
    String? address2,
    List<String>? billingsIds,
    String? bloodG,
    String? city,
    String? country,
    DateTime? createdAt,
    List<String>? dependentsArray,
    dynamic dob,
    List<String>? doctorsId,
    List<String>? favsId,
    String? firstName,
    String? fullName,
    String? gender,
    bool? idle,
    List<String>? invoiceIds,
    bool? isActive,
    bool? isVerified,
    LastLogin? lastLogin,
    String? lastName,
    DateTime? lastUpdate,
    List<String>? medicalRecordsArray,
    String? mobileNumber,
    bool? online,
    List<String>? prescriptionsId,
    String? profileImage,
    List<double>? rateArray,
    List<String>? reservationsId,
    List<String>? reviewsArray,
    String? roleName,
    String? services,
    String? state,
    String? userName,
    String? zipCode,
    String? id,
    int? patientsId,
  }) {
    return PatientUserProfile(
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      billingsIds: billingsIds ?? this.billingsIds,
      bloodG: bloodG ?? this.bloodG,
      city: city ?? this.city,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      dependentsArray: dependentsArray ?? this.dependentsArray,
      dob: dob ?? this.dob,
      doctorsId: doctorsId ?? this.doctorsId,
      favsId: favsId ?? this.favsId,
      firstName: firstName ?? this.firstName,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      idle: idle ?? this.idle,
      invoiceIds: invoiceIds ?? this.invoiceIds,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      lastLogin: lastLogin ?? this.lastLogin,
      lastName: lastName ?? this.lastName,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      medicalRecordsArray: medicalRecordsArray ?? this.medicalRecordsArray,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      online: online ?? this.online,
      prescriptionsId: prescriptionsId ?? this.prescriptionsId,
      profileImage: profileImage ?? this.profileImage,
      rateArray: rateArray ?? this.rateArray,
      reservationsId: reservationsId ?? this.reservationsId,
      reviewsArray: reviewsArray ?? this.reviewsArray,
      roleName: roleName ?? this.roleName,
      services: services ?? this.services,
      state: state ?? this.state,
      userName: userName ?? this.userName,
      zipCode: zipCode ?? this.zipCode,
      id: id ?? this.id,
      patientsId: patientsId ?? this.patientsId,
    );
  }

  @override
  String toString() {
    return 'PatientUserProfile(address1: $address1, address2: $address2, billingsIds: $billingsIds, bloodG: $bloodG, city: $city, country: $country, createdAt: $createdAt, dependentsArray: $dependentsArray, dob: $dob, doctorsId: $doctorsId, favsId: $favsId, firstName: $firstName, fullName: $fullName, gender: $gender, idle: $idle, invoiceIds: $invoiceIds, isActive: $isActive, isVerified: $isVerified, lastLogin: $lastLogin, lastName: $lastName, lastUpdate: $lastUpdate, medicalRecordsArray: $medicalRecordsArray, mobileNumber: $mobileNumber, online: $online, prescriptionsId: $prescriptionsId, profileImage: $profileImage, rateArray: $rateArray, reservationsId: $reservationsId, reviewsArray: $reviewsArray, roleName: $roleName, services: $services, state: $state, userName: $userName, zipCode: $zipCode, id: $id, patientsId: $patientsId)';
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

   factory LastLogin.defaultInstance() {
    return LastLogin(date: DateTime.now().toIso8601String(), ipAddr: 'Unknown', userAgent: 'Unknow');
  }

  String toJson() => json.encode(toMap());

  factory LastLogin.fromJson(String source) => LastLogin.fromMap(json.decode(source));

  @override
  String toString() => 'LastLogin(date: $date, ipAddr: $ipAddr, userAgent: $userAgent)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LastLogin && other.date == date && other.ipAddr == ipAddr && other.userAgent == userAgent;
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
    return accessToken.hashCode ^ userId.hashCode ^ services.hashCode ^ roleName.hashCode ^ userProfile.hashCode;
  }
}

class DoctorUserProfile {
  final String aboutMe;
  final String accessToken;
  final String address1;
  final String address2;
  final List<Award> awards;
  final String bankId;
  final List<String> billingsIds;
  final int bookingsFee;
  final String city;
  final String clinicAddress;
  final List<ClinicImages> clinicImages;
  final String clinicName;
  final String country;
  final DateTime createdAt;
  final List<Currency> currency;
  final dynamic dob;
  final List<Education> educations;
  final List<Experinces> experinces;
  final List<dynamic> favsId;
  final String firstName;
  final String fullName;
  final String gender;
  final bool? idle;
  final List<String> invoiceIds;
  final bool isActive;
  final bool? isVerified;
  final LastLogin lastLogin;
  final String lastName;
  final DateTime lastUpdate;
  final List<Memberships> memberships;
  final String mobileNumber;
  final String userName;
  final bool online;
  final List<String> patientsId;
  final List<String> prescriptionsId;
  final String profileImage;
  final List<double> rateArray;
  final List<int> recommendArray;
  final List<Registrations> registrations;
  final List<String> reviewsArray;
  final List<String> reservationsId;
  final String roleName;
  final String services;
  final List<SocialMedia> socialMedia;
  final List<Specialities> specialities;
  final List<String>? specialitiesServices;
  final String state;
  final List<String> timeSlotId;
  final List<DoctorsTimeSlot>? timeslots;
  final String zipCode;
  final String? id;
  final int doctorsId;

  DoctorUserProfile({
    required this.aboutMe,
    required this.accessToken,
    required this.address1,
    required this.address2,
    required this.awards,
    required this.bankId,
    required this.billingsIds,
    required this.bookingsFee,
    required this.city,
    required this.clinicAddress,
    required this.clinicImages,
    required this.clinicName,
    required this.country,
    required this.createdAt,
    required this.currency,
    required this.dob,
    required this.educations,
    required this.experinces,
    required this.favsId,
    required this.firstName,
    required this.fullName,
    required this.gender,
    required this.idle,
    required this.invoiceIds,
    required this.isActive,
    required this.isVerified,
    required this.lastLogin,
    required this.lastName,
    required this.lastUpdate,
    required this.memberships,
    required this.mobileNumber,
    required this.userName,
    required this.online,
    required this.patientsId,
    required this.prescriptionsId,
    required this.profileImage,
    required this.rateArray,
    required this.recommendArray,
    required this.registrations,
    required this.reviewsArray,
    required this.reservationsId,
    required this.roleName,
    required this.services,
    required this.socialMedia,
    required this.specialities,
    required this.specialitiesServices,
    required this.state,
    required this.timeSlotId,
    required this.timeslots,
    required this.zipCode,
    required this.id,
    required this.doctorsId,
  });
  factory DoctorUserProfile.fromJson(Map<String, dynamic> json) {
    return DoctorUserProfile(
      aboutMe: json['aboutMe'] ?? '',
      accessToken: json['accessToken'] ?? '',
      address1: json['address1'] ?? '',
      address2: json['address2'] ?? '',
      awards: (json['awards'] as List)
          .map((e) => Award.fromMap(e as Map<String, dynamic>)) // Use fromMap here
          .toList(),
      bankId: json['bankId'] ?? '',
      billingsIds: List<String>.from(json['billingsIds']),
      bookingsFee: json['bookingsFee'] ?? 0,
      city: json['city'] ?? '',
      clinicAddress: json['clinicAddress'] ?? '',
      clinicImages: (json['clinicImages'] as List)
          .map((e) => ClinicImages.fromMap(e as Map<String, dynamic>)) // Use fromMap here
          .toList(),
      clinicName: json['clinicName'] ?? '',
      country: json['country'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      currency: (json['currency'] as List).map((e) => Currency.fromJson(e)).toList(),
      dob: json['dob'] ?? '',
      educations: (json['educations'] as List).map((e) => Education.fromMap(e as Map<String, dynamic>)).toList(),
      experinces: (json['experinces'] as List).map((e) => Experinces.fromMap(e as Map<String, dynamic>)).toList(),
      favsId: List<String>.from(json['favs_id']),
      firstName: json['firstName'] ?? '',
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      idle: json['idle'],
      invoiceIds: List<String>.from(json['invoice_ids']),
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'],
      lastLogin: LastLogin.fromJson(json['lastLogin']),
      lastName: json['lastName'] ?? '',
      lastUpdate: DateTime.parse(json['lastUpdate']),
      memberships: (json['memberships'] as List).map((e) => Memberships.fromMap(e as Map<String, dynamic>)).toList(),
      mobileNumber: json['mobileNumber'] ?? '',
      online: json['online'] ?? false,
      patientsId: List<String>.from(json['patients_id']),
      prescriptionsId: List<String>.from(json['prescriptions_id']),
      profileImage: json['profileImage'] ?? '',
      rateArray: List<double>.from(json['rate_array']),
      recommendArray: List<int>.from(json['recommendArray']),
      registrations: (json['registrations'] as List).map((e) => Registrations.fromMap(e as Map<String, dynamic>)).toList(),
      reviewsArray: List<String>.from(json['reviews_array']),
      reservationsId: List<String>.from(json['reservations_id']),
      roleName: json['roleName'] ?? "",
      services: json['services'] ?? "",
      socialMedia: (json['socialMedia'] as List).map((e) => SocialMedia.fromJson(e)).toList(),
      specialities: (json['specialities'] as List).map((e) => Specialities.fromMap(e as Map<String, dynamic>)).toList(),
      specialitiesServices: List<String>.from(json['specialitiesServices']),
      state: json['state'] ?? '',
      timeSlotId: json['timeSlotId'] is List
          ? List<String>.from(json['timeSlotId']) // If it's a List, convert to List<String>
          : (json['timeSlotId'] != null ? [json['timeSlotId'].toString()] : []), // If it's a string, wrap it in a list
      timeslots: json['timeslots'] != null ? (json['timeslots'] as List).map((e) => DoctorsTimeSlot.fromJson(e)).toList() : null,
      userName: json['userName'] ?? '',
      zipCode: json['zipCode'] ?? '',
      id: json['_id'],
      doctorsId: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aboutMe': aboutMe,
      'accessToken': accessToken,
      'address1': address1,
      'address2': address2,
      'awards': awards.map((e) => e.toJson()).toList(),
      'bankId': bankId,
      'billingsIds': billingsIds,
      'bookingsFee': bookingsFee,
      'city': city,
      'clinicAddress': clinicAddress,
      'clinicImages': clinicImages.map((e) => e.toJson()).toList(),
      'clinicName': clinicName,
      'country': country,
      'createdAt': createdAt,
      'currency': currency.map((e) => e.toJson()).toList(),
      'dob': dob,
      'educations': educations.map((e) => e.toJson()).toList(),
      'experinces': experinces.map((e) => e.toJson()).toList(),
      'favs_id': favsId,
      'firstName': firstName,
      'fullName': fullName,
      'gender': gender,
      'idle': idle,
      'invoice_ids': invoiceIds,
      'isActive': isActive,
      'isVerified': isVerified,
      'lastLogin': lastLogin.toJson(),
      'lastName': lastName,
      'lastUpdate': lastUpdate.toIso8601String(),
      'memberships': memberships.map((e) => e.toJson()).toList(),
      'mobileNumber': mobileNumber,
      'online': online,
      'patients_id': patientsId,
      'prescriptions_id': prescriptionsId,
      'profileImage': profileImage,
      'rate_array': rateArray,
      'recommendArray': recommendArray,
      'registrations': registrations.map((e) => e.toJson()).toList(),
      'reviews_array': reviewsArray,
      'reservations_id': reservationsId,
      'roleName': roleName.toString().split('.').last,
      'services': services.toString().split('.').last,
      'socialMedia': socialMedia.map((e) => e.toJson()).toList(),
      'specialities': specialities.map((e) => e.toJson()).toList(),
      'specialitiesServices': specialitiesServices,
      'state': state,
      'timeSlotId': timeSlotId,
      'timeslots': timeslots?.map((e) => e.toJson()).toList(),
      'userName': userName,
      'zipCode': zipCode,
      '_id': id,
      'id': doctorsId,
    };
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'aboutMe': aboutMe});
    result.addAll({'accessToken': accessToken});
    result.addAll({'address1': address1});
    result.addAll({'address2': address2});
    result.addAll({'awards': awards.map((x) => x.toMap()).toList()});
    result.addAll({"bankId": bankId});
    result.addAll({"billingsIds": billingsIds});
    result.addAll({"bookingsFee": bookingsFee});
    result.addAll({'city': city});
    result.addAll({'clinicAddress': clinicAddress});
    result.addAll({'clinicImages': clinicImages.map((x) => x.toMap()).toList()});
    result.addAll({'clinicName': clinicName});
    result.addAll({'country': country});
    result.addAll({'createdAt': createdAt});
    result.addAll({'currency': currency.map((x) => x.toMap()).toList()});
    result.addAll({'dob': dob});
    result.addAll({'educations': educations.map((x) => x.toMap()).toList()});
    result.addAll({'experinces': experinces.map((x) => x.toMap()).toList()});
    result.addAll({'favsId': favsId});
    result.addAll({'firstName': firstName});
    result.addAll({'fullName': fullName});
    result.addAll({'gender': gender});
    result.addAll({'idle': idle});
    result.addAll({'invoiceIds': invoiceIds});
    result.addAll({'isActive': isActive});
    result.addAll({'isVerified': isVerified});
    result.addAll({'lastLogin': lastLogin.toMap()});
    result.addAll({'lastName': lastName});
    result.addAll({'lastUpdate': lastUpdate});
    result.addAll({'memberships': memberships.map((x) => x.toMap()).toList()});
    result.addAll({'mobileNumber': mobileNumber});
    result.addAll({'online': online});
    result.addAll({'patientsId': patientsId});
    result.addAll({'prescriptionsId': prescriptionsId});
    result.addAll({'profileImage': profileImage});
    result.addAll({'rateArray': rateArray});
    result.addAll({'recommendArray': recommendArray});
    result.addAll({'registrations': registrations.map((x) => x.toMap()).toList()});
    result.addAll({'reviewsArray': reviewsArray});
    result.addAll({'reservationsId': reservationsId});
    result.addAll({'roleName': roleName});
    result.addAll({'services': services});
    result.addAll({'socialMedia': socialMedia});
    result.addAll({'specialities': specialities.map((x) => x.toMap()).toList()});
    result.addAll({'specialitiesServices': specialitiesServices});
    result.addAll({'state': state});
    result.addAll({'timeSlotId': timeSlotId});
    result.addAll({'timeslots': timeslots});
    result.addAll({'userName': userName});
    result.addAll({'zipCode': zipCode});
    result.addAll({'id': id});
    result.addAll({'doctorsId': doctorsId});

    return result;
  }

  factory DoctorUserProfile.fromMap(Map<String, dynamic> map) {
    return DoctorUserProfile(
      aboutMe: map['aboutMe'] ?? '',
      accessToken: map['accessToken'] ?? '',
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      awards: map['awards'] != null ? List<Award>.from(map['awards']?.map((x) => Award.fromMap(x))) : [],
      bankId: map['bankId'] ?? '',
      billingsIds: map['billingsIds'] != null ? List<String>.from(map['billingsIds']) : [],
      bookingsFee: map['bookingsFee'] ?? '',
      city: map['city'] ?? '',
      clinicAddress: map['clinicAddress'] ?? '',
      clinicImages: map['clinicImages'] != null ? List<ClinicImages>.from(map['clinicImages']?.map((x) => ClinicImages.fromMap(x))) : [],
      clinicName: map['clinicName'] ?? '',
      country: map['country'] ?? '',
      currency: map['currency'] != null ? List<Currency>.from(map['currency']?.map((x) => Currency.fromMap(x))) : [],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(), // Handle DateTime parsing
      dob: (map['dob'] is String && map['dob'].isNotEmpty) ? DateTime.tryParse(map['dob'].trim()) : null,
      educations: map['educations'] != null ? List<Education>.from(map['educations']?.map((x) => Education.fromMap(x))) : [],
      experinces: map['experinces'] != null ? List<Experinces>.from(map['experinces']?.map((x) => Experinces.fromMap(x))) : [],
      favsId: map['favs_id'] != null ? List<String>.from(map['favs_id']) : [],
      firstName: map['firstName'] ?? '',
      fullName: map['fullName'] ?? '',
      gender: map['gender'] ?? '',
      idle: map['idle'] ?? false,
      invoiceIds: map['invoice_ids'] != null ? List<String>.from(map['invoice_ids']) : [],
      isActive: map['isActive'] ?? false,
      isVerified: map['isVerified'] ?? false,
      lastLogin: map['lastLogin'] != null ? LastLogin.fromMap(map['lastLogin']) : LastLogin(date: '', ipAddr: '', userAgent: ''),
      lastName: map['lastName'] ?? '',
      lastUpdate: map['lastUpdate'] != null ? DateTime.parse(map['lastUpdate']) : DateTime.now(), // Handle DateTime parsing for lastUpdate
      memberships: map['memberships'] != null ? List<Memberships>.from(map['memberships']?.map((x) => Memberships.fromMap(x))) : [],
      mobileNumber: map['mobileNumber'] ?? '',
      online: map['online'] ?? false,
      patientsId: map['patients_id'] != null ? List<String>.from(map['patients_id']) : [],
      prescriptionsId: map['prescriptions_id'] != null ? List<String>.from(map['prescriptions_id']) : [],
      profileImage: map['profileImage'] ?? '',
      rateArray: map['rate_array'] != null ? List<double>.from(map['rate_array']) : [],
      recommendArray: map['recommendArray'] != null ? List<int>.from(map['recommendArray']) : [],
      registrations: map['registrations'] != null ? List<Registrations>.from(map['registrations']?.map((x) => Registrations.fromMap(x))) : [],
      reviewsArray: map['reviews_array'] != null ? List<String>.from(map['reviews_array']) : [],
      reservationsId: map['reservations_id'] != null ? List<String>.from(map['reservations_id']) : [],
      roleName: map['roleName'] ?? "",
      services: map['services'],
      // roleName: DoctorRoleNameExtension.fromString(map['roleName']),
      // services: ServicesExtension.fromString(map['services']),
      socialMedia: (map['socialMedia'] as List?)
    ?.map((e) => SocialMedia.fromMap(e))
    .toList() ?? [],
      specialities: map['specialities'] != null ? List<Specialities>.from(map['specialities']?.map((x) => Specialities.fromMap(x))) : [],
      specialitiesServices: map['specialitiesServices'] != null ? List<String>.from(map['specialitiesServices']) : [],
      state: map['state'] ?? '',
      timeSlotId: map['timeSlotId'] != null ? List<String>.from(map['timeSlotId']) : [],
      timeslots: map['timeslots'] != null
          ? List<DoctorsTimeSlot>.from(map['timeslots']?.map((x) => DoctorsTimeSlot.fromMap(x)) ?? [])
          : null, // Handle null timeslots
      userName: map['userName'] ?? '',
      zipCode: map['zipCode'] ?? '',
      id: map['_id'] ?? '',
      doctorsId: map['id'] ?? '',
    );
  }

  @override
  String toString() {
    return 'DoctorUserProfile(aboutMe: $aboutMe, accessToken: $accessToken, address1: $address1, address2: $address2, awards: $awards, bankId: $bankId, billingsIds: $billingsIds, bookingsFee: $bookingsFee, city: $city, clinicAddress: $clinicAddress, clinicImages: $clinicImages, clinicName: $clinicName, country: $country, createdAt: $createdAt, currency: $currency, dob: $dob, educations: $educations, experinces: $experinces, favsId: $favsId, firstName: $firstName, fullName: $fullName, gender: $gender, idle: $idle, invoiceIds: $invoiceIds, isActive: $isActive, isVerified: $isVerified, lastLogin: $lastLogin, lastName: $lastName, lastUpdate: $lastUpdate, memberships: $memberships, mobileNumber: $mobileNumber, userName: $userName, online: $online, patientsId: $patientsId, prescriptionsId: $prescriptionsId, profileImage: $profileImage, rateArray: $rateArray, recommendArray: $recommendArray, registrations: $registrations, reviewsArray: $reviewsArray, reservationsId: $reservationsId, roleName: $roleName, services: $services, socialMedia: $socialMedia, specialities: $specialities, specialitiesServices: $specialitiesServices, state: $state, timeSlotId: $timeSlotId, timeslots: $timeslots, zipCode: $zipCode, id: $id, doctorsId: $doctorsId)';
  }
}
