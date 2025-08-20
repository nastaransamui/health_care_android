import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' hide MessageType;
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/shared/chat/chat_helpers/create_peer_connection_function.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

Future<void> makeVoiceCall(
  BuildContext context,
  String currentUserId,
  ChatUserType callerData,
  ChatUserType receiverData,
  String roomId,
  MessageType messageData,
) async {
  try {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.setEndCall(false);
    final String callerId = currentUserId;
    String receiverId = callerData.userId == currentUserId ? receiverData.userId : callerData.userId;
    List<String> senderFcmTokens = callerData.userId == currentUserId ? callerData.fcmTokens : receiverData.fcmTokens;
    List<String> receiverFcmTokens = callerData.userId == currentUserId ? receiverData.fcmTokens : callerData.fcmTokens;
    String senderRoleName = callerData.userId == currentUserId ? callerData.roleName : receiverData.roleName;
    String senderName = callerData.userId == currentUserId ? callerData.fullName : receiverData.fullName;
    String icon = callerData.userId == currentUserId ? callerData.profileImage : receiverData.profileImage;
    String senderGender = callerData.userId == currentUserId ? callerData.gender : receiverData.gender;

    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    });
    // get the audio and asign stream to local Stream
    localStream = stream;
    // create peerConnection
    peerConnection = await createPeerConnectionFunction(callerId, receiverId, roomId);
    // add Tracks to peer connection
    localStream!.getTracks().forEach((track) async {
      track.enabled = true;
      peerConnection?.addTrack(track, localStream!);
      await Helper.setSpeakerphoneOn(true);
    });
    // create offer
    final offer = await peerConnection?.createOffer({'offerToReceiveAudio': 1, 'offerToReceiveVideo': 0});
    await peerConnection?.setLocalDescription(offer!);
    Map<String, dynamic> messageDataMap = {
      "senderId": currentUserId,
      "receiverId": receiverId,
      "senderFcmTokens": senderFcmTokens,
      "receiverFcmTokens": receiverFcmTokens,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "message": null,
      "read": false,
      "attachment": [],
      "roomId": roomId,
      "calls": messageData.calls.map((call) => call.toMap()).toList(),
      "senderRoleName": senderRoleName,
      "senderName": senderName,
      'senderGender': senderGender,
      "icon": icon,
    };
    final payload = {
      "offer": {'sdp': offer!.sdp, 'type': offer.type},
      "callerId": currentUserId,
      "receiverId": receiverId,
      "roomId": roomId,
      "messageData": messageDataMap,
      "callerData": callerData.toMap(),
      "receiverData": receiverData.toMap(),
    };
    
    socket.emit('makeVoiceCall', payload);
  } catch (e) {
    log('makeVoiceCall error: $e');
  }
}
