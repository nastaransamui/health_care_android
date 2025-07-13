import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:health_care/models/doctors.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/specialities.dart';

class BookingInformation {
  final List<AvailableType> availableSlots;
  final DateTime createDate;
  final String doctorId;
  final BookingInformationDoctorProfile doctorProfile;
  final List<OccupyTime> occupyTime;
  final String patientId;
  final DateTime updateDate;
  final String id;

  BookingInformation({
    required this.availableSlots,
    required this.createDate,
    required this.doctorId,
    required this.doctorProfile,
    required this.occupyTime,
    required this.patientId,
    required this.updateDate,
    required this.id,
  });

  BookingInformation copyWith({
    List<AvailableType>? availableSlots,
    DateTime? createDate,
    String? doctorId,
    BookingInformationDoctorProfile? doctorProfile,
    List<OccupyTime>? occupyTime,
    String? patientId,
    DateTime? updateDate,
    String? id,
  }) {
    return BookingInformation(
      availableSlots: availableSlots ?? this.availableSlots,
      createDate: createDate ?? this.createDate,
      doctorId: doctorId ?? this.doctorId,
      doctorProfile: doctorProfile ?? this.doctorProfile,
      occupyTime: occupyTime ?? this.occupyTime,
      patientId: patientId ?? this.patientId,
      updateDate: updateDate ?? this.updateDate,
      id: id ?? this.id,
    );
  }

  factory BookingInformation.fromMap(Map<String, dynamic> map) {
    return BookingInformation(
      availableSlots:
          map['availableSlots'] != null ? List<AvailableType>.from(map['availableSlots']?.map((x) => AvailableType.fromMap(x)) ?? []) : [],
      createDate: map['createDate'] != null ? DateTime.parse(map['createDate']) : DateTime.now(),
      doctorId: map['doctorId'] ?? '',
      doctorProfile: BookingInformationDoctorProfile.fromMap(map['doctorProfile']),
      occupyTime: List<OccupyTime>.from(map['occupyTime']?.map((x) => OccupyTime.fromMap(x))),
      patientId: map['patientId'] ?? '',
      updateDate: map['updateDate'] != null
          ? DateTime.parse(map['updateDate']) // Parse DateTime if not null
          : DateTime.now(),
      id: map['_id'] ?? '',
    );
  }

  factory BookingInformation.fromJson(String source) => BookingInformation.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BookingInformation(availableSlots: $availableSlots, createDate: $createDate, doctorId: $doctorId, doctorProfile: $doctorProfile, occupyTime: $occupyTime, patientId: $patientId, updateDate: $updateDate, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookingInformation &&
        listEquals(other.availableSlots, availableSlots) &&
        other.createDate == createDate &&
        other.doctorId == doctorId &&
        other.doctorProfile == doctorProfile &&
        listEquals(other.occupyTime, occupyTime) &&
        other.patientId == patientId &&
        other.updateDate == updateDate &&
        other.id == id;
  }

  @override
  int get hashCode {
    return availableSlots.hashCode ^
        createDate.hashCode ^
        doctorId.hashCode ^
        doctorProfile.hashCode ^
        occupyTime.hashCode ^
        patientId.hashCode ^
        updateDate.hashCode ^
        id.hashCode;
  }
}

class BookingInformationDoctorProfile {
  final String address1;
  final String address2;
  final String city;
  final String country;
  final List<Currency> currency;
  final String fullName;
  final String ipAddr;
  final LastLogin lastLogin;
  final bool online;
  final String profileImage;
  final List<double> rateArray;
  final List<int> recommendArray;
  final List<Specialities> specialities;
  final String state;
  final String id;

  BookingInformationDoctorProfile({
    required this.address1,
    required this.address2,
    required this.city,
    required this.country,
    required this.currency,
    required this.fullName,
    required this.ipAddr,
    required this.lastLogin,
    required this.online,
    required this.profileImage,
    required this.rateArray,
    required this.recommendArray,
    required this.specialities,
    required this.state,
    required this.id,
  });

  BookingInformationDoctorProfile copyWith({
    String? address1,
    String? address2,
    String? city,
    String? country,
    List<Currency>? currency,
    String? fullName,
    String? ipAddr,
    LastLogin? lastLogin,
    bool? online,
    String? profileImage,
    List<double>? rateArray,
    List<int>? recommendArray,
    List<Specialities>? specialities,
    String? state,
    String? id,
  }) {
    return BookingInformationDoctorProfile(
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      fullName: fullName ?? this.fullName,
      ipAddr: ipAddr ?? this.ipAddr,
      lastLogin: lastLogin ?? this.lastLogin,
      online: online ?? this.online,
      profileImage: profileImage ?? this.profileImage,
      rateArray: rateArray ?? this.rateArray,
      recommendArray: recommendArray ?? this.recommendArray,
      specialities: specialities ?? this.specialities,
      state: state ?? this.state,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'address1': address1});
    result.addAll({'address2': address2});
    result.addAll({'city': city});
    result.addAll({'country': country});
    result.addAll({'currency': currency.map((x) => x.toMap()).toList()});
    result.addAll({'fullName': fullName});
    result.addAll({'ipAddr': ipAddr});
    result.addAll({'lastLogin': lastLogin.toMap()});
    result.addAll({'online': online});
    result.addAll({'profileImage': profileImage});
    result.addAll({'rateArray': rateArray});
    result.addAll({'recommendArray': recommendArray});
    result.addAll({'specialities': specialities.map((x) => x.toMap()).toList()});
    result.addAll({'state': state});
    result.addAll({'id': id});

    return result;
  }

  factory BookingInformationDoctorProfile.fromMap(Map<String, dynamic> map) {
    return BookingInformationDoctorProfile(
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      currency: map['currency'] != null ? List<Currency>.from(map['currency']?.map((x) => Currency.fromMap(x))) : [],
      fullName: map['fullName'] ?? '',
      ipAddr: map['ipAddr'] ?? '',
      lastLogin:
          map['lastLogin'] != null ? LastLogin.fromMap(map['lastLogin']) : LastLogin(date: DateTime.now(), ipAddr: '', userAgent: '', idle: false),
      online: map['online'] ?? false,
      profileImage: map['profileImage'] ?? '',
      rateArray: map['rate_array'] != null ? List<double>.from(map['rate_array'].map((e) => e.toDouble())) : [],
      recommendArray: map['recommendArray'] != null ? List<int>.from(map['recommendArray']) : [],
      specialities: map['specialities'] != null ? List<Specialities>.from(map['specialities']?.map((x) => Specialities.fromMap(x))) : [],
      state: map['state'] ?? '',
      id: map['_id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingInformationDoctorProfile.fromJson(String source) => BookingInformationDoctorProfile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BookingInformationDoctorProfile(address1: $address1, address2: $address2, city: $city, country: $country, currency: $currency, fullName: $fullName, ipAddr: $ipAddr, lastLogin: $lastLogin, online: $online, profileImage: $profileImage, rateArray: $rateArray, recommendArray: $recommendArray, specialities: $specialities, state: $state, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookingInformationDoctorProfile &&
        other.address1 == address1 &&
        other.address2 == address2 &&
        other.city == city &&
        other.country == country &&
        listEquals(other.currency, currency) &&
        other.fullName == fullName &&
        other.ipAddr == ipAddr &&
        other.lastLogin == lastLogin &&
        other.online == online &&
        other.profileImage == profileImage &&
        listEquals(other.rateArray, rateArray) &&
        listEquals(other.recommendArray, recommendArray) &&
        listEquals(other.specialities, specialities) &&
        other.state == state &&
        other.id == id;
  }

  @override
  int get hashCode {
    return address1.hashCode ^
        address2.hashCode ^
        city.hashCode ^
        country.hashCode ^
        currency.hashCode ^
        fullName.hashCode ^
        ipAddr.hashCode ^
        lastLogin.hashCode ^
        online.hashCode ^
        profileImage.hashCode ^
        rateArray.hashCode ^
        recommendArray.hashCode ^
        specialities.hashCode ^
        state.hashCode ^
        id.hashCode;
  }
}

class OccupyTime {
  final DateTime createdAt;
  final String dayPeriod;
  final String doctorId;
  final BookingInformationDoctorProfile? doctorProfile;
  final DateTime expireAt;
  final DateTime finishDate;
  String patientId;
  final DateTime selectedDate;
  final String slotId;
  final DateTime startDate;
  final TimeType timeSlot;
  final DateTime updateAt;
  String id;

  OccupyTime({
    required this.createdAt,
    required this.dayPeriod,
    required this.doctorId,
    this.doctorProfile,
    required this.expireAt,
    required this.finishDate,
    required this.patientId,
    required this.selectedDate,
    required this.slotId,
    required this.startDate,
    required this.timeSlot,
    required this.updateAt,
    required this.id,
  });

  OccupyTime copyWith({
    DateTime? createdAt,
    String? dayPeriod,
    String? doctorId,
    BookingInformationDoctorProfile? doctorProfile,
    DateTime? expireAt,
    DateTime? finishDate,
    String? patientId,
    DateTime? selectedDate,
    String? slotId,
    DateTime? startDate,
    TimeType? timeSlot,
    DateTime? updateAt,
    String? id,
  }) {
    return OccupyTime(
      createdAt: createdAt ?? this.createdAt,
      dayPeriod: dayPeriod ?? this.dayPeriod,
      doctorId: doctorId ?? this.doctorId,
      doctorProfile: doctorProfile ?? this.doctorProfile,
      expireAt: expireAt ?? this.expireAt,
      finishDate: finishDate ?? this.finishDate,
      patientId: patientId ?? this.patientId,
      selectedDate: selectedDate ?? this.selectedDate,
      slotId: slotId ?? this.slotId,
      startDate: startDate ?? this.startDate,
      timeSlot: timeSlot ?? this.timeSlot,
      updateAt: updateAt ?? this.updateAt,
      id: id ?? this.id,
    );
  }

  factory OccupyTime.fromMap(Map<String, dynamic> map) {
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    DateTime parseWithTz(String? dateStr) {
      return dateStr != null ? tz.TZDateTime.from(DateTime.parse(dateStr), bangkok) : tz.TZDateTime.now(bangkok);
    }

    return OccupyTime(
      createdAt: parseWithTz(map['createdAt']),
      dayPeriod: map['dayPeriod'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorProfile: map['doctorProfile'] != null ? BookingInformationDoctorProfile.fromMap(map['doctorProfile']) : null,
      expireAt: parseWithTz(map['expireAt']),
      finishDate: parseWithTz(map['finishDate']),
      patientId: map['patientId'] ?? '',
      selectedDate: parseWithTz(map['selectedDate']),
      slotId: map['slotId'] ?? '',
      startDate: parseWithTz(map['startDate']),
      timeSlot: TimeType.fromMap(map['timeSlot'] ?? {}),
      updateAt: parseWithTz(map['updateAt']),
      id: map['_id'] ?? '',
    );
  }

  factory OccupyTime.fromJson(String source) => OccupyTime.fromMap(json.decode(source));

  factory OccupyTime.empty(
    String dayPeriod,
    String doctorId,
    String patientId,
    String slotId,
    DateTime finishDate,
    DateTime selectedDate,
    DateTime startDate,
    TimeType timeSlot,
  ) {
    return OccupyTime(
      createdAt: DateTime.now(),
      dayPeriod: dayPeriod,
      doctorId: doctorId,
      expireAt: DateTime.now(),
      finishDate: finishDate,
      patientId: patientId,
      selectedDate: selectedDate,
      slotId: slotId,
      startDate: startDate,
      timeSlot: timeSlot,
      updateAt: DateTime.now(),
      id: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'dayPeriod': dayPeriod,
      'doctorId': doctorId,
      'expireAt': expireAt.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'patientId': patientId,
      'selectedDate': selectedDate.toIso8601String(),
      'slotId': slotId,
      'startDate': startDate.toIso8601String(),
      'timeSlot': timeSlot.toJson(),
      'updateAt': updateAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'OccupyTime(createdAt: $createdAt, dayPeriod: $dayPeriod, doctorId: $doctorId, doctorProfile: $doctorProfile, expireAt: $expireAt, finishDate: $finishDate, patientId: $patientId, selectedDate: $selectedDate, slotId: $slotId, startDate: $startDate, timeSlot: $timeSlot, updateAt: $updateAt, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OccupyTime &&
        other.createdAt == createdAt &&
        other.dayPeriod == dayPeriod &&
        other.doctorId == doctorId &&
        other.doctorProfile == doctorProfile &&
        other.expireAt == expireAt &&
        other.finishDate == finishDate &&
        other.patientId == patientId &&
        other.selectedDate == selectedDate &&
        other.slotId == slotId &&
        other.startDate == startDate &&
        other.timeSlot == timeSlot &&
        other.updateAt == updateAt &&
        other.id == id;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        dayPeriod.hashCode ^
        doctorId.hashCode ^
        doctorProfile.hashCode ^
        expireAt.hashCode ^
        finishDate.hashCode ^
        patientId.hashCode ^
        selectedDate.hashCode ^
        slotId.hashCode ^
        startDate.hashCode ^
        timeSlot.hashCode ^
        updateAt.hashCode ^
        id.hashCode;
  }

}
