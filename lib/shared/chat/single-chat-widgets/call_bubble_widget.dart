import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/shared/chat/chat_helpers/initiate_voice_call_if_permitted.dart';

class CallBubbleWidget extends StatelessWidget {
  final MessageType message;
  final String currentUserId;
  final ChatDataType currentRoom;
  const CallBubbleWidget({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.currentRoom,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final call = message.calls.first;
    final int startTime = message.calls.first.startTimeStamp;
    final int finishTime = message.calls.first.finishTimeStamp ?? startTime;
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
    IconData icon;
    Color iconColor = theme.primaryColorLight;

    if (call.isMissedCall) {
      icon = Icons.phone_missed;
    } else if (call.isRejected) {
      icon = Icons.call_end;
    } else if (call.isAnswered && call.isVideoCall) {
      icon = Icons.videocam;
    } else if (call.isAnswered && call.isVoiceCall) {
      icon = message.senderId == currentUserId ? Icons.phone_forwarded : Icons.phone_callback;
    } else {
      icon = message.senderId == currentUserId ? Icons.phone_forwarded : Icons.phone_callback;
    }
    return GestureDetector(
      onTap: () async {
        final ChatUserType callerData = currentRoom.createrData.userId == currentUserId ? currentRoom.createrData : currentRoom.receiverData;
        final ChatUserType receiverData = currentRoom.createrData.userId == currentUserId ? currentRoom.receiverData : currentRoom.createrData;
        final String roomId = currentRoom.roomId;
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
