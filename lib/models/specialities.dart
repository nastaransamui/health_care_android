import 'dart:convert';

import 'package:flutter/foundation.dart';

class Specialities {
  final String id;
  final String specialities;
  final String description;
  final String image;
  final String imageId;
  final List<dynamic> usersId;
  final String createdAt;
  final String updatedAt;

  Specialities({
    required this.id,
    required this.specialities,
    required this.description,
    required this.image,
    required this.imageId,
    required this.usersId,
    required this.createdAt,
    required this.updatedAt,
  });

  Specialities copyWith({
    String? id,
    String? specialities,
    String? description,
    String? image,
    String? imageId,
    List<String>? usersId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Specialities(
      id: id ?? this.id,
      specialities: specialities ?? this.specialities,
      description: description ?? this.description,
      image: image ?? this.image,
      imageId: imageId ?? this.imageId,
      usersId: usersId ?? this.usersId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'specialities': specialities});
    result.addAll({'description': description});
    result.addAll({'image': image});
    result.addAll({'imageId': imageId});
    result.addAll({'usersId': usersId});
    result.addAll({'createdAt': createdAt});
    result.addAll({'updatedAt': updatedAt});
    return result;
  }

  factory Specialities.fromMap(Map<String, dynamic> map) {
    return Specialities(
      id: map['_id'] ?? '',
      specialities: map['specialities'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      imageId: map['imageId'] ?? '',
      usersId: List<String>.from(map['users_id']),
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  // factory Specialities.fromJson(String source) => Specialities.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Specialities(id: $id, specialities: $specialities, description: $description, image: $image, imageId: $imageId, usersId: $usersId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Specialities &&
        other.id == id &&
        other.specialities == specialities &&
        other.description == description &&
        other.image == image &&
        other.imageId == imageId &&
        listEquals(other.usersId, usersId) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        specialities.hashCode ^
        description.hashCode ^
        image.hashCode ^
        imageId.hashCode ^
        usersId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
