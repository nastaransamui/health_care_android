import 'dart:convert';

import 'package:flutter/foundation.dart';

class Countries {
  final String mongoId;
  final int id;
  final String name;
  final bool isActive;
  final String iso3;
  final String iso2;
  final List<String> usersId;
  final List<String> statesId;
  final List<String> citiesId;
  final String numericCode;
  final String phoneCode;
  final String capital;
  final String currency;
  final String currencyName;
  final String currencySymbol;
  final String tld;
  final String nativeName;
  final String region;
  final String subregion;
  final List<TimeZones> timezones;
  final Translations translations;
  final String latitude;
  final String longitude;
  final String emoji;
  final String emojiU;
  final String? subtitle;

  Countries({
    required this.mongoId,
    required this.id,
    required this.name,
    required this.isActive,
    required this.iso3,
    required this.iso2,
    required this.usersId,
    required this.statesId,
    required this.citiesId,
    required this.numericCode,
    required this.phoneCode,
    required this.capital,
    required this.currency,
    required this.currencyName,
    required this.currencySymbol,
    required this.tld,
    required this.nativeName,
    required this.region,
    required this.subregion,
    required this.timezones,
    required this.translations,
    required this.latitude,
    required this.longitude,
    required this.emoji,
    required this.emojiU,
    this.subtitle,
  });

  Countries copyWith({
    String? mongoId,
    int? id,
    String? name,
    bool? isActive,
    String? iso3,
    String? iso2,
    List<String>? usersId,
    List<String>? statesId,
    List<String>? citiesId,
    String? numericCode,
    String? phoneCode,
    String? capital,
    String? currency,
    String? currencyName,
    String? currencySymbol,
    String? tld,
    String? nativeName,
    String? region,
    String? subregion,
    List<TimeZones>? timezones,
    Translations? translations,
    String? latitude,
    String? longitude,
    String? emoji,
    String? emojiU,
    String? subtitle,
  }) {
    return Countries(
      mongoId: mongoId ?? this.mongoId,
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      iso3: iso3 ?? this.iso3,
      iso2: iso2 ?? this.iso2,
      usersId: usersId ?? this.usersId,
      statesId: statesId ?? this.statesId,
      citiesId: citiesId ?? this.citiesId,
      numericCode: numericCode ?? this.numericCode,
      phoneCode: phoneCode ?? this.phoneCode,
      capital: capital ?? this.capital,
      currency: currency ?? this.currency,
      currencyName: currencyName ?? this.currencyName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      tld: tld ?? this.tld,
      nativeName: nativeName ?? this.nativeName,
      region: region ?? this.region,
      subregion: subregion ?? this.subregion,
      timezones: timezones ?? this.timezones,
      translations: translations ?? this.translations,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      emoji: emoji ?? this.emoji,
      emojiU: emojiU ?? this.emojiU,
      subtitle: subtitle ?? this.subtitle
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'mongoId': mongoId});
    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'isActive': isActive});
    result.addAll({'iso3': iso3});
    result.addAll({'iso2': iso2});
    result.addAll({'usersId': usersId});
    result.addAll({'statesId': statesId});
    result.addAll({'citiesId': citiesId});
    result.addAll({'numericCode': numericCode});
    result.addAll({'phoneCode': phoneCode});
    result.addAll({'capital': capital});
    result.addAll({'currency': currency});
    result.addAll({'currencyName': currencyName});
    result.addAll({'currencySymbol': currencySymbol});
    result.addAll({'tld': tld});
    result.addAll({'nativeName': nativeName});
    result.addAll({'region': region});
    result.addAll({'subregion': subregion});
    result.addAll({'timezones': timezones.map((x) => x.toMap()).toList()});
    result.addAll({'translations': translations.toMap()});
    result.addAll({'latitude': latitude});
    result.addAll({'longitude': longitude});
    result.addAll({'emoji': emoji});
    result.addAll({'emojiU': emojiU});
    result.addAll({'subtitle': subtitle});
  
    return result;
  }

  factory Countries.fromMap(Map<String, dynamic> map) {
    return Countries(
      mongoId: map['_id'] ?? '',
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      isActive: map['isActive'] ?? false,
      iso3: map['iso3'] ?? '',
      iso2: map['iso2'] ?? '',
      usersId: List<String>.from(map['users_id']),
      statesId: List<String>.from(map['states_id']),
      citiesId: List<String>.from(map['cities_id']),
      numericCode: map['numeric_code'] ?? '',
      phoneCode: map['phone_code'] ?? '',
      capital: map['capital'] ?? '',
      currency: map['currency'] ?? '',
      currencyName: map['currency_name'] ?? '',
      currencySymbol: map['currency_symbol'] ?? '',
      tld: map['tld'] ?? '',
      nativeName: map['native'] ?? '',
      region: map['region'] ?? '',
      subregion: map['subregion'] ?? '',
      timezones: List<TimeZones>.from(map['timezones']?.map((x) => TimeZones.fromMap(x))),
      translations: Translations.fromMap(map['translations']),
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      emoji: map['emoji'] ?? '',
      emojiU: map['emojiU'] ?? '',
      subtitle: map['subtitle'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Countries.fromJson(String source) => Countries.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Countries(mongoId: $mongoId, id: $id, name: $name, isActive: $isActive, iso3: $iso3, iso2: $iso2, usersId: $usersId, statesId: $statesId, citiesId: $citiesId, numericCode: $numericCode, phoneCode: $phoneCode, capital: $capital, currency: $currency, currencyName: $currencyName, currencySymbol: $currencySymbol, tld: $tld, nativeName: $nativeName, region: $region, subregion: $subregion, timezones: $timezones, translations: $translations, latitude: $latitude, longitude: $longitude, emoji: $emoji, emojiU: $emojiU, subtitle: $subtitle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Countries &&
      other.mongoId == mongoId &&
      other.id == id &&
      other.name == name &&
      other.isActive == isActive &&
      other.iso3 == iso3 &&
      other.iso2 == iso2 &&
      listEquals(other.usersId, usersId) &&
      listEquals(other.statesId, statesId) &&
      listEquals(other.citiesId, citiesId) &&
      other.numericCode == numericCode &&
      other.phoneCode == phoneCode &&
      other.capital == capital &&
      other.currency == currency &&
      other.currencyName == currencyName &&
      other.currencySymbol == currencySymbol &&
      other.tld == tld &&
      other.nativeName == nativeName &&
      other.region == region &&
      other.subregion == subregion &&
      listEquals(other.timezones, timezones) &&
      other.translations == translations &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.emoji == emoji &&
      other.emojiU == emojiU&&
      other.subtitle == subtitle;
  }

  @override
  int get hashCode {
    return mongoId.hashCode ^
      id.hashCode ^
      name.hashCode ^
      isActive.hashCode ^
      iso3.hashCode ^
      iso2.hashCode ^
      usersId.hashCode ^
      statesId.hashCode ^
      citiesId.hashCode ^
      numericCode.hashCode ^
      phoneCode.hashCode ^
      capital.hashCode ^
      currency.hashCode ^
      currencyName.hashCode ^
      currencySymbol.hashCode ^
      tld.hashCode ^
      nativeName.hashCode ^
      region.hashCode ^
      subregion.hashCode ^
      timezones.hashCode ^
      translations.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      emoji.hashCode ^
      emojiU.hashCode^
      subtitle.hashCode;
  }
}

class TimeZones {
  final String zoneName;
  final double gmtOffset;
  final String gmtOffsetName;
  final String abbreviation;
  final String tzName;

  TimeZones({
    required this.zoneName,
    required this.gmtOffset,
    required this.gmtOffsetName,
    required this.abbreviation,
    required this.tzName,
  });

  TimeZones copyWith({
    String? zoneName,
    double? gmtOffset,
    String? gmtOffsetName,
    String? abbreviation,
    String? tzName,
  }) {
    return TimeZones(
      zoneName: zoneName ?? this.zoneName,
      gmtOffset: gmtOffset ?? this.gmtOffset,
      gmtOffsetName: gmtOffsetName ?? this.gmtOffsetName,
      abbreviation: abbreviation ?? this.abbreviation,
      tzName: tzName ?? this.tzName,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'zoneName': zoneName});
    result.addAll({'gmtOffset': gmtOffset});
    result.addAll({'gmtOffsetName': gmtOffsetName});
    result.addAll({'abbreviation': abbreviation});
    result.addAll({'tzName': tzName});

    return result;
  }

  factory TimeZones.fromMap(Map<String, dynamic> map) {
    return TimeZones(
      zoneName: map['zoneName'] ?? '',
      gmtOffset: map['gmtOffset']?.toDouble() ?? 0.0,
      gmtOffsetName: map['gmtOffsetName'] ?? '',
      abbreviation: map['abbreviation'] ?? '',
      tzName: map['tzName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeZones.fromJson(String source) =>
      TimeZones.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TimeZones(zoneName: $zoneName, gmtOffset: $gmtOffset, gmtOffsetName: $gmtOffsetName, abbreviation: $abbreviation, tzName: $tzName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimeZones &&
        other.zoneName == zoneName &&
        other.gmtOffset == gmtOffset &&
        other.gmtOffsetName == gmtOffsetName &&
        other.abbreviation == abbreviation &&
        other.tzName == tzName;
  }

  @override
  int get hashCode {
    return zoneName.hashCode ^
        gmtOffset.hashCode ^
        gmtOffsetName.hashCode ^
        abbreviation.hashCode ^
        tzName.hashCode;
  }
}

class Translations {
  final String kr;
  final String br;
  final String pt;
  final String nl;
  final String hr;
  final String fa;
  final String de;
  final String es;
  final String fr;
  final String ja;
  final String it;
  final String cn;
  final String th;

  Translations({
    required this.kr,
    required this.br,
    required this.pt,
    required this.nl,
    required this.hr,
    required this.fa,
    required this.de,
    required this.es,
    required this.fr,
    required this.ja,
    required this.it,
    required this.cn,
    required this.th,
  });

  Translations copyWith({
    String? kr,
    String? br,
    String? pt,
    String? nl,
    String? hr,
    String? fa,
    String? de,
    String? es,
    String? fr,
    String? ja,
    String? it,
    String? cn,
    String? th,
  }) {
    return Translations(
      kr: kr ?? this.kr,
      br: br ?? this.br,
      pt: pt ?? this.pt,
      nl: nl ?? this.nl,
      hr: hr ?? this.hr,
      fa: fa ?? this.fa,
      de: de ?? this.de,
      es: es ?? this.es,
      fr: fr ?? this.fr,
      ja: ja ?? this.ja,
      it: it ?? this.it,
      cn: cn ?? this.cn,
      th: th ?? this.th,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'kr': kr});
    result.addAll({'br': br});
    result.addAll({'pt': pt});
    result.addAll({'nl': nl});
    result.addAll({'hr': hr});
    result.addAll({'fa': fa});
    result.addAll({'de': de});
    result.addAll({'es': es});
    result.addAll({'fr': fr});
    result.addAll({'ja': ja});
    result.addAll({'it': it});
    result.addAll({'cn': cn});
    result.addAll({'th': th});

    return result;
  }

  factory Translations.fromMap(Map<String, dynamic> map) {
    return Translations(
      kr: map['kr'] ?? '',
      br: map['br'] ?? '',
      pt: map['pt'] ?? '',
      nl: map['nl'] ?? '',
      hr: map['hr'] ?? '',
      fa: map['fa'] ?? '',
      de: map['de'] ?? '',
      es: map['es'] ?? '',
      fr: map['fr'] ?? '',
      ja: map['ja'] ?? '',
      it: map['it'] ?? '',
      cn: map['cn'] ?? '',
      th: map['th'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Translations.fromJson(String source) =>
      Translations.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Translations(kr: $kr, br: $br, pt: $pt, nl: $nl, hr: $hr, fa: $fa, de: $de, es: $es, fr: $fr, ja: $ja, it: $it, cn: $cn, th: $th)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Translations &&
        other.kr == kr &&
        other.br == br &&
        other.pt == pt &&
        other.nl == nl &&
        other.hr == hr &&
        other.fa == fa &&
        other.de == de &&
        other.es == es &&
        other.fr == fr &&
        other.ja == ja &&
        other.it == it &&
        other.cn == cn &&
        other.th == th;
  }

  @override
  int get hashCode {
    return kr.hashCode ^
        br.hashCode ^
        pt.hashCode ^
        nl.hashCode ^
        hr.hashCode ^
        fa.hashCode ^
        de.hashCode ^
        es.hashCode ^
        fr.hashCode ^
        ja.hashCode ^
        it.hashCode ^
        cn.hashCode ^
        th.hashCode;
  }
}
