import 'dart:convert';

class UserData {
  final String status;
  final String country;
  final String countryCode;
  final String region;
  final String regionName;
  final String city;
  final String zip;
  final int lat;
  final int lon;
  final String timezone;
  final String isp;
  final String org;
  final String asIsp;
  final String query;

  UserData({
    required this.status,
    required this.country,
    required this.countryCode,
    required this.region,
    required this.regionName,
    required this.city,
    required this.zip,
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.isp,
    required this.org,
    required this.asIsp,
    required this.query,
  });

  UserData copyWith({
    String? status,
    String? country,
    String? countryCode,
    String? region,
    String? regionName,
    String? city,
    String? zip,
    int? lat,
    int? lon,
    String? timezone,
    String? isp,
    String? org,
    String? asIsp,
    String? query,
  }) {
    return UserData(
      status: status ?? this.status,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      region: region ?? this.region,
      regionName: regionName ?? this.regionName,
      city: city ?? this.city,
      zip: zip ?? this.zip,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      timezone: timezone ?? this.timezone,
      isp: isp ?? this.isp,
      org: org ?? this.org,
      asIsp: asIsp ?? this.asIsp,
      query: query ?? this.query,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'status': status});
    result.addAll({'country': country});
    result.addAll({'countryCode': countryCode});
    result.addAll({'region': region});
    result.addAll({'regionName': regionName});
    result.addAll({'city': city});
    result.addAll({'zip': zip});
    result.addAll({'lat': lat});
    result.addAll({'lon': lon});
    result.addAll({'timezone': timezone});
    result.addAll({'isp': isp});
    result.addAll({'org': org});
    result.addAll({'asIsp': asIsp});
    result.addAll({'query': query});
  
    return result;
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      status: map['status'] ?? '',
      country: map['country'] ?? '',
      countryCode: map['countryCode'] ?? '',
      region: map['region'] ?? '',
      regionName: map['regionName'] ?? '',
      city: map['city'] ?? '',
      zip: map['zip'] ?? '',
      lat: map['lat']?.toInt() ?? 0,
      lon: map['lon']?.toInt() ?? 0,
      timezone: map['timezone'] ?? '',
      isp: map['isp'] ?? '',
      org: map['org'] ?? '',
      asIsp: map['as'] ?? '',
      query: map['query'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) => UserData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserData(status: $status, country: $country, countryCode: $countryCode, region: $region, regionName: $regionName, city: $city, zip: $zip, lat: $lat, lon: $lon, timezone: $timezone, isp: $isp, org: $org, asIsp: $asIsp, query: $query)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserData &&
      other.status == status &&
      other.country == country &&
      other.countryCode == countryCode &&
      other.region == region &&
      other.regionName == regionName &&
      other.city == city &&
      other.zip == zip &&
      other.lat == lat &&
      other.lon == lon &&
      other.timezone == timezone &&
      other.isp == isp &&
      other.org == org &&
      other.asIsp == asIsp &&
      other.query == query;
  }

  @override
  int get hashCode {
    return status.hashCode ^
      country.hashCode ^
      countryCode.hashCode ^
      region.hashCode ^
      regionName.hashCode ^
      city.hashCode ^
      zip.hashCode ^
      lat.hashCode ^
      lon.hashCode ^
      timezone.hashCode ^
      isp.hashCode ^
      org.hashCode ^
      asIsp.hashCode ^
      query.hashCode;
  }
}
