import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:health_care/models/bills.dart';

import 'package:health_care/models/patient_appointment_reservation.dart';
import 'package:health_care/models/prescriptions.dart';
import 'package:health_care/models/users.dart';

class DoctorPatientProfileModel {
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
  final List<String> invoiceIds;
  final bool isActive;
  final bool? isVerified;
  final LastLogin lastLogin;
  final String lastName;
  final List<PatientAppointmentReservation> lastTwoAppointments;
  final DateTime lastUpdate;
  final List<String> medicalRecordsArray;
  final String mobileNumber;
  final bool online;
  final List<String> prescriptionsId;
  final String profileImage;
  final List<String> reservationsId;
  final String roleName;
  final String services;
  Prescriptions? singlePrescription;
  Bills? singleBill;
  final String state;
  final String userName;
  final String zipCode;
  final String? id;
  final int patientsId;

  DoctorPatientProfileModel({
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
    required this.invoiceIds,
    required this.isActive,
    required this.isVerified,
    required this.lastLogin,
    required this.lastName,
    required this.lastTwoAppointments,
    required this.lastUpdate,
    required this.medicalRecordsArray,
    required this.mobileNumber,
    required this.online,
    required this.prescriptionsId,
    required this.profileImage,
    required this.reservationsId,
    required this.roleName,
    required this.services,
    this.singlePrescription,
    this.singleBill,
    required this.state,
    required this.userName,
    required this.zipCode,
    required this.id,
    required this.patientsId,
  });

  DoctorPatientProfileModel copyWith({
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
    List<String>? invoiceIds,
    bool? isActive,
    bool? isVerified,
    LastLogin? lastLogin,
    String? lastName,
    List<PatientAppointmentReservation>? lastTwoAppointments,
    DateTime? lastUpdate,
    List<String>? medicalRecordsArray,
    String? mobileNumber,
    bool? online,
    List<String>? prescriptionsId,
    String? profileImage,
    List<String>? reservationsId,
    String? roleName,
    String? services,
    Prescriptions? singlePrescription,
    Bills? singleBill,
    String? state,
    String? userName,
    String? zipCode,
    String? id,
    int? patientsId,
  }) {
    return DoctorPatientProfileModel(
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
      invoiceIds: invoiceIds ?? this.invoiceIds,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      lastLogin: lastLogin ?? this.lastLogin,
      lastName: lastName ?? this.lastName,
      lastTwoAppointments: lastTwoAppointments ?? this.lastTwoAppointments,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      medicalRecordsArray: medicalRecordsArray ?? this.medicalRecordsArray,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      online: online ?? this.online,
      prescriptionsId: prescriptionsId ?? this.prescriptionsId,
      profileImage: profileImage ?? this.profileImage,
      reservationsId: reservationsId ?? this.reservationsId,
      roleName: roleName ?? this.roleName,
      services: services ?? this.services,
      singlePrescription: singlePrescription ?? this.singlePrescription,
      singleBill: singleBill ?? this.singleBill,
      state: state ?? this.state,
      userName: userName ?? this.userName,
      zipCode: zipCode ?? this.zipCode,
      id: id ?? this.id,
      patientsId: patientsId ?? this.patientsId,
    );
  }

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
    result.addAll({'invoiceIds': invoiceIds});
    result.addAll({'isActive': isActive});
    if (isVerified != null) {
      result.addAll({'isVerified': isVerified});
    }
    result.addAll({'lastLogin': lastLogin.toMap()});
    result.addAll({'lastName': lastName});
    result.addAll({'lastTwoAppointments': lastTwoAppointments.map((x) => PatientAppointmentReservation.fromMap(x as Map<String, dynamic>)).toList()});
    result.addAll({'lastUpdate': lastUpdate});
    result.addAll({'medicalRecordsArray': medicalRecordsArray});
    result.addAll({'mobileNumber': mobileNumber});
    result.addAll({'online': online});
    result.addAll({'prescriptionsId': prescriptionsId});
    result.addAll({'profileImage': profileImage});
    result.addAll({'reservationsId': reservationsId});
    result.addAll({'roleName': roleName});
    result.addAll({'services': services});
    if (singlePrescription != null) {
      result.addAll({'singlePrescription': singlePrescription});
    }
    if (singleBill != null) {
      result.addAll({'singleBill': singleBill});
    }
    result.addAll({'state': state});
    result.addAll({'userName': userName});
    result.addAll({'zipCode': zipCode});
    if (id != null) {
      result.addAll({'id': id});
    }
    result.addAll({'patientsId': patientsId});

    return result;
  }

  factory DoctorPatientProfileModel.fromMap(Map<String, dynamic> map) {
    return DoctorPatientProfileModel(
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      billingsIds: List<String>.from(map['billingsIds']),
      bloodG: map['bloodG'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      dependentsArray: List<String>.from(map['dependentsArray'] ?? []),
      dob: map['dob'] == '' ? '' : DateTime.parse(map['dob']),
      doctorsId: List<String>.from(map['doctors_id'] ?? []),
      favsId: List<String>.from(map['favs_id'] ?? []),
      firstName: map['firstName'] ?? '',
      fullName: map['fullName'] ?? '',
      gender: map['gender'] ?? '',
      invoiceIds: List<String>.from(map['invoice_ids'] ?? []),
      isActive: map['isActive'] ?? false,
      isVerified: map['isVerified'],
      lastLogin: map['lastLogin'] != null ? LastLogin.fromMap(map['lastLogin']) : LastLogin.defaultInstance(),
      lastName: map['lastName'] ?? '',
      lastTwoAppointments: List<PatientAppointmentReservation>.from(map['lastTwoAppointments']?.map((x) => PatientAppointmentReservation.fromMap(x))),
      lastUpdate: map['lastUpdate'] != null ? DateTime.parse(map['lastUpdate']) : DateTime.now(),
      medicalRecordsArray: List<String>.from(map['medicalRecordsArray']),
      mobileNumber: map['mobileNumber'] ?? '',
      online: map['online'] ?? false,
      prescriptionsId: List<String>.from(map['prescriptions_id']),
      profileImage: map['profileImage'] ?? '',
      reservationsId: List<String>.from(map['reservations_id']),
      roleName: map['roleName'] ?? '',
      services: map['services'] ?? '',
      singlePrescription: map['singlePrescription'] != null ? Prescriptions.fromMap(map['singlePrescription']) : null,
      singleBill: map['singleBill'] != null ? Bills.fromMap(map['singleBill']) : null,
      state: map['state'] ?? '',
      userName: map['userName'] ?? '',
      zipCode: map['zipCode'] ?? '',
      id: map['_id'],
      patientsId: map['id']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DoctorPatientProfileModel.fromJson(String source) => DoctorPatientProfileModel.fromMap(json.decode(source));

  factory DoctorPatientProfileModel.empty() {
    return DoctorPatientProfileModel(
      address1: '',
      address2: '',
      billingsIds: [],
      bloodG: '',
      city: '',
      country: '',
      createdAt: DateTime.now(),
      dependentsArray: [],
      dob: '',
      doctorsId: [],
      favsId: [],
      firstName: '',
      fullName: '',
      gender: '',
      invoiceIds: [],
      isActive: false,
      isVerified: false,
      lastLogin: LastLogin(date: DateTime.now(), ipAddr: '', userAgent: '', idle: false),
      lastName: '',
      lastTwoAppointments: [],
      lastUpdate: DateTime.now(),
      medicalRecordsArray: [],
      mobileNumber: '',
      online: false,
      prescriptionsId: [],
      profileImage: '',
      reservationsId: [],
      roleName: 'patient',
      services: '',
      singlePrescription: Prescriptions.empty(),
      singleBill: null,
      state: '',
      userName: '',
      zipCode: '',
      id: '',
      patientsId: 0,
    );
  }
  @override
  String toString() {
    return 'DoctorPatientProfile(address1: $address1, address2: $address2, billingsIds: $billingsIds, bloodG: $bloodG, city: $city, country: $country, createdAt: $createdAt, dependentsArray: $dependentsArray, dob: $dob, doctorsId: $doctorsId, favsId: $favsId, firstName: $firstName, fullName: $fullName, gender: $gender, invoiceIds: $invoiceIds, isActive: $isActive, isVerified: $isVerified, lastLogin: $lastLogin, lastName: $lastName, lastTwoAppointments $lastTwoAppointments, lastUpdate: $lastUpdate, medicalRecordsArray: $medicalRecordsArray, mobileNumber: $mobileNumber, online: $online,  prescriptionsId: $prescriptionsId, profileImage: $profileImage,  reservationsId: $reservationsId,  roleName: $roleName, services: $services,singlePrescription: $singlePrescription, singleBill: $singleBill, state: $state, userName: $userName, zipCode: $zipCode, id: $id, patientsId: $patientsId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DoctorPatientProfileModel &&
        other.address1 == address1 &&
        other.address2 == address2 &&
        listEquals(other.billingsIds, billingsIds) &&
        other.bloodG == bloodG &&
        other.city == city &&
        other.country == country &&
        other.createdAt == createdAt &&
        listEquals(other.dependentsArray, dependentsArray) &&
        other.dob == dob &&
        listEquals(other.doctorsId, doctorsId) &&
        listEquals(other.favsId, favsId) &&
        other.firstName == firstName &&
        other.fullName == fullName &&
        other.gender == gender &&
        listEquals(other.invoiceIds, invoiceIds) &&
        other.isActive == isActive &&
        other.isVerified == isVerified &&
        other.lastLogin == lastLogin &&
        other.lastName == lastName &&
        listEquals(other.lastTwoAppointments, lastTwoAppointments) &&
        other.lastUpdate == lastUpdate &&
        listEquals(other.medicalRecordsArray, medicalRecordsArray) &&
        other.mobileNumber == mobileNumber &&
        other.online == online &&
        listEquals(other.prescriptionsId, prescriptionsId) &&
        other.profileImage == profileImage &&
        listEquals(other.reservationsId, reservationsId) &&
        other.roleName == roleName &&
        other.services == services &&
        other.singlePrescription == singlePrescription &&
        other.singleBill == singleBill &&
        other.state == state &&
        other.userName == userName &&
        other.zipCode == zipCode &&
        other.id == id &&
        other.patientsId == patientsId;
  }

  @override
  int get hashCode {
    return address1.hashCode ^
        address2.hashCode ^
        billingsIds.hashCode ^
        bloodG.hashCode ^
        city.hashCode ^
        country.hashCode ^
        createdAt.hashCode ^
        dependentsArray.hashCode ^
        dob.hashCode ^
        doctorsId.hashCode ^
        favsId.hashCode ^
        firstName.hashCode ^
        fullName.hashCode ^
        gender.hashCode ^
        invoiceIds.hashCode ^
        isActive.hashCode ^
        isVerified.hashCode ^
        lastLogin.hashCode ^
        lastName.hashCode ^
        lastTwoAppointments.hashCode ^
        lastUpdate.hashCode ^
        medicalRecordsArray.hashCode ^
        mobileNumber.hashCode ^
        online.hashCode ^
        prescriptionsId.hashCode ^
        profileImage.hashCode ^
        reservationsId.hashCode ^
        roleName.hashCode ^
        services.hashCode ^
        singlePrescription.hashCode ^
        singleBill.hashCode ^
        state.hashCode ^
        userName.hashCode ^
        zipCode.hashCode ^
        id.hashCode ^
        patientsId.hashCode;
  }
}
