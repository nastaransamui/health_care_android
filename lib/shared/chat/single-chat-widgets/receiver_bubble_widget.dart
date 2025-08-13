import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/shared/chat/chat-share/read_status_widget.dart';
import 'package:health_care/shared/chat/single-chat-widgets/call_bubble_widget.dart';
import 'package:health_care/shared/chat/single-chat-widgets/chat_attachment_widget.dart';
import 'package:health_care/src/utils/encrupt_decrypt.dart';

class ReceiverBubbleWidget extends StatefulWidget {
  final String currentUserId;
  final ChatDataType currentRoom;
  final MessageType message;
  final bool showTail;
  const ReceiverBubbleWidget({
    super.key,
    required this.currentUserId,
    required this.currentRoom,
    required this.message,
    required this.showTail,
  });

  @override
  State<ReceiverBubbleWidget> createState() => _ReceiverBubbleWidgetState();
}

class _ReceiverBubbleWidgetState extends State<ReceiverBubbleWidget> {
  late String messageText = "";
  @override
  Widget build(BuildContext context) {
    final currentUserId = widget.currentUserId;
    final message = widget.message;
    final msg = message.message;
    if (msg != null && msg.isNotEmpty) {
      messageText = decrypt(msg);
    }
    final int timestamp = message.timestamp;
    late String displayValue = '';
    final DateTime lastMessageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final String timeValue = DateFormat.Hm().format(lastMessageTime);

    displayValue = timeValue;
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final bubbleBackground = theme.brightness == Brightness.dark ? theme.cardTheme.color : theme.disabledColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: ChatBubble(
        clipper: widget.showTail
            ? ChatBubbleClipper5(
                type: BubbleType.receiverBubble,
              )
            : ChatBubbleClipper5(
                type: BubbleType.receiverBubble,
              ),
        alignment: Alignment.topLeft,
        backGroundColor: bubbleBackground,
        shadowColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.calls.isNotEmpty)
                CallBubbleWidget(
                  message: message,
                  currentUserId: currentUserId,
                  currentRoom: widget.currentRoom,
                )
              else if (message.attachment.isEmpty)
                // Only Text message
                Text(
                  messageText,
                  style: TextStyle(color: textColor),
                )
              else
                ChatAttachmentWidget(
                  key: ValueKey(message.receiverId),
                  message: message,
                  userId: currentUserId,
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReadStatusWidget(lastMessage: message),
                  Text(
                    displayValue,
                    style: TextStyle(
                      color: theme.disabledColor,
                      fontSize: 12,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
