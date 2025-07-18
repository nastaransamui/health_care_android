import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/src/features/patients/patient-chat/single-chat-widgets/receiver_bubble_widget.dart';
import 'package:health_care/src/features/patients/patient-chat/single-chat-widgets/sender_bubble_with_avatar.dart';

class ChatBubbleWidget extends StatelessWidget {
  final int index;
  final ChatDataType currentRoom;
  final String currentUserId;
  const ChatBubbleWidget({
    super.key,
    required this.index,
    required this.currentRoom,
    required this.currentUserId,
  });

  String _formatDateFromEpoch(int epochMillis) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(epochMillis);
    final DateTime now = DateTime.now();

    final bool isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    final bool isThisWeek = date.isAfter(now.subtract(const Duration(days: 7)));
    final bool isThisYear = date.year == now.year;

    if (isToday) {
      return 'Today';
    } else if (isThisWeek) {
      return DateFormat.EEEE().format(date); // Monday, etc.
    } else if (isThisYear) {
      return DateFormat.MMMd().format(date); // Jan 4
    } else {
      return DateFormat('d MMM yy').format(date); // 4 Jan 24
    }
  }

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);
    final MessageType message = currentRoom.messages[index];
    final bool isSent = message.senderId == currentUserId;
    final DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    DateTime? previousDate;
    if (index > 0) {
      previousDate = DateTime.fromMillisecondsSinceEpoch(currentRoom.messages[index - 1].timestamp);
    }

    final bool showDate = previousDate == null ||
        !(messageDate.year == previousDate.year && messageDate.month == previousDate.month && messageDate.day == previousDate.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDate)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 10 : 0, bottom: 8),
            child: Center(
              child: Container(
                decoration:  BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: const BorderRadius.all(Radius.circular(15))
                ),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                child: Text(
                  _formatDateFromEpoch(message.timestamp),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: theme.disabledColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
        isSent
            ? ReceiverBubbleWidget(
                currentUserId: currentUserId,
                currentRoom: currentRoom,
                message: message,
              )
            : SenderBubbleWithAvatar(
                currentUserId: currentUserId,
                currentRoom: currentRoom,
                message: message,
              ),
      ],
    );
  }
}
