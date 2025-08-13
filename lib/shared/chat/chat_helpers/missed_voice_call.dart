import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/src/utils/play_sound.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

Future<void> missedVoiceCall(
  BuildContext context,
  MessageType messageData,
) async {
  final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
  if (chatProvider.endCall) return;
  chatProvider.setEndCall(true);
  chatProvider.setIncomingCall(null, notify: true);
  try {
    incomingCallSound(false);

    if (Navigator.canPop(context)) Navigator.of(context).pop();
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
                isAnswered: false,
                isMissedCall: true
              )
            : call;
      }).toList(),
    );
    socket.emit('endVoiceCall', {'messageData': updatedMessageData.toMap()});
  } catch (e) {
    log('endVoiceCall error: $e');
  }
}
