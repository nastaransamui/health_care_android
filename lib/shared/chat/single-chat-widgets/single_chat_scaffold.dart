import 'dart:developer';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' hide MessageType;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/shared/chat/chat-share/show_delete_confirmation_dialog.dart';
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
  final ChatService chatService = ChatService();
  late final ChatProvider chatProvider;
  bool _isProvidersInitialized = false;

  @override
  void initState() {
    super.initState();
    socket.on('receiveVoiceCall', (data) async {
      chatService.handleIncomingVoiceCall(
        context,
        data: data,
        currentUserId: widget.currentUserId,
      );
    });
    socket.on('endVoiceCall', (data) async {
      try {
        if (chatProvider.endCall) return;
        final MessageType messageData = MessageType.fromMap(data['messageData']);
        final ChatUserType callerData = ChatUserType.fromMap(data['callerData']);
        final ChatUserType receiverData = ChatUserType.fromMap(data['receiverData']);
        endVoiceCall(
          context,
          messageData,
          callerData,
          receiverData,
          widget.currentUserId,
          false
        );
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
    socket.on('confirmCall', (data) async {
      try {
        chatProvider.setEndCall(false);
        chatProvider.setIsAcceptCall(true);
        final answer = data['answer'];
        final sdp = answer['sdp'];
        final type = answer['type'];
        peerConnection?.setRemoteDescription(RTCSessionDescription(sdp, type));
        incomingCallSound(false);
        final receivers = await peerConnection?.getReceivers();
        final remoteTracks = receivers?.map((r) => r.track).whereType<MediaStreamTrack>().toList();
        if (remoteTracks!.isNotEmpty) {
          final newRemoteStream = await createLocalMediaStream('remote');
          for (final track in remoteTracks) {
            await newRemoteStream.addTrack(track);
          }
          remoteStream = newRemoteStream;
        }
      } catch (e) {
        log("Error socket confirmCall: $e");
      }
    });

    socket.on('receiveMessage', (data) async {
      final rawMessage = MessageType.fromMap(data);
      final roomId = rawMessage.roomId;
      final chatList = chatProvider.userChatData;
      final index = chatList.indexWhere((chat) => chat.roomId == roomId);
      if (index == -1) return;

      final chat = chatList[index];
      final exists = chat.messages.any((msg) => msg.timestamp == rawMessage.timestamp);
      if (exists) return;

      // Immediately insert raw message (without waiting for attachment downloads)
      final updatedMessages = [...chat.messages, rawMessage];
      final updatedChat = chat.copyWith(messages: updatedMessages);
      final newChatList = [...chatList];
      newChatList[index] = updatedChat;
      chatProvider.setUserChatData(newChatList); // ✅ fast UI update

      // If there are attachments, update them asynchronously
      if (rawMessage.attachment.isNotEmpty) {
        final updatedAttachments = await Future.wait(
          rawMessage.attachment.map((attach) async {
            final fileId = attach.id;
            final fileBytes = fileId.isNotEmpty ? await getChatFile(fileId, widget.currentUserId) : null;
            return attach.copyWith(imageBytes: fileBytes);
          }),
        );

        final updatedMessage = rawMessage.copyWith(attachment: updatedAttachments);

        // Replace just this one message (with updated attachment)
        final current = chatProvider.userChatData;
        final i = current.indexWhere((c) => c.roomId == roomId);
        if (i != -1) {
          final chat = current[i];
          final updatedMsgIndex = chat.messages.indexWhere((m) => m.timestamp == rawMessage.timestamp);
          if (updatedMsgIndex != -1) {
            final newMessages = [...chat.messages];
            newMessages[updatedMsgIndex] = updatedMessage;

            final newChat = chat.copyWith(messages: newMessages);
            final updatedChatList = [...current];
            updatedChatList[i] = newChat;

            chatProvider.setUserChatData(updatedChatList); // ⚡ only updates if attachment differs
          }
        }
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
    socket.off('receiveMessage');
    // Fire-and-forget async cleanup
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
    final ChatUserType profileToShow =
        widget.currentRoom.createrData.userId == widget.currentUserId ? widget.currentRoom.receiverData : widget.currentRoom.createrData;
    final String currentUserId = widget.currentUserId;
    final String roomId = widget.currentRoom.roomId;
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
    final bubbleBackground = theme.brightness == Brightness.dark ? theme.cardTheme.color : theme.disabledColor;

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
                  final ChatUserType callerData =
                      widget.currentRoom.createrData.userId == currentUserId ? widget.currentRoom.createrData : widget.currentRoom.receiverData;
                  final ChatUserType receiverData =
                      widget.currentRoom.createrData.userId == currentUserId ? widget.currentRoom.receiverData : widget.currentRoom.createrData;
                  await initiateVoiceCallIfPermitted(
                    context,
                    currentUserId,
                    callerData,
                    receiverData,
                    roomId,
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
            PopupMenuButton<String>(
              color: bubbleBackground,
              icon: const FaIcon(FontAwesomeIcons.ellipsisV, size: 18),
              offset: const Offset(0, 53),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.delete_forever, color: Colors.red),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(context.tr('deleteRoom')),
                    ],
                  ),
                ),
              ],
              elevation: 4,
              onSelected: (value) {
                if (value == 'delete') {
                  showDeleteConfirmationDialog(context, () async {
                    var payload = {
                      "deleteType": "room",
                      "currentUserId": widget.currentUserId,
                      "roomId": widget.currentRoom.roomId,
                      "valueToSearch": "room",
                    };
                    await chatService.deleteChat(context, payload);
                  });
                }
              },
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: GestureDetector(
            //     onTap: () {

            //     },
            //     child: const FaIcon(
            //       FontAwesomeIcons.ellipsisV,
            //       size: 18,
            //     ),
            //   ),
            // ),
          ],
        ),
        body: widget.children,
        bottomNavigationBar: const BottomBar(showLogin: true),
      ),
    );
  }
}
