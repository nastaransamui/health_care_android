import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/specialities.dart';
class Doctors {
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
  final List<String> favIds;
  final String firstName;
  final String fullName;
  final String gender;
  final bool? idle;
  final List<String> invoiceIds;
  final bool isActive;
  final bool? isVerified;
  final LastLogin? lastLogin;
  final String lastName;
  final DateTime lastUpdate;
  final List<Memberships> memberships;
  final String mobileNumber;
  final bool online;
  final List<String> patientsId;
  final List<String> prescriptionsId;
  final String profileImage;
  final List<double> rateArray;
  final List<int>recommendArray;
  final List<Registrations> registrations;
  final List<String> reviewsArray;
  final List<String> reservationsId;
  final String roleName;
  final String services;
  final List<SocialMedia> socialMedia;
  final List<Specialities> specialities;
  final List<String> specialitiesServices;
  final String state;
  final List<String> timeSlotId;
  final List<DoctorsTimeSlot>? timeslots;
  final String userName;
  final String zipCode;
  final String updatedAt;
  final String? id;
  final int doctorsId;

 Doctors({
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
    required this.favIds,
    required this.firstName,
    required this.fullName,
    required this.gender,
    this.idle,
    required this.invoiceIds,
    required this.isActive,
    this.isVerified,
    this.lastLogin,
    required this.lastName,
    required this.lastUpdate,
    required this.memberships,
    required this.mobileNumber,
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
    this.timeslots,
    required this.userName,
    required this.zipCode,
    required this.updatedAt,
    this.id,
    required this.doctorsId,
  });

   factory Doctors.fromJson(Map<String, dynamic> json) {

    return Doctors(
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
      createdAt: json['createdAt'] != null
    ? DateTime.parse(json['createdAt'])
    : DateTime.now(),
      currency: (json['currency'] as List)
          .map((e) => Currency.fromJson(e))
          .toList(),
      dob: json['dob'] ?? '',
      educations: (json['educations'] as List)
          .map((e) => Education.fromMap(e as Map<String, dynamic>))
          .toList(),
      experinces: (json['experinces'] as List)
          .map((e) => Experinces.fromMap(e as Map<String, dynamic>))
          .toList(),
      favIds: List<String>.from(json['favs_id']),
      firstName: json['firstName'] ?? '',
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      idle: json['idle'],
      invoiceIds: List<String>.from(json['invoice_ids']),
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'],
      lastLogin: json['lastLogin'] != null
          ? LastLogin.fromMap(json['lastLogin'])
          : null,
      lastName: json['lastName'] ?? '',
      lastUpdate: DateTime.parse(json['lastUpdate']),
      memberships: (json['memberships'] as List)
          .map((e) => Memberships.fromMap(e as Map<String, dynamic>))
          .toList(),
      mobileNumber: json['mobileNumber'] ?? '',
      online: json['online'] ?? false,
      patientsId: List<String>.from(json['patients_id']),
      prescriptionsId: List<String>.from(json['prescriptions_id']),
      profileImage: json['profileImage'] ?? '',
      rateArray: (json['rate_array'] as List<dynamic>?)
    ?.map((e) => (e as num).toDouble())
    .toList() ?? [],
      recommendArray: List<int>.from(json['recommendArray']),
      registrations: (json['registrations'] as List)
          .map((e) => Registrations.fromMap(e as Map<String, dynamic>))
          .toList(),
      reviewsArray: List<String>.from(json['reviews_array']),
      reservationsId: List<String>.from(json['reservations_id']),
      roleName: json['roleName'] ?? "",
      services: json['services'] ?? "",
      // roleName: DoctorRoleName.values.firstWhere(
      //     (e) => e.toString() == 'DoctorRoleName.${json['roleName']}'),
      // services: Services.values
      //     .firstWhere((e) => e.toString() == 'Services.${json['services']}'),
      socialMedia: (json['socialMedia'] as List)
          .map((e) => SocialMedia.fromJson(e))
          .toList(),
      specialities: (json['specialities'] as List)
          .map((e) => Specialities.fromMap(e as Map<String, dynamic>))
          .toList(),
      specialitiesServices: List<String>.from(json['specialitiesServices']),
      state: json['state'] ?? '',
      timeSlotId: json['timeSlotId'] is List
    ? List<String>.from(json['timeSlotId']) // If it's a List, convert to List<String>
    : (json['timeSlotId'] != null ? [json['timeSlotId'].toString()] : []), // If it's a string, wrap it in a list
      timeslots: json['timeslots'] != null
          ? (json['timeslots'] as List)
              .map((e) => DoctorsTimeSlot.fromJson(e))
              .toList()
          : null,
      userName: json['userName'] ?? '',
      zipCode: json['zipCode'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
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
      'favs_id': favIds,
      'firstName': firstName,
      'fullName': fullName,
      'gender': gender,
      'idle': idle,
      'invoice_ids': invoiceIds,
      'isActive': isActive,
      'isVerified': isVerified,
      'lastLogin': lastLogin?.toJson(),
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
      'updatedAt': updatedAt,
      '_id': id,
      'id': doctorsId,
    };
  }

  @override
  String toString() {
    return 'Doctors(aboutMe: $aboutMe, accessToken: $accessToken, address1: $address1, address2: $address2, awards: $awards, bankId: $bankId, billingsIds: $billingsIds, bookingsFee: $bookingsFee, city: $city, clinicAddress: $clinicAddress, clinicImages: $clinicImages, clinicName: $clinicName, country: $country, createdAt: $createdAt, currency: $currency, dob: $dob, educations: $educations, experinces: $experinces, favIds: $favIds, firstName: $firstName, fullName: $fullName, gender: $gender, idle: $idle, invoiceIds: $invoiceIds, isActive: $isActive, isVerified: $isVerified, lastLogin: $lastLogin, lastName: $lastName, lastUpdate: $lastUpdate, memberships: $memberships, mobileNumber: $mobileNumber, online: $online, patientsId: $patientsId, prescriptionsId: $prescriptionsId, profileImage: $profileImage, rateArray: $rateArray, registrations: $registrations, reviewsArray: $reviewsArray, reservationsId: $reservationsId, roleName: $roleName, services: $services, socialMedia: $socialMedia, specialities: $specialities, specialitiesServices: $specialitiesServices, state: $state, timeSlotId: $timeSlotId, timeslots: $timeslots, userName: $userName, zipCode: $zipCode, updatedAt: $updatedAt, id: $id, doctorsId: $doctorsId)';
  }
}

class Tags {
  final String value;
  final String title;

  Tags({
    required this.value,
    required this.title,
  });

  Tags copyWith({
    String? value,
    String? title,
  }) {
    return Tags(
      value: value ?? this.value,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'value': value});
    result.addAll({'title': title});

    return result;
  }

  factory Tags.fromMap(Map<String, dynamic> map) {
    return Tags(
      value: map['value'] ?? '',
      title: map['title'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Tags.fromJson(String source) => Tags.fromMap(json.decode(source));

  @override
  String toString() => 'Tags(value: $value, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tags && other.value == value && other.title == title;
  }

  @override
  int get hashCode => value.hashCode ^ title.hashCode;
}

class ClinicImages {
  final String src;
  final int width;
  final int height;
  final bool isSelected;
  final String name;
  final String id;
  final String uuid;
  final String random;
  final List<Tags> tags;

  ClinicImages({
    required this.src,
    required this.width,
    required this.height,
    required this.isSelected,
    required this.name,
    required this.id,
    required this.uuid,
    required this.random,
    required this.tags,
  });

  ClinicImages copyWith({
    String? src,
    int? width,
    int? height,
    bool? isSelected,
    String? name,
    String? id,
    String? random,
    List<Tags>? tags,
  }) {
    return ClinicImages(
      src: src ?? this.src,
      width: width ?? this.width,
      height: height ?? this.height,
      isSelected: isSelected ?? this.isSelected,
      name: name ?? this.name,
      id: id ?? this.id,
      uuid: uuid,
      random: random ?? this.random,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'src': src});
    result.addAll({'width': width});
    result.addAll({'height': height});
    result.addAll({'isSelected': isSelected});
    result.addAll({'name': name});
    result.addAll({'_id': id});
    result.addAll({'uuid': uuid});
    result.addAll({'random': random});
    result.addAll({'tags': tags.map((x) => x.toMap()).toList()});

    return result;
  }

  factory ClinicImages.fromMap(Map<String, dynamic> map) {
    return ClinicImages(
      src: map['src'] ?? '',
      width: map['width']?.toInt() ?? 0,
      height: map['height']?.toInt() ?? 0,
      isSelected: map['isSelected'] ?? false,
      name: map['name'] ?? '',
      id: map['id'] ?? '',
      uuid: map['uuid'] ?? '',
      random: map['random'] ?? '',
      tags: List<Tags>.from(map['tags']?.map((x) => Tags.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory ClinicImages.fromJson(String source) => ClinicImages.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ClinicImages(src: $src, width: $width, height: $height, isSelected: $isSelected, name: $name, id: $id, uuid: $uuid, random: $random, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClinicImages &&
        other.src == src &&
        other.width == width &&
        other.height == height &&
        other.isSelected == isSelected &&
        other.name == name &&
        other.id == id &&
        other.uuid == uuid &&
        other.random == random &&
        listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    return src.hashCode ^
        width.hashCode ^
        height.hashCode ^
        isSelected.hashCode ^
        name.hashCode ^
        id.hashCode ^
        uuid.hashCode ^
        random.hashCode ^
        tags.hashCode;
  }
}

class Education {
  final String collage;
  final String degree;
  final String yearOfCompletion;

  Education({
    required this.collage,
    required this.degree,
    required this.yearOfCompletion,
  });

  Education copyWith({
    String? collage,
    String? degree,
    String? yearOfCompletion,
  }) {
    return Education(
      collage: collage ?? this.collage,
      degree: degree ?? this.degree,
      yearOfCompletion: yearOfCompletion ?? this.yearOfCompletion,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'collage': collage});
    result.addAll({'degree': degree});
    result.addAll({'yearOfCompletion': yearOfCompletion});

    return result;
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      collage: map['collage'] ?? '',
      degree: map['degree'] ?? '',
       yearOfCompletion: map['yearOfCompletion'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Education.fromJson(String source) => Education.fromMap(json.decode(source));

  @override
  String toString() => 'Education(collage: $collage, degree: $degree, yearOfCompletion: $yearOfCompletion)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Education && other.collage == collage && other.degree == degree && other.yearOfCompletion == yearOfCompletion;
  }

  @override
  int get hashCode => collage.hashCode ^ degree.hashCode ^ yearOfCompletion.hashCode;
}

class Experinces {
  final String designation;
  final DateTime from;
  final String hospitalName;
  final DateTime to;

  Experinces({
    required this.designation,
    required this.from,
    required this.hospitalName,
    required this.to,
  });

  Experinces copyWith({
    String? designation,
    DateTime? from,
    String? hospitalName,
    DateTime? to,
  }) {
    return Experinces(
      designation: designation ?? this.designation,
      from: from ?? this.from,
      hospitalName: hospitalName ?? this.hospitalName,
      to: to ?? this.to,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'designation': designation});
    result.addAll({'from': from.toIso8601String()});
    result.addAll({'hospitalName': hospitalName});
    result.addAll({'to': to.toIso8601String()});

    return result;
  }

  factory Experinces.fromMap(Map<String, dynamic> map) {
    return Experinces(
      designation: map['designation'] ?? '',
      from: DateTime.parse(map['from'] ?? DateTime.now().toIso8601String()),
      hospitalName: map['hospitalName'] ?? '',
      to: DateTime.parse(map['to'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory Experinces.fromJson(String source) => Experinces.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Experinces(designation: $designation, from: $from, hospitalName: $hospitalName, to: $to)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Experinces && other.designation == designation && other.from == from && other.hospitalName == hospitalName && other.to == to;
  }

  @override
  int get hashCode {
    return designation.hashCode ^ from.hashCode ^ hospitalName.hashCode ^ to.hashCode;
  }
}

class Award {
  final String award;
  final String year;

  Award({
    required this.award,
    required this.year,
  });

  Award copyWith({
    String? award,
    String? year,
  }) {
    return Award(
      award: award ?? this.award,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'award': award});
    result.addAll({'year': year}); // Convert DateTime to ISO 8601 string

    return result;
  }

  factory Award.fromMap(Map<String, dynamic> map) {
    return Award(
      award: map['award'] ?? '',
      year: map['year'], // Parse the year as DateTime
    );
  }

  String toJson() => json.encode(toMap());

  factory Award.fromJson(String source) => Award.fromMap(json.decode(source));

  @override
  String toString() => 'Award(award: $award, year: $year)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Award && other.award == award && other.year == year;
  }

  @override
  int get hashCode => award.hashCode ^ year.hashCode;
}
class Memberships {
  final String membership;

  Memberships({
    required this.membership,
  });

  Memberships copyWith({
    String? membership,
  }) {
    return Memberships(
      membership: membership ?? this.membership,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'membership': membership});

    return result;
  }

  factory Memberships.fromMap(Map<String, dynamic> map) {
    return Memberships(
      membership: map['membership'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Memberships.fromJson(String source) => Memberships.fromMap(json.decode(source));

  @override
  String toString() => 'Memberships(membership: $membership)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Memberships && other.membership == membership;
  }

  @override
  int get hashCode => membership.hashCode;
}

class Registrations {
  final String registration;
  final String year;

  Registrations({
    required this.registration,
    required this.year,
  });

  Registrations copyWith({
    String? registration,
    String? year,
  }) {
    return Registrations(
      registration: registration ?? this.registration,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'registration': registration});
    result.addAll({'year': year});

    return result;
  }

  factory Registrations.fromMap(Map<String, dynamic> map) {
    return Registrations(
      registration: map['registration'] ?? '',
      year: map['year'], // Parse the year as DateTime
    );
  }

  String toJson() => json.encode(toMap());

  factory Registrations.fromJson(String source) => Registrations.fromMap(json.decode(source));

  @override
  String toString() => 'Registrations(registration: $registration, year: $year)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Registrations && other.registration == registration && other.year == year;
  }

  @override
  int get hashCode => registration.hashCode ^ year.hashCode;
}

class Currency {
  final String? id;
  final int currencyId;
  final String name;
  final bool isActive;
  final String iso3;
  final String iso2;
  final String numericCode;
  final String currency;
  final String currencyName;
  final String currencySymbol;
  final String emoji;
  String? searchString;
  String? subtitle;
  final List<String> patientsId;
  final List<String> doctorsId;
  Currency({
    this.id,
    required this.currencyId,
    required this.name,
    required this.isActive,
    required this.iso3,
    required this.iso2,
    required this.numericCode,
    required this.currency,
    required this.currencyName,
    required this.currencySymbol,
    required this.emoji,
    required this.patientsId,
    required this.doctorsId,
    this.searchString,
    this.subtitle,
  });
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['_id'],
      currencyId: json['id'],
      name: json['name'],
      isActive: json['isActive'],
      iso3: json['iso3'],
      iso2: json['iso2'],
      numericCode: json['numeric_code'],
      currency: json['currency'],
      currencyName: json['currency_name'],
      currencySymbol: json['currency_symbol'],
      emoji: json['emoji'],
      patientsId: List<String>.from(json['patients_id'] ?? []),
      doctorsId: List<String>.from(json['doctors_id'] ?? []),
      searchString: json['searchString'],
      subtitle: json['subtitle'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': currencyId,
      'name': name,
      'isActive': isActive,
      'iso3': iso3,
      'iso2': iso2,
      'numeric_code': numericCode,
      'currency': currency,
      'currency_name': currencyName,
      'currency_symbol': currencySymbol,
      'emoji': emoji,
      'patients_id': patientsId,
      'doctors_id': doctorsId,
      'searchString': searchString,
      'subtitle': subtitle,
    };
  }

    Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'_id': id});
    result.addAll({'id': currencyId});
    result.addAll({'name': name});
    result.addAll({'isActive': isActive});
    result.addAll({'iso3': iso3});
    result.addAll({'iso2': iso2});
    result.addAll({'numeric_code': numericCode});
    result.addAll({'currency_symbol': currencySymbol});
    result.addAll({'emoji': emoji});
    result.addAll({'patients_id': patientsId});
    result.addAll({'doctors_id': doctorsId});
    result.addAll({'searchString': searchString});
    result.addAll({'subtitle': subtitle});

    return result;
  }
   // fromMap constructor to map data to the Currency model
  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      id: map['_id'], // id is nullable
      currencyId: map['id'] ?? 0, // Ensure a default value for currencyId
      name: map['name'] ?? '',
      isActive: map['isActive'] ?? false, // Default to false if not present
      iso3: map['iso3'] ?? '',
      iso2: map['iso2'] ?? '',
      numericCode: map['numeric_code'] ?? '',
      currency: map['currency'] ?? '',
      currencyName: map['currency_name'] ?? '',
      currencySymbol: map['currency_symbol'] ?? '',
      emoji: map['emoji'] ?? '',
      searchString: map['searchString'], // searchString is nullable
      subtitle: map['subtitle'], // subtitle is nullable
      patientsId: map['patients_id'] != null
          ? List<String>.from(map['patients_id'])
          : [], // Default to empty list if null
      doctorsId: map['doctors_id'] != null
          ? List<String>.from(map['doctors_id'])
          : [], // Default to empty list if null
    );
  }

  @override
  String toString() {
    return 'Currency(id: $id, currencyId: $currencyId, name: $name, isActive: $isActive, iso3: $iso3, iso2: $iso2, numericCode: $numericCode, currency: $currency, currencyName: $currencyName, currencySymbol: $currencySymbol, emoji: $emoji, searchString: $searchString, subtitle: $subtitle, patientsId: $patientsId, doctorsId: $doctorsId)';
  }
}

class LastLogin {
  final DateTime date;
  final String ipAddr;
  final String userAgent;
  final bool idle;
  LastLogin({
    required this.date,
    required this.ipAddr,
    required this.userAgent,
    required this.idle,
  });

  LastLogin copyWith({
    DateTime? date,
    String? ipAddr,
    String? userAgent,
    bool? idle,
  }) {
    return LastLogin(
      date: date ?? this.date,
      ipAddr: ipAddr ?? this.ipAddr,
      userAgent: userAgent ?? this.userAgent,
      idle: idle ?? this.idle,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'date': date});
    result.addAll({'ipAddr': ipAddr});
    result.addAll({'userAgent': userAgent});
    result.addAll({'idle': idle});
  
    return result;
  }

  factory LastLogin.fromMap(Map<String, dynamic> map) {
    return LastLogin(
      date: map['date'] is DateTime ? map['date'] : DateTime.now(),
      ipAddr: map['ipAddr'] ?? '',
      userAgent: map['userAgent'] ?? '',
      idle: map['idle'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory LastLogin.fromJson(String source) => LastLogin.fromMap(json.decode(source));

  @override
  String toString() {
    return 'LastLogin(date: $date, ipAddr: $ipAddr, userAgent: $userAgent, idle: $idle)';
  }
}
class SocialMedia {
  final String platform;
  final String link;

  SocialMedia({required this.platform, required this.link});

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      platform: json['platform'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'link': link,
    };
  }
}