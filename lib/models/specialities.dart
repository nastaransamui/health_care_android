import 'dart:convert';
import 'package:flutter/foundation.dart';

class Specialities {
  final String? id; // _id is optional
  final int specialityId; // Changed to match the `id` type as number in TypeScript
  final String specialities;
  final String description;
  final String image;
  final String imageId;
  final List<String> usersId; // users_id is a list of strings
  final DateTime createdAt; // Date type in TypeScript is converted to DateTime in Dart
  final DateTime updatedAt; // Same as createdAt

  Specialities({
    this.id,
    required this.specialityId,
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
    int? specialityId,
    String? specialities,
    String? description,
    String? image,
    String? imageId,
    List<String>? usersId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Specialities(
      id: id ?? this.id,
      specialityId: specialityId ?? this.specialityId,
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

    result.addAll({'_id': id});
    result.addAll({'id': specialityId});
    result.addAll({'specialities': specialities});
    result.addAll({'description': description});
    result.addAll({'image': image});
    result.addAll({'imageId': imageId});
    result.addAll({'users_id': usersId});
    result.addAll({'createdAt': createdAt.toIso8601String()});
    result.addAll({'updatedAt': updatedAt.toIso8601String()});
    return result;
  }

  factory Specialities.fromMap(Map<String, dynamic> map) {
    return Specialities(
      id: map['_id'], // _id is optional
      specialityId: map['id'], // Match with the TypeScript `id` field
      specialities: map['specialities'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      imageId: map['imageId'] ?? '',
      usersId: map['users_id'] != null 
      ? List<String>.from(map['users_id']) 
      : [],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Specialities.fromJson(String source) =>
      Specialities.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Specialities(id: $id, specialityId: $specialityId, specialities: $specialities, description: $description, image: $image, imageId: $imageId, usersId: $usersId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Specialities &&
        other.id == id &&
        other.specialityId == specialityId &&
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
        specialityId.hashCode ^
        specialities.hashCode ^
        description.hashCode ^
        image.hashCode ^
        imageId.hashCode ^
        usersId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}