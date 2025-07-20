import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/src/features/patients/patient-chat/chat-share/show_delete_confirmation_dialog.dart';
import 'package:health_care/src/features/patients/patient-chat/single-chat-widgets/receiver_bubble_widget.dart';
import 'package:health_care/src/features/patients/patient-chat/single-chat-widgets/sender_bubble_with_avatar.dart';
import 'package:health_care/src/utils/encrupt_decrypt.dart';

class ChatBubbleWidget extends StatefulWidget {
  final int index;
  final ChatDataType currentRoom;
  final String currentUserId;
  final TextEditingController chatInputController;
  final FocusNode chatInputFocusNode;
  final ValueChanged<bool> taggleEditMessage;
  final bool isEditMessage;
  final Set<int> showDeleteIndices;
  final ValueChanged<int> bubbleChatLongPress;
  final ValueChanged<int> setEditMessageTime;
  const ChatBubbleWidget({
    super.key,
    required this.index,
    required this.currentRoom,
    required this.currentUserId,
    required this.chatInputController,
    required this.chatInputFocusNode,
    required this.taggleEditMessage,
    required this.isEditMessage,
    required this.showDeleteIndices,
    required this.bubbleChatLongPress,
    required this.setEditMessageTime,
  });

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  final ChatService chatService = ChatService();

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
    final MessageType message = widget.currentRoom.messages[widget.index];
    final bool isSent = message.senderId == widget.currentUserId;

    final DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    DateTime? previousDate;
    if (widget.index > 0) {
      previousDate = DateTime.fromMillisecondsSinceEpoch(widget.currentRoom.messages[widget.index - 1].timestamp);
    }

    final bool showDate = previousDate == null ||
        !(messageDate.year == previousDate.year && messageDate.month == previousDate.month && messageDate.day == previousDate.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDate)
          Padding(
            padding: EdgeInsets.only(top: widget.index == 0 ? 10 : 0, bottom: 8),
            child: Center(
              child: Container(
                decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: const BorderRadius.all(Radius.circular(15))),
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
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: () {
                  widget.bubbleChatLongPress(widget.index);
                },
                child: Row(
                  children: [
                    ReceiverBubbleWidget(
                      currentUserId: widget.currentUserId,
                      currentRoom: widget.currentRoom,
                      message: message,
                    ),
                    if (widget.showDeleteIndices.contains(widget.index)) ...[
                      GestureDetector(
                        onTap: () {
                          showDeleteConfirmationDialog(context, () async {
                            var payload = {
                              "deleteType": "message",
                              "currentUserId": widget.currentUserId,
                              "roomId": widget.currentRoom.roomId,
                              "valueToSearch": message.timestamp
                            };
                            await chatService.deleteChat(context, payload);
                            widget.bubbleChatLongPress(widget.index);
                          });
                        },
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.pink,
                        ),
                      ),
                      if (message.calls.isEmpty && message.attachment.isEmpty)
                        GestureDetector(
                          onTap: () {
                            final msg = message.message;
                            if (msg != null && msg.isNotEmpty) {
                              widget.chatInputController.text = decrypt(msg);
                              widget.chatInputFocusNode.requestFocus();
                              widget.taggleEditMessage(true);
                              widget.setEditMessageTime(message.timestamp);
                            }
                          },
                          child: Icon(
                            Icons.edit,
                            color: theme.primaryColorLight,
                          ),
                        ),
                    ],
                  ],
                ),
              )
            : SenderBubbleWithAvatar(
                currentUserId: widget.currentUserId,
                currentRoom: widget.currentRoom,
                message: message,
              ),
      ],
    );
  }
}
