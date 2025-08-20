import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' hide MessageType;
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/shared/chat/chat_helpers/end_voice_call.dart';
import 'package:health_care/shared/chat/chat_helpers/initiate_voice_call_if_permitted.dart';
import 'package:health_care/src/utils/play_sound.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class ChatUserWithSliderVoiceCallWidget extends StatefulWidget {
  final CallType call;
  final MessageType lastMessage;
  final String currentUserId;
  final ChatDataType chatData;
  const ChatUserWithSliderVoiceCallWidget({
    super.key,
    required this.call,
    required this.lastMessage,
    required this.currentUserId,
    required this.chatData,
  });

  @override
  State<ChatUserWithSliderVoiceCallWidget> createState() => _ChatUserWithSliderVoiceCallWidgetState();
}

class _ChatUserWithSliderVoiceCallWidgetState extends State<ChatUserWithSliderVoiceCallWidget> {
  late final ChatProvider chatProvider;
  bool _isProvidersInitialized = false;
  List<RTCIceCandidate> remoteCandidates = [];
  RTCSessionDescription? _bufferedRemoteAnswer;
  bool _applyingRemoteAnswer = false;
  @override
  void initState() {
    super.initState();
    socket.on('iceCandidate', (data) async {
      try {
        final candidateMap = data['candidate'];
        final candidate = RTCIceCandidate(
          candidateMap['candidate'],
          candidateMap['sdpMid'],
          candidateMap['sdpMLineIndex'],
        );
        if (peerConnection == null) {
          remoteCandidates.add(candidate);
          return;
        }
        final remoteDesc = await peerConnection?.getRemoteDescription();
        if (remoteDesc != null) {
          // Iterate over a copy to avoid concurrent modification
          for (final buffered in List.of(remoteCandidates)) {
            await peerConnection?.addCandidate(buffered);
          }
          remoteCandidates.clear();

          // Add the newly received candidate too
          await peerConnection?.addCandidate(candidate);
        } else {
          // PeerConnection not ready yet, buffer this new candidate
          remoteCandidates.add(candidate);
        }
      } catch (e) {
        log("Error socket iceCandidate: $e");
      }
    });
    // make sure no duplicate handlers
    socket.off('confirmCall');
    // dont trust this its from shit ai
    socket.on('confirmCall', (data) async {
      try {
        chatProvider.setEndCall(false);
        chatProvider.setIsAcceptCall(true);

        final answer = data['answer'];
        final sdp = answer['sdp'] as String;
        final type = answer['type'] as String;
        final remoteDesc = RTCSessionDescription(sdp, type);

        // If already applying an answer, buffer and return (will be attempted later)
        if (_applyingRemoteAnswer) {
          log('confirmCall: already applying an answer, buffering new one');
          _bufferedRemoteAnswer = remoteDesc;
          return;
        }

        // Attempt immediate apply if ready
        final localDesc = await peerConnection?.getLocalDescription();
        final signalingState = peerConnection?.signalingState;
        final bool readyNow =
            (signalingState == RTCSignalingState.RTCSignalingStateHaveLocalOffer) || (localDesc != null && localDesc.type == 'offer');

        if (readyNow) {
          _applyingRemoteAnswer = true;
          try {
            await peerConnection?.setRemoteDescription(remoteDesc);
            incomingCallSound(false);

            // attach remote tracks if any (your existing logic)
            final receivers = await peerConnection?.getReceivers();
            final remoteTracks = receivers?.map((r) => r.track).whereType<MediaStreamTrack>().toList();
            if (remoteTracks != null && remoteTracks.isNotEmpty) {
              final newRemoteStream = await createLocalMediaStream('remote');
              for (final track in remoteTracks) {
                await newRemoteStream.addTrack(track);
              }
              remoteStream = newRemoteStream;
            }

            // flush buffered ICE
            if (remoteCandidates.isNotEmpty) {
              for (final c in List.of(remoteCandidates)) {
                try {
                  await peerConnection?.addCandidate(c);
                } catch (e) {
                  log('Failed to add buffered ICE candidate: $e');
                }
              }
              remoteCandidates.clear();
            }

            _bufferedRemoteAnswer = null;
            return;
          } catch (e) {
            log('confirmCall: immediate setRemoteDescription failed: $e');
            // fallthrough to buffer+retry
          } finally {
            _applyingRemoteAnswer = false;
          }
        }

        // Not ready: buffer and retry with stronger diagnostics
        _bufferedRemoteAnswer = remoteDesc;
        log('confirmCall: buffered answer because pc not ready: signaling=${peerConnection?.signalingState} localDesc=${(await peerConnection?.getLocalDescription())?.type}');

        // Retry loop: try longer (8 attempts * 250ms = 2s)
        const int attempts = 8;
        const int delayMs = 250;
        for (int i = 0; i < attempts; i++) {
          await Future.delayed(const Duration(milliseconds: delayMs));

          if (peerConnection == null) {
            log('Retry ${i + 1}: peerConnection is null; continue');
            continue;
          }

          final curSignaling = peerConnection!.signalingState;
          final curLocalDesc = await peerConnection!.getLocalDescription();
          log('Retry ${i + 1}: signaling=$curSignaling localDesc=${curLocalDesc?.type}');

          final bool nowReady =
              (curSignaling == RTCSignalingState.RTCSignalingStateHaveLocalOffer) || (curLocalDesc != null && curLocalDesc.type == 'offer');

          if (!nowReady) continue;

          // now try applying
          _applyingRemoteAnswer = true;
          try {
            await peerConnection!.setRemoteDescription(_bufferedRemoteAnswer!);
            log('Retry ${i + 1}: setRemoteDescription succeeded');

            incomingCallSound(false);

            final receivers = await peerConnection!.getReceivers();
            final remoteTracks = receivers.map((r) => r.track).whereType<MediaStreamTrack>().toList();
            if (remoteTracks.isNotEmpty) {
              final newRemoteStream = await createLocalMediaStream('remote');
              for (final track in remoteTracks) {
                await newRemoteStream.addTrack(track);
              }
              remoteStream = newRemoteStream;
            }

            if (remoteCandidates.isNotEmpty) {
              for (final c in List.of(remoteCandidates)) {
                try {
                  await peerConnection?.addCandidate(c);
                } catch (e) {
                  log('Failed to add buffered ICE candidate after applying answer: $e');
                }
              }
              remoteCandidates.clear();
            }

            _bufferedRemoteAnswer = null;
            break; // success
          } catch (e) {
            log('Retry ${i + 1}: setRemoteDescription failed: $e');
          } finally {
            _applyingRemoteAnswer = false;
          }
        }

        if (_bufferedRemoteAnswer != null) {
          log('confirmCall: failed to apply buffered answer after retries. signaling=${peerConnection?.signalingState} localDesc=${(await peerConnection?.getLocalDescription())?.type}');
          // OPTIONAL: you can decide to notify server to resend or force a renegotiation.
        }
      } catch (e) {
        log("Error socket confirmCall: $e");
      }
    });
    socket.on('endVoiceCall', (data) async {
      try {
        if (chatProvider.endCall) return;
        final MessageType messageData = MessageType.fromMap(data['messageData']);
        final ChatUserType callerData = ChatUserType.fromMap(data['callerData']);
        final ChatUserType receiverData = ChatUserType.fromMap(data['receiverData']);
        endVoiceCall(context, messageData, callerData, receiverData, widget.currentUserId, false);
      } catch (e) {
        log("Error socket endVoiceCall: $e");
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('iceCandidate');
    socket.off('confirmCall');
    socket.off('endVoiceCall');
    cleanupPeerConnection();
    super.dispose();
  }

  void cleanupPeerConnection() async {
    try {
      await peerConnection?.close();
      await peerConnection?.dispose();
      peerConnection = null;
      await localStream?.dispose();
      localStream = null;
    } catch (e) {
      log('Error disposing peerConnection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CallType call = widget.call;
    final MessageType lastMessage = widget.lastMessage;
    final String currentUserId = widget.currentUserId;
    final ChatDataType chatData = widget.chatData;
    final String roomId = chatData.roomId;

    IconData icon;
    Color iconColor = theme.primaryColorLight;
    final int startTime = call.startTimeStamp;
    final int finishTime = call.finishTimeStamp ?? startTime;
    final bool isAnswered = call.isAnswered;
    final bool isMissedCall = call.isMissedCall;

    // Duration from milliseconds
    final duration = Duration(milliseconds: finishTime - startTime);

    final int totalSeconds = duration.inSeconds;
    final int totalMinutes = duration.inMinutes;
    final int totalHours = duration.inHours;
    String formattedDuration = "";
    if (isMissedCall) {
      formattedDuration = context.tr('missedCall');
    } else if (!isAnswered) {
      formattedDuration = context.tr('noAnswer');
    } else if (totalSeconds < 60) {
      formattedDuration = "$totalSeconds sec";
    } else if (totalSeconds < 3600) {
      final int remainingSeconds = totalSeconds % 60;
      formattedDuration = "$totalMinutes min $remainingSeconds sec";
    } else {
      final int remainingMinutes = totalMinutes % 60;
      formattedDuration = "$totalHours hr $remainingMinutes min";
    }
    if (isMissedCall) {
      icon = Icons.phone_missed;
    } else if (call.isRejected) {
      icon = Icons.call_end;
    } else if (call.isAnswered && call.isVideoCall) {
      icon = Icons.videocam;
    } else if (call.isAnswered && call.isVoiceCall) {
      icon = lastMessage.senderId == currentUserId ? Icons.phone_forwarded : Icons.phone_callback;
    } else {
      icon = lastMessage.senderId == currentUserId ? Icons.phone_forwarded : Icons.phone_callback;
    }
    return GestureDetector(
      onTap: () async {
        final ChatUserType callerData = chatData.createrData.userId == currentUserId ? chatData.createrData : chatData.receiverData;
        final ChatUserType receiverData = chatData.createrData.userId == currentUserId ? chatData.receiverData : chatData.createrData;
        socket.emit("joinRoom", roomId);
        await initiateVoiceCallIfPermitted(
          context,
          currentUserId,
          callerData,
          receiverData,
          roomId,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              color: theme.canvasColor,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 14,
            ),
          ),
          Text(
            formattedDuration,
            style: TextStyle(
              color: theme.disabledColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
