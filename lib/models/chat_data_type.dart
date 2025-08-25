import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:health_care/models/specialities.dart';
import 'package:health_care/models/users.dart';

class ChatDataType {
  String? id;
  final String roomId;
  final List<String> participants;
  final ChatUserType createrData;
  final ChatUserType receiverData;
  final List<MessageType> messages;
  final int totalUnreadMessage;

  ChatDataType(
      {this.id,
      required this.roomId,
      required this.participants,
      required this.createrData,
      required this.receiverData,
      required this.messages,
      required this.totalUnreadMessage});

  ChatDataType copyWith(
      {String? id,
      String? roomId,
      List<String>? participants,
      ChatUserType? createrData,
      ChatUserType? receiverData,
      List<MessageType>? messages,
      int? totalUnreadMessage}) {
    return ChatDataType(
        id: id ?? this.id,
        roomId: roomId ?? this.roomId,
        participants: participants ?? this.participants,
        createrData: createrData ?? this.createrData,
        receiverData: receiverData ?? this.receiverData,
        messages: messages ?? this.messages,
        totalUnreadMessage: totalUnreadMessage ?? this.totalUnreadMessage);
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'roomId': roomId});
    result.addAll({'participants': participants});
    result.addAll({'createrData': createrData.toMap()});
    result.addAll({'receiverData': receiverData.toMap()});
    result.addAll({'messages': messages.map((x) => x.toMap()).toList()});
    result.addAll({'totalUnreadMessage': totalUnreadMessage});

    return result;
  }

  factory ChatDataType.fromMap(Map<String, dynamic> map) {
    return ChatDataType(
      id: map['_id'] ?? '',
      roomId: map['roomId'] ?? '',
      participants: List<String>.from(map['participants']),
      createrData: ChatUserType.fromMap(map['createrData']),
      receiverData: ChatUserType.fromMap(map['receiverData']),
      messages: List<MessageType>.from(map['messages']?.map((x) => MessageType.fromMap(x))),
      totalUnreadMessage: map['totalUnreadMessage'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatDataType.fromJson(String source) => ChatDataType.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ChatDataType(id: $id, roomId: $roomId, participants: $participants, createrData: $createrData, receiverData: $receiverData, messages: $messages, totalUnreadMessage: $totalUnreadMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatDataType &&
        other.id == id &&
        other.roomId == roomId &&
        listEquals(other.participants, participants) &&
        other.createrData == createrData &&
        other.receiverData == receiverData &&
        listEquals(other.messages, messages) &&
        other.totalUnreadMessage == totalUnreadMessage;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomId.hashCode ^
        participants.hashCode ^
        createrData.hashCode ^
        receiverData.hashCode ^
        messages.hashCode ^
        totalUnreadMessage.hashCode;
  }
}

class ChatUserType {
  final String userId;
  final String fullName;
  final String profileImage;
  final bool online;
  final bool idle;
  final String roleName;
  final List<String> fcmTokens;
  final String gender;

  ChatUserType({
    required this.userId,
    required this.fullName,
    required this.profileImage,
    required this.online,
    required this.idle,
    required this.roleName,
    required this.fcmTokens,
    required this.gender,
  });

  ChatUserType copyWith({
    String? userId,
    String? fullName,
    String? profileImage,
    bool? online,
    bool? idle,
    String? roleName,
    List<String>? fcmTokens,
    String? gender,
  }) {
    return ChatUserType(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      online: online ?? this.online,
      idle: idle ?? this.idle,
      roleName: roleName ?? this.roleName,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'userId': userId});
    result.addAll({'fullName': fullName});
    result.addAll({'profileImage': profileImage});
    result.addAll({'online': online});
    result.addAll({'idle': idle});
    result.addAll({'roleName': roleName});
    result.addAll({'fcmTokens': fcmTokens});
    result.addAll({'gender': gender});

    return result;
  }

  factory ChatUserType.fromMap(Map<String, dynamic> map) {
    return ChatUserType(
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      profileImage: map['profileImage'] ?? '',
      online: map['online'] ?? false,
      idle: map['idle'] ?? false,
      roleName: map['roleName'] ?? '',
      fcmTokens: (map['fcmTokens'] as List?)?.whereType<String>().toList() ?? [],
      gender: map['gender'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatUserType.fromJson(String source) => ChatUserType.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ChatUserType(userId: $userId, fullName: $fullName, profileImage: $profileImage, online: $online, idle: $idle, roleName: $roleName, fcmTokens: $fcmTokens,gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatUserType &&
        other.userId == userId &&
        other.fullName == fullName &&
        other.profileImage == profileImage &&
        other.online == online &&
        other.idle == idle &&
        other.roleName == roleName &&
        other.fcmTokens == fcmTokens &&
        other.gender == gender;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        fullName.hashCode ^
        profileImage.hashCode ^
        online.hashCode ^
        idle.hashCode ^
        roleName.hashCode ^
        fcmTokens.hashCode ^
        gender.hashCode;
  }
}

class MessageType {
  final String senderId;
  final String receiverId;
  final List<String> senderFcmTokens;
  final List<String> receiverFcmTokens;
  final int timestamp;
  final String? message;
  final bool read;
  final List<AttachmentType> attachment;
  final List<CallType> calls;
  final String roomId;

  MessageType({
    required this.senderId,
    required this.receiverId,
    required this.senderFcmTokens,
    required this.receiverFcmTokens,
    required this.timestamp,
    required this.message,
    required this.read,
    required this.attachment,
    required this.calls,
    required this.roomId,
  });

  MessageType copyWith({
    String? senderId,
    String? receiverId,
    List<String>? senderFcmTokens,
    List<String>? receiverFcmTokens,
    int? timestamp,
    String? message,
    bool? read,
    List<AttachmentType>? attachment,
    List<CallType>? calls,
    String? roomId,
  }) {
    return MessageType(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderFcmTokens: senderFcmTokens ?? this.senderFcmTokens,
      receiverFcmTokens: receiverFcmTokens ?? this.receiverFcmTokens,
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
      read: read ?? this.read,
      attachment: attachment ?? this.attachment,
      calls: calls ?? this.calls,
      roomId: roomId ?? this.roomId,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'senderId': senderId});
    result.addAll({'receiverId': receiverId});
    result.addAll({'senderFcmTokens': senderFcmTokens});
    result.addAll({'receiverFcmTokens': receiverFcmTokens});
    result.addAll({'timestamp': timestamp});
    if (message != null) {
      result.addAll({'message': message});
    } else {
      result.addAll({'message': null});
    }
    result.addAll({'read': read});
    result.addAll({'attachment': attachment.map((x) => x.toMap()).toList()});
    result.addAll({'calls': calls.map((x) => x.toMap()).toList()});
    result.addAll({'roomId': roomId});

    return result;
  }

  factory MessageType.fromMap(Map<String, dynamic> map) {
    return MessageType(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderFcmTokens: (map['senderFcmTokens'] as List?)?.whereType<String>().toList() ?? [],
      receiverFcmTokens: (map['receiverFcmTokens'] as List?)?.whereType<String>().toList() ?? [],
      timestamp: map['timestamp']?.toInt() ?? 0,
      message: map['message'],
      read: map['read'] ?? false,
      attachment: List<AttachmentType>.from(map['attachment']?.map((x) => AttachmentType.fromMap(x))),
      calls: List<CallType>.from(map['calls']?.map((x) => CallType.fromMap(x))),
      roomId: map['roomId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageType.fromJson(String source) => MessageType.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MessageType(senderId: $senderId, receiverId: $receiverId,senderFcmTokens: $senderFcmTokens,  receiverFcmTokens: $receiverFcmTokens, timestamp: $timestamp, message: $message, read: $read, attachment: $attachment, calls: $calls, roomId: $roomId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageType &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.timestamp == timestamp &&
        other.message == message &&
        other.read == read &&
        listEquals(other.attachment, attachment) &&
        listEquals(other.calls, calls) &&
        other.roomId == roomId;
  }

  @override
  int get hashCode {
    return senderId.hashCode ^
        receiverId.hashCode ^
        timestamp.hashCode ^
        message.hashCode ^
        read.hashCode ^
        attachment.hashCode ^
        calls.hashCode ^
        roomId.hashCode;
  }
}

class AttachmentType {
  final String src;
  final String name;
  final bool isImage;
  final String type;
  final String id;
  Uint8List? imageBytes;

  AttachmentType({
    required this.src,
    required this.name,
    required this.isImage,
    required this.type,
    required this.id,
    this.imageBytes,
  });

  AttachmentType copyWith({
    String? src,
    String? name,
    bool? isImage,
    String? type,
    String? id,
    Uint8List? imageBytes,
  }) {
    return AttachmentType(
        src: src ?? this.src,
        name: name ?? this.name,
        isImage: isImage ?? this.isImage,
        type: type ?? this.type,
        id: id ?? this.id,
        imageBytes: imageBytes ?? this.imageBytes);
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'src': src});
    result.addAll({'name': name});
    result.addAll({'isImage': isImage});
    result.addAll({'type': type});
    result.addAll({'id': id});
    result.addAll({'imageBytes': imageBytes});

    return result;
  }

  factory AttachmentType.fromMap(Map<String, dynamic> map) {
    return AttachmentType(
      src: map['src'] ?? '',
      name: map['name'] ?? '',
      isImage: map['isImage'] ?? false,
      type: map['type'] ?? '',
      id: map['id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AttachmentType.fromJson(String source) => AttachmentType.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AttachmentType(src: $src, name: $name, isImage: $isImage, type: $type, id: $id, imageBytes: $imageBytes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttachmentType &&
        other.src == src &&
        other.name == name &&
        other.isImage == isImage &&
        other.type == type &&
        other.id == id &&
        other.imageBytes == imageBytes;
  }

  @override
  int get hashCode {
    return src.hashCode ^ name.hashCode ^ isImage.hashCode ^ type.hashCode ^ id.hashCode ^ imageBytes.hashCode;
  }
}

class CallType {
  final bool isVoiceCall;
  final bool isVideoCall;
  final int startTimeStamp;
  final int? finishTimeStamp;
  final bool isMissedCall;
  final bool isRejected;
  final bool isAnswered;

  CallType({
    required this.isVoiceCall,
    required this.isVideoCall,
    required this.startTimeStamp,
    required this.finishTimeStamp,
    required this.isMissedCall,
    required this.isRejected,
    required this.isAnswered,
  });

  CallType copyWith({
    bool? isVoiceCall,
    bool? isVideoCall,
    int? startTimeStamp,
    int? finishTimeStamp,
    bool? isMissedCall,
    bool? isRejected,
    bool? isAnswered,
  }) {
    return CallType(
      isVoiceCall: isVoiceCall ?? this.isVoiceCall,
      isVideoCall: isVideoCall ?? this.isVideoCall,
      startTimeStamp: startTimeStamp ?? this.startTimeStamp,
      finishTimeStamp: finishTimeStamp ?? this.finishTimeStamp,
      isMissedCall: isMissedCall ?? this.isMissedCall,
      isRejected: isRejected ?? this.isRejected,
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'isVoiceCall': isVoiceCall});
    result.addAll({'isVideoCall': isVideoCall});
    result.addAll({'startTimeStamp': startTimeStamp});
    if (finishTimeStamp != null) {
      result.addAll({'finishTimeStamp': finishTimeStamp});
    } else {
      result.addAll({'finishTimeStamp': null});
    }
    result.addAll({'isMissedCall': isMissedCall});
    result.addAll({'isRejected': isRejected});
    result.addAll({'isAnswered': isAnswered});

    return result;
  }

  factory CallType.fromMap(Map<String, dynamic> map) {
    return CallType(
      isVoiceCall: map['isVoiceCall'] ?? false,
      isVideoCall: map['isVideoCall'] ?? false,
      startTimeStamp: map['startTimeStamp']?.toInt() ?? 0,
      finishTimeStamp: map['finishTimeStamp']?.toInt(),
      isMissedCall: map['isMissedCall'] ?? false,
      isRejected: map['isRejected'] ?? false,
      isAnswered: map['isAnswered'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CallType.fromJson(String source) => CallType.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CallType(isVoiceCall: $isVoiceCall, isVideoCall: $isVideoCall, startTimeStamp: $startTimeStamp, finishTimeStamp: $finishTimeStamp, isMissedCall: $isMissedCall, isRejected: $isRejected, isAnswered: $isAnswered)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CallType &&
        other.isVoiceCall == isVoiceCall &&
        other.isVideoCall == isVideoCall &&
        other.startTimeStamp == startTimeStamp &&
        other.finishTimeStamp == finishTimeStamp &&
        other.isMissedCall == isMissedCall &&
        other.isRejected == isRejected &&
        other.isAnswered == isAnswered;
  }

  @override
  int get hashCode {
    return isVoiceCall.hashCode ^
        isVideoCall.hashCode ^
        startTimeStamp.hashCode ^
        finishTimeStamp.hashCode ^
        isMissedCall.hashCode ^
        isRejected.hashCode ^
        isAnswered.hashCode;
  }
}

class ChatUserAutocompleteData {
  final bool online;
  final LastLogin lastLogin;
  final DateTime createdAt;
  final String fullName;
  final String profileImage;
  final String roleName;
  final String id;
  final String searchString;
  final List<Specialities>? specialities;
  final List<String> fcmTokens;
  final String gender;

  ChatUserAutocompleteData({
    required this.online,
    required this.lastLogin,
    required this.createdAt,
    required this.fullName,
    required this.profileImage,
    required this.roleName,
    required this.id,
    required this.searchString,
    required this.specialities,
    required this.fcmTokens,
    required this.gender,
  });

  ChatUserAutocompleteData copyWith({
    bool? online,
    LastLogin? lastLogin,
    DateTime? createdAt,
    String? fullName,
    String? profileImage,
    String? roleName,
    String? id,
    String? searchString,
    List<Specialities>? specialities,
    List<String>? fcmTokens,
    String? gender,
  }) {
    return ChatUserAutocompleteData(
      online: online ?? this.online,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      roleName: roleName ?? this.roleName,
      id: id ?? this.id,
      searchString: searchString ?? this.searchString,
      specialities: specialities ?? this.specialities,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'online': online});
    result.addAll({'lastLogin': lastLogin.toMap()});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'fullName': fullName});
    result.addAll({'profileImage': profileImage});
    result.addAll({'roleName': roleName});
    result.addAll({'id': id});
    result.addAll({'searchString': searchString});
    if (specialities != null) {
      result.addAll({'specialities': specialities!.map((x) => x.toMap()).toList()});
    }
    result.addAll({'fcmTokens': fcmTokens});
    result.addAll({'gender': gender});

    return result;
  }

  factory ChatUserAutocompleteData.fromMap(Map<String, dynamic> map) {
    return ChatUserAutocompleteData(
      online: map['online'] ?? false,
      lastLogin:
          map['lastLogin'] != null ? LastLogin.fromMap(map['lastLogin']) : LastLogin(date: DateTime.now(), ipAddr: '', userAgent: '', idle: false),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      fullName: map['fullName'] ?? '',
      profileImage: map['profileImage'] ?? '',
      roleName: map['roleName'] ?? '',
      id: map['_id'] ?? '',
      searchString: map['searchString'] ?? '',
      specialities: map['specialities'] != null ? List<Specialities>.from(map['specialities']?.map((x) => Specialities.fromMap(x))) : [],
      fcmTokens: (map['fcmTokens'] as List?)?.whereType<String>().toList() ?? [],
      gender: map['gender'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatUserAutocompleteData.fromJson(String source) => ChatUserAutocompleteData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ChatUserAutocompleteData(online: $online, lastLogin: $lastLogin, createdAt: $createdAt, fullName: $fullName, profileImage: $profileImage, roleName: $roleName, id: $id, searchString: $searchString, specialities: $specialities, gender: $gender, fcmTokens: $fcmTokens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatUserAutocompleteData &&
        other.online == online &&
        other.lastLogin == lastLogin &&
        other.createdAt == createdAt &&
        other.fullName == fullName &&
        other.profileImage == profileImage &&
        other.roleName == roleName &&
        other.id == id &&
        other.searchString == searchString &&
        listEquals(other.specialities, specialities);
  }

  @override
  int get hashCode {
    return online.hashCode ^
        lastLogin.hashCode ^
        createdAt.hashCode ^
        fullName.hashCode ^
        profileImage.hashCode ^
        roleName.hashCode ^
        id.hashCode ^
        searchString.hashCode ^
        specialities.hashCode;
  }
}
