import 'dart:convert';

class ThemeFromAdmin {
  final String id;
  final String homeThemeName;
  final String homeThemeType;
  final String homeRedirect;
  final String homeActivePage;
  final String updatedAt;
  final String createdAt;

  ThemeFromAdmin({
    required this.id,
    required this.homeThemeName,
    required this.homeThemeType,
    required this.homeRedirect,
    required this.homeActivePage,
    required this.updatedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'homeThemeName': homeThemeName});
    result.addAll({'homeThemeType': homeThemeType});
    result.addAll({'homeRedirect': homeRedirect});
    result.addAll({'homeActivePage': homeActivePage});
    result.addAll({'updatedAt': updatedAt});
    result.addAll({'createdAt': createdAt});
    return result;
  }

  factory ThemeFromAdmin.fromMap(Map<String, dynamic> map) {
    return ThemeFromAdmin(
      id: map['_id'],
      homeThemeName: map['homeThemeName'],
      homeThemeType: map['homeThemeType'],
      homeRedirect: map['homeRedirect'],
      homeActivePage: map['homeActivePage'],
      updatedAt: map['updatedAt'],
      createdAt: map['createdAt'],
    );
  }

  dynamic returnToJson(data) => jsonDecode(data);

  String toJson() => json.encode(toMap());

  factory ThemeFromAdmin.fromJson(String source) =>
      ThemeFromAdmin.fromMap(json.decode(source));

  ThemeFromAdmin copyWith({
    String? id,
    String? homeThemeName,
    String? homeThemeType,
    String? homeRedirect,
    String? homeActivePage,
    String? updatedAt,
    String? createdAt,
  }) {
    return ThemeFromAdmin(
      id: id ?? this.id,
      homeThemeName: this.homeThemeName,
      homeThemeType: this.homeThemeType,
      homeRedirect: this.homeRedirect,
      homeActivePage: this.homeActivePage,
      updatedAt: this.updatedAt,
      createdAt: this.createdAt,
    );
  }
}
