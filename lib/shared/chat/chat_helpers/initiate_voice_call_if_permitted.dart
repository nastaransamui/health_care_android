import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/shared/chat/chat_helpers/check_microphone_permission.dart';
import 'package:health_care/shared/chat/chat_helpers/make_voice_call.dart';
import 'package:health_care/shared/chat/single-chat-widgets/chat_input.dart';
import 'package:health_care/shared/chat/single-chat-widgets/voice_call_widget.dart';
import 'package:health_care/src/utils/play_sound.dart';
import 'package:provider/provider.dart';

Future<void> initiateVoiceCallIfPermitted(
  BuildContext context,
  ChatDataType currentRoom,
  String currentUserId,
) async {
  try {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.setEndCall(false, notify: false);
    chatProvider.setIsAcceptCall(false, notify: false);
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
    if (chatProvider.incomingCall == null) {
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
      if (context.mounted) await makeVoiceCall(context, currentRoom, currentUserId, messageData);
    }
    // this block happen if reciveCall
    else {
      receiverId = chatProvider.incomingCall!.receiverId;
      messageData = chatProvider.incomingCall!.messageData;
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
          );
        },
      );
    }
  } catch (e) {
    log('initiateVoiceCallIfPermitted error: $e');
  }
}
