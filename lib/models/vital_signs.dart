import 'dart:convert';

import 'package:flutter/foundation.dart';

class VitalSigns {
  final String id;
  final String userId;
  final List<VitalSignValues> heartRate;
  final List<VitalSignValues> bodyTemp;
  final List<VitalSignValues> weight;
  final List<VitalSignValues> height;

  VitalSigns({
    required this.id,
    required this.userId,
    required this.heartRate,
    required this.bodyTemp,
    required this.weight,
    required this.height,
  });

  VitalSigns copyWith({
    String? id,
    String? userId,
    List<VitalSignValues>? heartRate,
    List<VitalSignValues>? bodyTemp,
    List<VitalSignValues>? weight,
    List<VitalSignValues>? height,
  }) {
    return VitalSigns(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      heartRate: heartRate ?? this.heartRate,
      bodyTemp: bodyTemp ?? this.bodyTemp,
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'id': id});
    result.addAll({'userId': userId});
    result.addAll({'heartRate': heartRate.map((x) => x.toMap()).toList()});
    result.addAll({'bodyTemp': bodyTemp.map((x) => x.toMap()).toList()});
    result.addAll({'weight': weight.map((x) => x.toMap()).toList()});
    result.addAll({'height': height.map((x) => x.toMap()).toList()});
  
    return result;
  }

  factory VitalSigns.fromMap(Map<String, dynamic> map) {

    return VitalSigns(
      id: map['_id'] ?? '',
      userId: map['userId'] ?? '',
      heartRate: map['heartRate'] != null ? List<VitalSignValues>.from(map['heartRate']?.map((x) => VitalSignValues.fromMap(x))) : [],
      bodyTemp: map['bodyTemp'] != null ? List<VitalSignValues>.from(map['bodyTemp']?.map((x) => VitalSignValues.fromMap(x))) : [],
      weight:map['weight'] != null ? List<VitalSignValues>.from(map['weight']?.map((x) => VitalSignValues.fromMap(x))) : [],
      height: map['height'] != null ? List<VitalSignValues>.from(map['height']?.map((x) => VitalSignValues.fromMap(x))): [],
    );
  }

  String toJson() => json.encode(toMap());

  factory VitalSigns.fromJson(String source) => VitalSigns.fromMap(json.decode(source));

  @override
  String toString() {
    return 'VitalSigns(id: $id, userId: $userId, heartRate: $heartRate, bodyTemp: $bodyTemp, weight: $weight, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is VitalSigns &&
      other.id == id &&
      other.userId == userId &&
      listEquals(other.heartRate, heartRate) &&
      listEquals(other.bodyTemp, bodyTemp) &&
      listEquals(other.weight, weight) &&
      listEquals(other.height, height);
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      heartRate.hashCode ^
      bodyTemp.hashCode ^
      weight.hashCode ^
      height.hashCode;
  }
}

class VitalSignValues {
  final int value;
  final DateTime date;
  final int id;

  VitalSignValues({
    required this.value,
    required this.date,
    required this.id
  });

  VitalSignValues copyWith({
    int? value,
    DateTime? date,
    int ? id,
  }) {
    return VitalSignValues(
      value: value ?? this.value,
      date: date ?? this.date,
      id: id ?? this.id
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'value': value});
    result.addAll({'date': date});
    result.addAll({'id': id});

    return result;
  }

  factory VitalSignValues.fromMap(Map<String, dynamic> map) {
    return VitalSignValues(
      value: map['value']?? 0,
      date: DateTime.parse(map['date']).toLocal(),
      id: map['id'] ?? 0,

    );
  }

  String toJson() => json.encode(toMap());

  factory VitalSignValues.fromJson(String source) =>
      VitalSignValues.fromMap(json.decode(source));

  @override
  String toString() => 'VitalSignValues(value: $value, date: $date, id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VitalSignValues &&
        other.value == value &&
        other.date == date&&
        other.id == id;
  }

  @override
  int get hashCode => value.hashCode ^ date.hashCode;
}
