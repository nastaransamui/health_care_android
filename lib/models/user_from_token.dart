import 'dart:convert';

class UserFromToken {
  final String roleName;
  final String userId;
  final String firstName;
  final String lastName;
  final String? reason;
  final String userName;

  UserFromToken({
    required this.roleName,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.reason,
    required this.userName,
  });

  UserFromToken copyWith({
    String? roleName,
    String? userId,
    String? firstName,
    String? lastName,
    String? reason,
    String? userName,
  }) {
    return UserFromToken(
      roleName: roleName ?? this.roleName,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      reason: reason ?? this.reason,
      userName: userName ?? this.userName,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'roleName': roleName});
    result.addAll({'userId': userId});
    result.addAll({'firstName': firstName});
    result.addAll({'lastName': lastName});
    if(reason != null){
      result.addAll({'reason': reason});
    }
    result.addAll({'userName': userName});
  
    return result;
  }

  factory UserFromToken.fromMap(Map<String, dynamic> map) {
    return UserFromToken(
      roleName: map['roleName'] ?? '',
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      reason: map['reason'],
      userName: map['userName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserFromToken.fromJson(String source) => UserFromToken.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserFromToken(roleName: $roleName, userId: $userId, firstName: $firstName, lastName: $lastName, reason: $reason, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserFromToken &&
      other.roleName == roleName &&
      other.userId == userId &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.reason == reason &&
      other.userName == userName;
  }

  @override
  int get hashCode {
    return roleName.hashCode ^
      userId.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      reason.hashCode ^
      userName.hashCode;
  }
}
