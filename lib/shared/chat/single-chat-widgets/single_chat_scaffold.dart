import 'dart:developer';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' hide MessageType;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/shared/chat/single-chat-widgets/chat_input.dart';
import 'package:health_care/shared/chat/single-chat-widgets/voice_call_widget.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/utils/play_sound.dart';
import 'package:health_care/stream_socket.dart';
import 'package:permission_handler/permission_handler.dart';

bool endCall = false;
bool isAccept = false;

class SingleChatScaffold extends StatefulWidget {
  final Widget children;
  final ChatDataType currentRoom;
  final String currentUserId;
  const SingleChatScaffold({
    super.key,
    required this.children,
    required this.currentRoom,
    required this.currentUserId,
  });

  @override
  State<SingleChatScaffold> createState() => _SingleChatScaffoldState();
}

class _SingleChatScaffoldState extends State<SingleChatScaffold> {
  IncomingCall? incomingCall;
  List<RTCIceCandidate> remoteCandidates = [];

  void setIncomingCall(IncomingCall? call) {
    setState(() {
      incomingCall = call;
    });
  }

  @override
  void initState() {
    super.initState();
    socket.on('receiveVoiceCall', (data) async {
      endCall = false;
      isAccept = false;
      try {
        final RTCSessionDescription offer = RTCSessionDescription(data['offer']['sdp'], data['offer']['type']);
        final String receiverId = data['receiverId'];
        final String callerId = data['callerId'];
        final String roomId = data['roomId'];
        var messageDataMap = data['messageData'];
        final MessageType messageData = MessageType.fromMap(messageDataMap);
        setIncomingCall(
          IncomingCall(
            offer: offer,
            receiverId: receiverId,
            callerId: callerId,
            roomId: roomId,
            messageData: messageData,
          ),
        );
        await initiateVoiceCallIfPermitted(
          context,
          widget.currentRoom,
          widget.currentUserId,
          incomingCall,
          setIncomingCall,
        );
      } catch (e) {
        log("Error socket receiveVoiceCall: $e");
      }
    });
    socket.on('endVoiceCall', (data) async {
      try {
        if (endCall) return;

        final MessageType messageData = MessageType.fromMap(data['messageData']);
        endVoiceCall(context, messageData);
      } catch (e) {
        log("Error socket endVoiceCall: $e");
      }
    });
    socket.on('iceCandidate', (data) async {
      try {
        final candidateMap = data['candidate'];
        final candidate = RTCIceCandidate(
          candidateMap['candidate'],
          candidateMap['sdpMid'],
          candidateMap['sdpMLineIndex'],
        );
        final remoteDesc = await peerConnection.getRemoteDescription();
        if (remoteDesc != null) {
          // Iterate over a copy to avoid concurrent modification
          for (final buffered in List.of(remoteCandidates)) {
            await peerConnection.addCandidate(buffered);
          }
          remoteCandidates.clear();

          // Add the newly received candidate too
          await peerConnection.addCandidate(candidate);
        } else {
          // PeerConnection not ready yet, buffer this new candidate
          remoteCandidates.add(candidate);
        }
      } catch (e) {
        log("Error socket iceCandidate: $e");
      }
    });
    socket.on('confirmCall', (data) async {
      try {
        endCall = false;
        isAccept = true;
        // final callerId = data['callerId'];
        // final receiverId = data['receiverId'];
        // final roomId = data['roomId'];
        final answer = data['answer'];
        final sdp = answer['sdp'];
        final type = answer['type'];
        peerConnection.setRemoteDescription(RTCSessionDescription(sdp, type));
        incomingCallSound(false);
        final receivers = await peerConnection.getReceivers();
        final remoteTracks = receivers.map((r) => r.track).whereType<MediaStreamTrack>().toList();

        if (remoteTracks.isNotEmpty) {
          final newRemoteStream = await createLocalMediaStream('remote');
          for (final track in remoteTracks) {
            await newRemoteStream.addTrack(track);
          }
          remoteStream = newRemoteStream;
          log("🔊 Remote stream rebuilt from confirmCall");
        }
      } catch (e) {
        log("Error socket confirmCall: $e");
      }
    });
  }

  @override
  void dispose() {
    socket.off('receiveVoiceCall');
    socket.off('iceCandidate');
    socket.off('endVoiceCall');
    socket.off('confirmCall');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ChatUserType profileToShow =
        widget.currentRoom.createrData.userId == widget.currentUserId ? widget.currentRoom.receiverData : widget.currentRoom.createrData;
    final ImageProvider<Object> finalImage = profileToShow.roleName == 'doctors'
        ? profileToShow.profileImage.isEmpty
            ? const AssetImage('assets/images/default-avatar.png') as ImageProvider
            : CachedNetworkImageProvider(profileToShow.profileImage)
        : profileToShow.profileImage.isEmpty
            ? const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider
            : CachedNetworkImageProvider(profileToShow.profileImage);
    final Color statusColor = profileToShow.idle
        ? const Color(0xFFFFA812)
        : profileToShow.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          titleSpacing: 0.0,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: theme.primaryColorLight),
                        shape: BoxShape.rectangle,
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        image: DecorationImage(fit: BoxFit.contain, image: finalImage),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: AvatarGlow(
                        glowColor: statusColor,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: statusColor, width: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Text(
                  "${profileToShow.roleName == 'doctors' ? "Dr. " : ""}${profileToShow.fullName}",
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () async {
                  await initiateVoiceCallIfPermitted(
                    context,
                    widget.currentRoom,
                    widget.currentUserId,
                    incomingCall,
                    setIncomingCall,
                  );
                },
                child: Transform.rotate(
                  angle: 360,
                  child: const FaIcon(
                    FontAwesomeIcons.phone,
                    size: 18,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const FaIcon(
                FontAwesomeIcons.video,
                size: 18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {},
                child: const FaIcon(
                  FontAwesomeIcons.ellipsisV,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        body: widget.children,
        bottomNavigationBar: const BottomBar(showLogin: true),
      ),
    );
  }
}

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

late RTCPeerConnection peerConnection;
late MediaStream? localStream;
MediaStream? remoteStream;

Map<String, dynamic> configuration = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'}
  ]
};

Future<RTCPeerConnection> createPeerConnectionFunction(
  String callerId,
  String receiverId,
  String roomId,
) async {
  RTCPeerConnection pc = await createPeerConnection(configuration);
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

Future<bool> checkMicrophonePermission() async {
  final status = await Permission.microphone.request();
  return status.isGranted;
}

Future<void> initiateVoiceCallIfPermitted(
  BuildContext context,
  ChatDataType currentRoom,
  String currentUserId,
  IncomingCall? incomingCall,
  void Function(IncomingCall?) setIncomingCall,
) async {
  try {
    // if no have mic permission return
    final hasMicPermission = await checkMicrophonePermission();

    if (!hasMicPermission) {
      if (context.mounted) {
        showCustomToast(context, context.tr('weNeedMicrophonePermissionToMakeThisCall'));
      }
      return;
    }
    late String receiverId;
    late MessageType messageData;
    // this block happen if need to make call
    if (incomingCall == null) {
      receiverId = currentRoom.createrData.userId == currentUserId ? currentRoom.receiverData.userId : currentRoom.createrData.userId;
      messageData = MessageType(
        senderId: currentUserId,
        receiverId: receiverId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        message: null,
        read: false,
        attachment: [],
        calls: [
          CallType(
            isVoiceCall: true,
            isVideoCall: false,
            startTimeStamp: DateTime.now().millisecondsSinceEpoch,
            finishTimeStamp: null,
            isMissedCall: false,
            isRejected: false,
            isAnswered: false,
          )
        ],
        roomId: currentRoom.roomId,
      );
      await makeVoiceCall(currentRoom, currentUserId, messageData);
    }
    // this block happen if reciveCall
    else {
      receiverId = incomingCall.receiverId;
      messageData = incomingCall.messageData;
    }
    if (context.mounted) {
      incomingCallSound(true);

      showModalBottomSheet(
        useSafeArea: true,
        showDragHandle: false,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        context: context,
        builder: (context) {
          return VoiceCallWidget(
            currentRoom: currentRoom,
            currentUserId: currentUserId,
            messageData: messageData,
            incomingCall: incomingCall,
            isAccept: isAccept,
            setIncomingCall: setIncomingCall,
          );
        },
      );
    }
  } catch (e) {
    log('initiateVoiceCallIfPermitted error: $e');
  }
}

Future<void> makeVoiceCall(
  ChatDataType currentRoom,
  String currentUserId,
  MessageType messageData,
) async {
  try {
    endCall = false;
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

Future<void> acceptVoiceCall(IncomingCall incomingCall, void Function(IncomingCall?) setIncomingCall) async {
  try {
    endCall = false;
    isAccept = true;
    final callerId = incomingCall.callerId;
    final receiverId = incomingCall.receiverId;
    final roomId = incomingCall.roomId;
    final offer = incomingCall.offer;
    final messageData = incomingCall.messageData;
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
    setIncomingCall(null);
  } catch (e) {
    log('acceptVoiceCall error: $e');
  }
}

Future<void> endVoiceCall(
  BuildContext context,
  MessageType messageData,
) async {
  if (endCall) return;
  endCall = true;
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
    await peerConnection.close();
    await peerConnection.dispose();

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
    socket.emit('endVoiceCall', {'messageData': updatedMessageData.toMap()});
  } catch (e) {
    log('endVoiceCall error: $e');
  }
}
