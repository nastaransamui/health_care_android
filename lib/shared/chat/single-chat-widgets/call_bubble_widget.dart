import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';

class CallBubbleWidget extends StatelessWidget {
  final MessageType message;
  const CallBubbleWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final call = message.calls.first;
    final int startTime = message.calls.first.startTimeStamp;
    final int finishTime = message.calls.first.finishTimeStamp ?? startTime;
    final bool isAnswered = call.isAnswered;

// Duration from milliseconds
    final duration = Duration(milliseconds: finishTime - startTime);

    final int totalSeconds = duration.inSeconds;
    final int totalMinutes = duration.inMinutes;
    final int totalHours = duration.inHours;

    String formattedDuration = "";

    if (!isAnswered) {
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
      icon = Icons.phone;
    } else {
      icon = Icons.call;
    }
    return GestureDetector(
      onTap: () {
        // log('voiceCallToggleFunction()');
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
