import 'dart:developer';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/stream_socket.dart';



Future<RTCPeerConnection> createPeerConnectionFunction(
  String callerId,
  String receiverId,
  String roomId,
) async {
  RTCPeerConnection pc = await createPeerConnection(icServerConfiguration);
  pc.onIceCandidate = (candidate) async {
    socket.emit('newIceCandidate', {
      "candidate": {
        "candidate": candidate.candidate,
        "sdpMid": candidate.sdpMid,
        "sdpMLineIndex": candidate.sdpMLineIndex,
      },
      "callerId": callerId,
      "receiverId": receiverId,
      "roomId": roomId,
    });
  };
  pc.onTrack = (RTCTrackEvent event) {
    if (event.track.kind == 'audio') {
      remoteStream = event.streams.first;
      log("🔊 Remote audio stream received");
    }
  };
  return pc;
}
