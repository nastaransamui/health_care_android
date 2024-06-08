import 'dart:convert';

import 'package:flutter/foundation.dart';

class Cities {
  final String mongoId;
  final int id;
  final String name;
  final bool isActive;
  final int countryId;
  final String countryName;
  final int stateId;
  final String stateName;
  final String iso2;
  final String latitude;
  final String longitude;
  final List<String> usersId;
  final String emoji;
  final String? subtitle;

  Cities({
    required this.mongoId,
    required this.id,
    required this.name,
    required this.isActive,
    required this.countryId,
    required this.countryName,
    required this.stateId,
    required this.stateName,
    required this.iso2,
    required this.latitude,
    required this.longitude,
    required this.usersId,
    required this.emoji,
    required this.subtitle,
  });

  Cities copyWith({
    String? mongoId,
    int? id,
    String? name,
    bool? isActive,
    int? countryId,
    String? countryName,
    int? stateId,
    String? stateName,
    String? iso2,
    String? latitude,
    String? longitude,
    List<String>? usersId,
    String? emoji,
    String? subtitle,
  }) {
    return Cities(
      mongoId: mongoId ?? this.mongoId,
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      stateId: stateId ?? this.stateId,
      stateName: stateName ?? this.stateName,
      iso2: iso2 ?? this.iso2,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      usersId: usersId ?? this.usersId,
      emoji: emoji ?? this.emoji,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'mongoId': mongoId});
    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'isActive': isActive});
    result.addAll({'countryId': countryId});
    result.addAll({'countryName': countryName});
    result.addAll({'stateId': stateId});
    result.addAll({'stateName': stateName});
    result.addAll({'iso2': iso2});
    result.addAll({'latitude': latitude});
    result.addAll({'longitude': longitude});
    result.addAll({'usersId': usersId});
    result.addAll({'emoji': emoji});
    if(subtitle != null){
      result.addAll({'subtitle': subtitle});
    }
  
    return result;
  }

  factory Cities.fromMap(Map<String, dynamic> map) {
    return Cities(
      mongoId: map['_id'] ?? '',
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      isActive: map['isActive'] ?? false,
      countryId: map['country_id']?.toInt() ?? 0,
      countryName: map['country_name'] ?? '',
      stateId: map['state_id']?.toInt() ?? 0,
      stateName: map['state_name'] ?? '',
      iso2: map['iso2'] ?? '',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      usersId: List<String>.from(map['users_id']),
      emoji: map['emoji'] ?? '',
      subtitle: map['subtitle'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Cities.fromJson(String source) => Cities.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Cities(mongoId: $mongoId, id: $id, name: $name, isActive: $isActive, countryId: $countryId, countryName: $countryName, stateId: $stateId, stateName: $stateName, iso2: $iso2, latitude: $latitude, longitude: $longitude, usersId: $usersId, emoji: $emoji, subtitle: $subtitle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Cities &&
      other.mongoId == mongoId &&
      other.id == id &&
      other.name == name &&
      other.isActive == isActive &&
      other.countryId == countryId &&
      other.countryName == countryName &&
      other.stateId == stateId &&
      other.stateName == stateName &&
      other.iso2 == iso2 &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      listEquals(other.usersId, usersId) &&
      other.emoji == emoji &&
      other.subtitle == subtitle;
  }

  @override
  int get hashCode {
    return mongoId.hashCode ^
      id.hashCode ^
      name.hashCode ^
      isActive.hashCode ^
      countryId.hashCode ^
      countryName.hashCode ^
      stateId.hashCode ^
      stateName.hashCode ^
      iso2.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      usersId.hashCode ^
      emoji.hashCode ^
      subtitle.hashCode;
  }
}
