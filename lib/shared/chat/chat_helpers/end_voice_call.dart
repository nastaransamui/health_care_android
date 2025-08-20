import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/src/utils/play_sound.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

Future<void> endVoiceCall(
  BuildContext context,
  MessageType messageData,
  ChatUserType callerData,
  ChatUserType receiverData,
  String currentUserId,
  bool closeAlready,
) async {
  final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
  if (chatProvider.endCall) return;
  chatProvider.setEndCall(true);
  chatProvider.setIncomingCall(null, notify: true);
  try {
    incomingCallSound(false);
    if (Navigator.canPop(context) && !closeAlready) Navigator.of(context).pop();
    // Stop all local tracks
    localStream?.getTracks().forEach((track) async {
      await track.stop();
    });

    // Stop all remote tracks
    remoteStream?.getTracks().forEach((track) async {
      await track.stop();
    });

    // Close and dispose the peer connection
    await peerConnection?.close();
    await peerConnection?.dispose();
    peerConnection = null;
    // Nullify references
    localStream = null;
    remoteStream = null;
    final updatedMessageData = messageData.copyWith(
      calls: messageData.calls.asMap().entries.map((entry) {
        final index = entry.key;
        final call = entry.value;

        return index == 0
            ? call.copyWith(
                finishTimeStamp: DateTime.now().millisecondsSinceEpoch,
                isAnswered: true,
              )
            : call;
      }).toList(),
    );
   String senderRoleName = callerData.userId == currentUserId ? callerData.roleName : receiverData.roleName;
    String senderName = callerData.userId == currentUserId ? callerData.fullName : receiverData.fullName;
    String icon = callerData.userId == currentUserId ? callerData.profileImage : receiverData.profileImage;
    String senderGender = callerData.userId == currentUserId ? callerData.gender : receiverData.gender;

     Map<String, dynamic> messageDataMap = {
      "senderId": updatedMessageData.senderId,
      "receiverId": updatedMessageData.receiverId,
      "senderFcmTokens": updatedMessageData.senderFcmTokens,
      "receiverFcmTokens": updatedMessageData.receiverFcmTokens,
      "timestamp": updatedMessageData.timestamp,
      "message": updatedMessageData.message,
      "read": updatedMessageData.read,
      "attachment": updatedMessageData.attachment,
      "roomId": updatedMessageData.roomId,
      "calls": updatedMessageData.calls.map((call) => call.toMap()).toList(),
      "senderRoleName": senderRoleName,
      "senderName": senderName,
      'senderGender': senderGender,
      "icon": icon,
    };
     final payload = {
      "messageData": messageDataMap,
      "callerData":  callerData.toMap(),
      "receiverData": receiverData.toMap(),
     };
    socket.emit('endVoiceCall', payload);
  } catch (e) {
    log('endVoiceCall error: $e');
  }
}
