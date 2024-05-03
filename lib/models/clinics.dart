import 'dart:convert';

import 'package:flutter/foundation.dart';

class Clinics {
  final String id;
  final String href;
  final bool active;
  final bool hasThemeImage;
  final String image;
  final String name;
  final Map<dynamic, dynamic> customStyle;
  final String createdAt;
  final String updatedAt;

  Clinics({
    required this.id,
    required this.href,
    required this.active,
    required this.hasThemeImage,
    required this.image,
    required this.name,
    required this.customStyle,
    required this.createdAt,
    required this.updatedAt,
  });

  Clinics copyWith({
    String? id,
    String? href,
    bool? active,
    bool? hasThemeImage,
    String? image,
    String? name,
    Map<dynamic, dynamic>? customStyle,
    String? createdAt,
    String? updatedAt,
  }) {
    return Clinics(
      id: id ?? this.id,
      href: href ?? this.href,
      active: active ?? this.active,
      hasThemeImage: hasThemeImage ?? this.hasThemeImage,
      image: image ?? this.image,
      name: name ?? this.name,
      customStyle: customStyle ?? this.customStyle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'id': id});
    result.addAll({'href': href});
    result.addAll({'active': active});
    result.addAll({'hasThemeImage': hasThemeImage});
    result.addAll({'image': image});
    result.addAll({'name': name});
    result.addAll({'customStyle': customStyle});
    result.addAll({'createdAt': createdAt});
    result.addAll({'updatedAt': updatedAt});
  
    return result;
  }

  factory Clinics.fromMap(Map<String, dynamic> map) {
    return Clinics(
      id: map['_id'] ?? '',
      href: map['href'] ?? '',
      active: map['active'] ?? false,
      hasThemeImage: map['hasThemeImage'] ?? false,
      image: map['image'] ?? '',
      name: map['name'] ?? '',
      customStyle: Map<dynamic, dynamic>.from(map['customStyle']),
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  // factory Clinics.fromJson(String source) => Clinics.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Clinics(id: $id, href: $href, active: $active, hasThemeImage: $hasThemeImage, image: $image, name: $name, customStyle: $customStyle, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Clinics &&
      other.id == id &&
      other.href == href &&
      other.active == active &&
      other.hasThemeImage == hasThemeImage &&
      other.image == image &&
      other.name == name &&
      mapEquals(other.customStyle, customStyle) &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      href.hashCode ^
      active.hashCode ^
      hasThemeImage.hashCode ^
      image.hashCode ^
      name.hashCode ^
      customStyle.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}
