import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:health_care/models/specialities.dart';

class Doctors {
  final String createdAt;
  final String updatedAt;
  final String userName;
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String gender;
  final String dob;
  final String clinicName;
  final String clinicAddress;
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
  final List<dynamic> invoiceIds;
  final List<dynamic> reviewsArray;
  final List<dynamic> rateArray;
  final String accessToken;
  final bool isActive;
  final String lastUpdate;
  // final Map<dynamic, dynamic> status;
  final String id;

  Doctors({
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.gender,
    required this.dob,
    required this.clinicName,
    required this.clinicAddress,
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
    required this.invoiceIds,
    required this.reviewsArray,
    required this.rateArray,
    required this.accessToken,
    required this.isActive,
    required this.lastUpdate,
    // required this.status,
    required this.id,
  });

  Doctors copyWith({
    String? createdAt,
    String? updatedAt,
    String? userName,
    String? firstName,
    String? lastName,
    String? mobileNumber,
    String? gender,
    String? dob,
    String? clinicName,
    String? clinicAddress,
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
    List<dynamic>? invoiceIds,
    List<dynamic>? reviewsArray,
    List<dynamic>? rateArray,
    String? accessToken,
    bool? isActive,
    String? lastUpdate,
    // Map<dynamic, dynamic>? status,
    String? id,
  }) {
    return Doctors(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
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
      invoiceIds: invoiceIds ?? this.invoiceIds,
      reviewsArray: reviewsArray ?? this.reviewsArray,
      rateArray: rateArray ?? this.rateArray,
      accessToken: accessToken ?? this.accessToken,
      isActive: isActive ?? this.isActive,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      // status: status ?? this.status,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'createdAt': createdAt});
    result.addAll({'updatedAt': updatedAt});
    result.addAll({'userName': userName});
    result.addAll({'firstName': firstName});
    result.addAll({'lastName': lastName});
    result.addAll({'mobileNumber': mobileNumber});
    result.addAll({'gender': gender});
    result.addAll({'dob': dob});
    result.addAll({'clinicName': clinicName});
    result.addAll({'clinicAddress': clinicAddress});
    result.addAll({'clinicImages': clinicImages.map((x) => x.toMap()).toList()});
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
    result.addAll({'specialities': specialities.map((x) => x.toMap()).toList()});
    result.addAll({'educations': educations.map((x) => x.toMap()).toList()});
    result.addAll({'experinces': experinces.map((x) => x.toMap()).toList()});
    result.addAll({'awards': awards.map((x) => x.toMap()).toList()});
    result.addAll({'memberships': memberships.map((x) => x.toMap()).toList()});
    result.addAll({'socialMedia': socialMedia});
    result.addAll({'registrations': registrations.map((x) => x.toMap()).toList()});
    result.addAll({'invoiceIds': invoiceIds});
    result.addAll({'reviewsArray': reviewsArray});
    result.addAll({'rateArray': rateArray});
    result.addAll({'accessToken': accessToken});
    result.addAll({'isActive': isActive});
    result.addAll({'lastUpdate': lastUpdate});
    // result.addAll({'status': status});
    result.addAll({'id': id});
  
    return result;
  }

  factory Doctors.fromMap(Map<String, dynamic> map) {
    return Doctors(
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      userName: map['userName'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      gender: map['gender'] ?? '',
      dob: map['dob'] ?? '',
      clinicName: map['clinicName'] ?? '',
      clinicAddress: map['clinicAddress'] ?? '',
      clinicImages: List<ClinicImages>.from(map['clinicImages']?.map((x) => ClinicImages.fromMap(x))),
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
      specialities: List<Specialities>.from(map['specialities']?.map((x) => Specialities.fromMap(x))),
      educations: List<Education>.from(map['educations']?.map((x) => Education.fromMap(x))),
      experinces: List<Experinces>.from(map['experinces']?.map((x) => Experinces.fromMap(x))),
      awards: List<Award>.from(map['awards']?.map((x) => Award.fromMap(x))),
      memberships: List<Memberships>.from(map['memberships']?.map((x) => Memberships.fromMap(x))),
      socialMedia: List<dynamic>.from(map['socialMedia']),
      registrations: List<Registrations>.from(map['registrations']?.map((x) => Registrations.fromMap(x))),
      invoiceIds: List<dynamic>.from(map['invoice_ids']),
      reviewsArray: List<dynamic>.from(map['reviews_array']),
      rateArray: List<dynamic>.from(map['rate_array']),
      accessToken: map['accessToken'] ?? '',
      isActive: map['isActive'] ?? false,
      lastUpdate: map['lastUpdate'] ?? '',
      // status: Map<dynamic, dynamic>.from(map['status']),
      id: map['_id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Doctors.fromJson(String source) => Doctors.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Doctors(createdAt: $createdAt, updatedAt: $updatedAt, userName: $userName, firstName: $firstName, lastName: $lastName, mobileNumber: $mobileNumber, gender: $gender, dob: $dob, clinicName: $clinicName, clinicAddress: $clinicAddress, clinicImages: $clinicImages, profileImage: $profileImage, roleName: $roleName, services: $services, address1: $address1, address2: $address2, city: $city, state: $state, zipCode: $zipCode, country: $country, pricing: $pricing, specialitiesServices: $specialitiesServices, specialities: $specialities, educations: $educations, experinces: $experinces, awards: $awards, memberships: $memberships, socialMedia: $socialMedia, registrations: $registrations, invoiceIds: $invoiceIds, reviewsArray: $reviewsArray, rateArray: $rateArray, accessToken: $accessToken, isActive: $isActive, lastUpdate: $lastUpdate,  id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Doctors &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.userName == userName &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.mobileNumber == mobileNumber &&
      other.gender == gender &&
      other.dob == dob &&
      other.clinicName == clinicName &&
      other.clinicAddress == clinicAddress &&
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
      listEquals(other.invoiceIds, invoiceIds) &&
      listEquals(other.reviewsArray, reviewsArray) &&
      listEquals(other.rateArray, rateArray) &&
      other.accessToken == accessToken &&
      other.isActive == isActive &&
      other.lastUpdate == lastUpdate &&
      // mapEquals(other.status, status) &&
      other.id == id;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
      updatedAt.hashCode ^
      userName.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      mobileNumber.hashCode ^
      gender.hashCode ^
      dob.hashCode ^
      clinicName.hashCode ^
      clinicAddress.hashCode ^
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
      invoiceIds.hashCode ^
      reviewsArray.hashCode ^
      rateArray.hashCode ^
      accessToken.hashCode ^
      isActive.hashCode ^
      lastUpdate.hashCode ^
      // status.hashCode ^
      id.hashCode;
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
  final String random;
  final List<Tags> tags;

  ClinicImages({
    required this.src,
    required this.width,
    required this.height,
    required this.isSelected,
    required this.name,
    required this.id,
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
      random: map['random'] ?? '',
      tags: List<Tags>.from(map['tags']?.map((x) => Tags.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory ClinicImages.fromJson(String source) =>
      ClinicImages.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ClinicImages(src: $src, width: $width, height: $height, isSelected: $isSelected, name: $name, id: $id, random: $random, tags: $tags)';
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
      yearOfCompletion: map['yearOfCompletion'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Education.fromJson(String source) =>
      Education.fromMap(json.decode(source));

  @override
  String toString() =>
      'Education(collage: $collage, degree: $degree, yearOfCompletion: $yearOfCompletion)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Education &&
        other.collage == collage &&
        other.degree == degree &&
        other.yearOfCompletion == yearOfCompletion;
  }

  @override
  int get hashCode =>
      collage.hashCode ^ degree.hashCode ^ yearOfCompletion.hashCode;
}

class Experinces {
  final String designation;
  final String from;
  final String hospitalName;
  final String to;

  Experinces({
    required this.designation,
    required this.from,
    required this.hospitalName,
    required this.to,
  });

  Experinces copyWith({
    String? designation,
    String? from,
    String? hospitalName,
    String? to,
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
    result.addAll({'from': from});
    result.addAll({'hospitalName': hospitalName});
    result.addAll({'to': to});

    return result;
  }

  factory Experinces.fromMap(Map<String, dynamic> map) {
    return Experinces(
      designation: map['designation'] ?? '',
      from: map['from'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      to: map['to'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Experinces.fromJson(String source) =>
      Experinces.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Experinces(designation: $designation, from: $from, hospitalName: $hospitalName, to: $to)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Experinces &&
        other.designation == designation &&
        other.from == from &&
        other.hospitalName == hospitalName &&
        other.to == to;
  }

  @override
  int get hashCode {
    return designation.hashCode ^
        from.hashCode ^
        hospitalName.hashCode ^
        to.hashCode;
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
    result.addAll({'year': year});

    return result;
  }

  factory Award.fromMap(Map<String, dynamic> map) {
    return Award(
      award: map['award'] ?? '',
      year: map['year'] ?? '',
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

  factory Memberships.fromJson(String source) =>
      Memberships.fromMap(json.decode(source));

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
      year: map['year'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Registrations.fromJson(String source) =>
      Registrations.fromMap(json.decode(source));

  @override
  String toString() =>
      'Registrations(registration: $registration, year: $year)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Registrations &&
        other.registration == registration &&
        other.year == year;
  }

  @override
  int get hashCode => registration.hashCode ^ year.hashCode;
}
