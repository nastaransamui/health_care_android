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
  ChatDataType currentRoom,
  String currentUserId,
  MessageType messageData,
) async {
  try {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.setEndCall(false);
    final String callerId = currentUserId;
    final String receiverId = currentRoom.createrData.userId == callerId ? currentRoom.receiverData.userId : currentRoom.createrData.userId;
    final String roomId = currentRoom.roomId;
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
      peerConnection.addTrack(track, localStream!);
      await Helper.setSpeakerphoneOn(true);
    });
    // create offer
    final offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);
    final payload = {
      "offer": {'sdp': offer.sdp, 'type': offer.type},
      "callerId": currentUserId,
      "receiverId": receiverId,
      "roomId": currentRoom.roomId,
      "messageData": messageData.toMap(),
    };
    socket.emit('makeVoiceCall', payload);
  } catch (e) {
    log('makeVoiceCall error: $e');
  }
}
