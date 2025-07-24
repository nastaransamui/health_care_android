import 'package:flutter_webrtc/flutter_webrtc.dart' hide MessageType;
import 'package:health_care/models/chat_data_type.dart';

class IncomingCall {
  final RTCSessionDescription offer;
  final String receiverId;
  final String callerId;
  final String roomId;
  final MessageType messageData;

  IncomingCall({
    required this.offer,
    required this.receiverId,
    required this.callerId,
    required this.roomId,
    required this.messageData,
  });
}
