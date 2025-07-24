import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/shared/chat/chat_helpers/create_peer_connection_function.dart';
import 'package:health_care/src/utils/play_sound.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

Future<void> acceptVoiceCall(BuildContext context) async {
  try {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.setEndCall(false);
    chatProvider.setIsAcceptCall(true);
    final callerId = chatProvider.incomingCall!.callerId;
    final receiverId = chatProvider.incomingCall!.receiverId;
    final roomId = chatProvider.incomingCall!.roomId;
    final offer = chatProvider.incomingCall!.offer;
    final messageData = chatProvider.incomingCall!.messageData;
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
    await peerConnection.setRemoteDescription(
      RTCSessionDescription(offer.sdp, offer.type),
    );
    var answer = await peerConnection.createAnswer();
    await peerConnection.setLocalDescription(answer);
    final updatedCalls = [...messageData.calls];
    if (updatedCalls.isNotEmpty) {
      updatedCalls[0] = updatedCalls[0].copyWith(isAnswered: true);
    }

    final updatedChatInputValue = messageData.copyWith(calls: updatedCalls);
    socket.emit('answerCall', {
      "answer": {
        "sdp": answer.sdp,
        "type": answer.type,
      },
      "callerId": callerId,
      "receiverId": receiverId,
      "roomId": roomId,
      "messageData": updatedChatInputValue.toMap(),
    });
    incomingCallSound(false);
    chatProvider.setIncomingCall(null);
  } catch (e) {
    log('acceptVoiceCall error: $e');
  }
}
