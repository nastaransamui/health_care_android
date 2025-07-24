import 'dart:developer';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' hide MessageType;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/models/incoming_call.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/shared/chat/chat_helpers/end_voice_call.dart';
import 'package:health_care/shared/chat/chat_helpers/initiate_voice_call_if_permitted.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/utils/play_sound.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

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
  List<RTCIceCandidate> remoteCandidates = [];
  late final ChatProvider chatProvider;
  bool _isProvidersInitialized = false;

  @override
  void initState() {
    super.initState();
    socket.on('receiveVoiceCall', (data) async {
      chatProvider.setEndCall(false);
      chatProvider.setIsAcceptCall(false);
      try {
        final RTCSessionDescription offer = RTCSessionDescription(data['offer']['sdp'], data['offer']['type']);
        final String receiverId = data['receiverId'];
        final String callerId = data['callerId'];
        final String roomId = data['roomId'];
        var messageDataMap = data['messageData'];
        final MessageType messageData = MessageType.fromMap(messageDataMap);
        chatProvider.setIncomingCall(
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
        );
      } catch (e) {
        log("Error socket receiveVoiceCall: $e");
      }
    });
    socket.on('endVoiceCall', (data) async {
      try {
        if (chatProvider.endCall) return;

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
        log('peerConnection: $peerConnection in iceCandidate');
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
        chatProvider.setEndCall(false);
        chatProvider.setIsAcceptCall(true);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
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
                  );
                },
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: Transform.rotate(
                      angle: 360,
                      child: const FaIcon(
                        FontAwesomeIcons.phone,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.video,
                    size: 18,
                  ),
                ),
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
