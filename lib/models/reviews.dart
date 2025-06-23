import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:health_care/models/users.dart';

class Reviews {
  final String id;
  final int reviewId;
  final String doctorId;
  final String authorId;
  final String role;
  final String title;
  final String body;
  final double rating;
  final bool recommend;
  final List<ReviewsReplies> replies;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PatientUserProfile patientProfile;

  Reviews({
    required this.id,
    required this.reviewId,
    required this.doctorId,
    required this.authorId,
    required this.role,
    required this.title,
    required this.body,
    required this.rating,
    required this.recommend,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
    required this.patientProfile,
  });

  Reviews copyWith({
    String? id,
    int? reviewId,
    String? doctorId,
    String? authorId,
    String? role,
    String? title,
    String? body,
    double? rating,
    bool? recommend,
    List<ReviewsReplies>? replies,
    DateTime? createdAt,
    DateTime? updatedAt,
    DoctorUserProfile? doctorProfile,
    PatientUserProfile? patientProfile,
  }) {
    return Reviews(
      id: id ?? this.id,
      reviewId: reviewId ?? this.reviewId,
      doctorId: doctorId ?? this.doctorId,
      authorId: authorId ?? this.authorId,
      role: role ?? this.role,
      title: title ?? this.title,
      body: body ?? this.body,
      rating: rating ?? this.rating,
      recommend: recommend ?? this.recommend,
      replies: replies ?? this.replies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patientProfile: patientProfile ?? this.patientProfile,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'reviewId': reviewId});
    result.addAll({'doctorId': doctorId});
    result.addAll({'authorId': authorId});
    result.addAll({'role': role});
    result.addAll({'title': title});
    result.addAll({'body': body});
    result.addAll({'rating': rating});
    result.addAll({'recommend': recommend});
    result.addAll({'replies': replies.map((x) => x.toMap()).toList()});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'updatedAt': updatedAt.millisecondsSinceEpoch});
    result.addAll({'patientProfile': patientProfile.toMap()});

    return result;
  }

  factory Reviews.fromMap(Map<String, dynamic> map) {
    return Reviews(
      id: map['_id'] ?? '',
      reviewId: map['id']?.toInt() ?? 0,
      doctorId: map['doctorId'] ?? '',
      authorId: map['authorId'] ?? '',
      role: map['role'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      recommend: map['recommend'],
      replies: List<ReviewsReplies>.from(map['replies']?.map((x) => ReviewsReplies.fromMap(x))),
      createdAt: (map['createdAt'] == null || map['createdAt'] == '') ? DateTime.now() : DateTime.parse(map['createdAt']),
      updatedAt: (map['updatedAt'] == null || map['updatedAt'] == '') ? DateTime.now() : DateTime.parse(map['updatedAt']),
      patientProfile: PatientUserProfile.fromMap(map['patientProfile']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Reviews.fromJson(String source) => Reviews.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Reviews(id: $id, reviewId: $reviewId, doctorId: $doctorId, authorId: $authorId, role: $role, title: $title, body: $body, rating: $rating, recommend: $recommend, replies: $replies, createdAt: $createdAt, updatedAt: $updatedAt,  patientProfile: $patientProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is Reviews &&
        other.id == id &&
        other.reviewId == reviewId &&
        other.doctorId == doctorId &&
        other.authorId == authorId &&
        other.role == role &&
        other.title == title &&
        other.body == body &&
        other.rating == rating &&
        other.recommend == recommend &&
        listEquals(other.replies, replies) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.patientProfile == patientProfile;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        reviewId.hashCode ^
        doctorId.hashCode ^
        authorId.hashCode ^
        role.hashCode ^
        title.hashCode ^
        body.hashCode ^
        rating.hashCode ^
        recommend.hashCode ^
        replies.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        patientProfile.hashCode;
  }
}

class ReviewsReplies {
  final String id;
  final String authorId;
  final String parentId;
  final String role;
  final String title;
  final String body;
  final List<ReviewsReplies> replies;
  final int replyId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DoctorUserProfile? doctorProfile;
  final PatientUserProfile? patientProfile;

  ReviewsReplies({
    required this.id,
    required this.replyId,
    required this.authorId,
    required this.role,
    required this.title,
    required this.body,
    required this.parentId,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
    this.patientProfile,
    this.doctorProfile,
  });

  ReviewsReplies copyWith(
      {String? id,
      int? replyId,
      String? authorId,
      String? role,
      String? title,
      String? body,
      String? parentId,
      List<ReviewsReplies>? replies,
      DateTime? createdAt,
      DateTime? updatedAt,
      PatientUserProfile? patientProfile,
      DoctorUserProfile? doctorProfile}) {
    return ReviewsReplies(
      id: id ?? this.id,
      replyId: replyId ?? this.replyId,
      authorId: authorId ?? this.authorId,
      role: role ?? this.role,
      title: title ?? this.title,
      body: body ?? this.body,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patientProfile: patientProfile ?? this.patientProfile,
      doctorProfile: doctorProfile ?? this.doctorProfile,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'replyId': replyId});
    result.addAll({'authorId': authorId});
    result.addAll({'role': role});
    result.addAll({'title': title});
    result.addAll({'body': body});
    result.addAll({'parentId': parentId});
    result.addAll({'replies': replies.map((x) => x.toMap()).toList()});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'updatedAt': updatedAt.millisecondsSinceEpoch});
    result.addAll({'patientProfile': patientProfile?.toMap()});
    result.addAll({'doctorProfile': doctorProfile?.toMap()});

    return result;
  }

  factory ReviewsReplies.fromMap(Map<String, dynamic> map) {
    return ReviewsReplies(
      id: map['_id'] ?? '',
      replyId: map['id']?.toInt() ?? 0,
      authorId: map['authorId'] ?? '',
      role: map['role'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      parentId: map['parentId'] ?? '',
      replies: List<ReviewsReplies>.from(map['replies']?.map((x) => ReviewsReplies.fromMap(x))),
      createdAt: (map['createdAt'] == null || map['createdAt'] == '') ? DateTime.now() : DateTime.parse(map['createdAt']),
      updatedAt: (map['updatedAt'] == null || map['updatedAt'] == '') ? DateTime.now() : DateTime.parse(map['updatedAt']),
      patientProfile: map['patientProfile'] != null ? PatientUserProfile.fromMap(map['patientProfile']) : null,
      doctorProfile: map['doctorProfile'] != null ? DoctorUserProfile.fromMap(map['doctorProfile']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewsReplies.fromJson(String source) => ReviewsReplies.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ReviewsReplies(id: $id, replyId: $replyId, authorId: $authorId, role: $role, title: $title, body: $body, parentId: $parentId, replies: $replies, createdAt: $createdAt, updatedAt: $updatedAt,  patientProfile: $patientProfile, doctorProfile: $doctorProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is ReviewsReplies &&
        other.id == id &&
        other.replyId == replyId &&
        other.authorId == authorId &&
        other.role == role &&
        other.title == title &&
        other.body == body &&
        other.parentId == parentId &&
        listEquals(other.replies, replies) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.patientProfile == patientProfile;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        replyId.hashCode ^
        authorId.hashCode ^
        role.hashCode ^
        title.hashCode ^
        body.hashCode ^
        parentId.hashCode ^
        replies.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        patientProfile.hashCode;
  }
}

class PatientReviews {
  final String id;
  final int reviewId;
  final String doctorId;
  final String authorId;
  final String role;
  final String title;
  final String body;
  final double rating;
  final bool recommend;
  final List<ReviewsReplies> replies;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DoctorUserProfile doctorProfile;

  PatientReviews({
    required this.id,
    required this.reviewId,
    required this.doctorId,
    required this.authorId,
    required this.role,
    required this.title,
    required this.body,
    required this.rating,
    required this.recommend,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
    required this.doctorProfile,
  });

  PatientReviews copyWith({
    String? id,
    int? reviewId,
    String? doctorId,
    String? authorId,
    String? role,
    String? title,
    String? body,
    double? rating,
    bool? recommend,
    List<ReviewsReplies>? replies,
    DateTime? createdAt,
    DateTime? updatedAt,
    DoctorUserProfile? doctorProfile,
  }) {
    return PatientReviews(
      id: id ?? this.id,
      reviewId: reviewId ?? this.reviewId,
      doctorId: doctorId ?? this.doctorId,
      authorId: authorId ?? this.authorId,
      role: role ?? this.role,
      title: title ?? this.title,
      body: body ?? this.body,
      rating: rating ?? this.rating,
      recommend: recommend ?? this.recommend,
      replies: replies ?? this.replies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doctorProfile: doctorProfile ?? this.doctorProfile,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'reviewId': reviewId});
    result.addAll({'doctorId': doctorId});
    result.addAll({'authorId': authorId});
    result.addAll({'role': role});
    result.addAll({'title': title});
    result.addAll({'body': body});
    result.addAll({'rating': rating});
    result.addAll({'recommend': recommend});
    result.addAll({'replies': replies.map((x) => x.toMap()).toList()});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'updatedAt': updatedAt.millisecondsSinceEpoch});
    result.addAll({'doctorProfile': doctorProfile.toMap()});

    return result;
  }

  factory PatientReviews.fromMap(Map<String, dynamic> map) {
    return PatientReviews(
      id: map['_id'] ?? '',
      reviewId: map['id']?.toInt() ?? 0,
      doctorId: map['doctorId'] ?? '',
      authorId: map['authorId'] ?? '',
      role: map['role'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      recommend: map['recommend'] ?? false,
      replies: List<ReviewsReplies>.from(map['replies']?.map((x) => ReviewsReplies.fromMap(x))),
      createdAt: (map['createdAt'] == null || map['createdAt'] == '') ? DateTime.now() : DateTime.parse(map['createdAt']),
      updatedAt: (map['updatedAt'] == null || map['updatedAt'] == '') ? DateTime.now() : DateTime.parse(map['updatedAt']),
      doctorProfile: DoctorUserProfile.fromMap(map['doctorProfile']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientReviews.fromJson(String source) => PatientReviews.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PatientsReviews(id: $id, reviewId: $reviewId, doctorId: $doctorId, authorId: $authorId, role: $role, title: $title, body: $body, rating: $rating, recommend: $recommend, replies: $replies, createdAt: $createdAt, updatedAt: $updatedAt, doctorProfile: $doctorProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatientReviews &&
        other.id == id &&
        other.reviewId == reviewId &&
        other.doctorId == doctorId &&
        other.authorId == authorId &&
        other.role == role &&
        other.title == title &&
        other.body == body &&
        other.rating == rating &&
        other.recommend == recommend &&
        listEquals(other.replies, replies) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.doctorProfile == doctorProfile;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        reviewId.hashCode ^
        doctorId.hashCode ^
        authorId.hashCode ^
        role.hashCode ^
        title.hashCode ^
        body.hashCode ^
        rating.hashCode ^
        recommend.hashCode ^
        replies.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        doctorProfile.hashCode;
  }
}
