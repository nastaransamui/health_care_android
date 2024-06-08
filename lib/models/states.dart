import 'dart:convert';

import 'package:flutter/foundation.dart';

class States {
  final String mongoId;
  final int id;
  final String name;
  final bool isActive;
  final int countryId;
  final String countryName;
  final String iso2;
  final String stateCode;
  final String? type;
  final String latitude;
  final String longitude;
  final String emoji;
  final List<String> usersId;
  final List<String> citiesId;
  final String? subtitle;

  States({
    required this.mongoId,
    required this.id,
    required this.name,
    required this.isActive,
    required this.countryId,
    required this.countryName,
    required this.iso2,
    required this.stateCode,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.emoji,
    required this.usersId,
    required this.citiesId,
    required this.subtitle,
  });

  States copyWith({
    String? mongoId,
    int? id,
    String? name,
    bool? isActive,
    int? countryId,
    String? countryName,
    String? iso2,
    String? stateCode,
    String? type,
    String? latitude,
    String? longitude,
    String? emoji,
    List<String>? usersId,
    List<String>? citiesId,
    String? subtitle,
  }) {
    return States(
      mongoId: mongoId ?? this.mongoId,
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      iso2: iso2 ?? this.iso2,
      stateCode: stateCode ?? this.stateCode,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      emoji: emoji ?? this.emoji,
      usersId: usersId ?? this.usersId,
      citiesId: citiesId ?? this.citiesId,
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
    result.addAll({'iso2': iso2});
    result.addAll({'stateCode': stateCode});
    if(type != null){
      result.addAll({'type': type});
    }
    result.addAll({'latitude': latitude});
    result.addAll({'longitude': longitude});
    result.addAll({'emoji': emoji});
    result.addAll({'usersId': usersId});
    result.addAll({'citiesId': citiesId});
    if(subtitle != null){
      result.addAll({'subtitle': subtitle});
    }
  
    return result;
  }

  factory States.fromMap(Map<String, dynamic> map) {
    return States(
      mongoId: map['_id'] ?? '',
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      isActive: map['isActive'] ?? false,
      countryId: map['country_id']?.toInt() ?? '',
      countryName: map['country_name'] ?? '',
      iso2: map['iso2'] ?? '',
      stateCode: map['state_code'] ?? '',
      type: map['type'],
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      emoji: map['emoji'] ?? '',
      usersId: List<String>.from(map['users_id']),
      citiesId: List<String>.from(map['cities_id']),
      subtitle: map['subtitle'],
    );
  }

  String toJson() => json.encode(toMap());

  factory States.fromJson(String source) => States.fromMap(json.decode(source));

  @override
  String toString() {
    return 'States(mongoId: $mongoId, id: $id, name: $name, isActive: $isActive, countryId: $countryId, countryName: $countryName, iso2: $iso2, stateCode: $stateCode, type: $type, latitude: $latitude, longitude: $longitude, emoji: $emoji, usersId: $usersId, citiesId: $citiesId, subtitle: $subtitle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is States &&
      other.mongoId == mongoId &&
      other.id == id &&
      other.name == name &&
      other.isActive == isActive &&
      other.countryId == countryId &&
      other.countryName == countryName &&
      other.iso2 == iso2 &&
      other.stateCode == stateCode &&
      other.type == type &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.emoji == emoji &&
      listEquals(other.usersId, usersId) &&
      listEquals(other.citiesId, citiesId) &&
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
      iso2.hashCode ^
      stateCode.hashCode ^
      type.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      emoji.hashCode ^
      usersId.hashCode ^
      citiesId.hashCode ^
      subtitle.hashCode;
  }
}
