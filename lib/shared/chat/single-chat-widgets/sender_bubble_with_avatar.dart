import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/shared/chat/chat-share/read_status_widget.dart';
import 'package:health_care/shared/chat/single-chat-widgets/call_bubble_widget.dart';
import 'package:health_care/shared/chat/single-chat-widgets/chat_attachment_widget.dart';
import 'package:health_care/src/utils/encrupt_decrypt.dart';

class SenderBubbleWithAvatar extends StatefulWidget {
  final String currentUserId;
  final ChatDataType currentRoom;
  final MessageType message;
  final bool showTail;

  const SenderBubbleWithAvatar({
    super.key,
    required this.currentUserId,
    required this.currentRoom,
    required this.message, required this.showTail,
  });

  @override
  State<SenderBubbleWithAvatar> createState() => _SenderBubbleWithAvatarState();
}

class _SenderBubbleWithAvatarState extends State<SenderBubbleWithAvatar> {
  late String messageText = "";

  @override
  Widget build(BuildContext context) {
    final currentRoom = widget.currentRoom;
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
    final ChatUserType profileToShow = currentRoom.createrData.userId == currentUserId ? currentRoom.receiverData : currentRoom.createrData;
    final bubbleBackground = theme.brightness == Brightness.dark ? theme.cardTheme.color : theme.disabledColor;
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Transform.translate(
            offset: const Offset(6, -5),
            child: ChatBubble(
              clipper: widget.showTail? ChatBubbleClipper3(
                type: BubbleType.sendBubble,
              ) :ChatBubbleClipper5(
                type: BubbleType.sendBubble,
              ) ,
              alignment: Alignment.topRight,
              backGroundColor: bubbleBackground,
              shadowColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('$message'),
                    if (message.calls.isNotEmpty)
                      CallBubbleWidget(message: message)
                    else if (message.attachment.isEmpty)
                      // Only Text message
                      Text(
                        messageText,
                        style: TextStyle(color: textColor),
                      )
                    else
                      ChatAttachmentWidget(key: ValueKey(message.senderId), message: message, userId: currentUserId),
            
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
          ),
          Stack(
            children: widget.showTail ? [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: theme.primaryColorLight),
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  image: DecorationImage(fit: BoxFit.contain, image: finalImage),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: AvatarGlow(
                  glowColor: statusColor,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor, width: 0.5),
                    ),
                  ),
                ),
              ),
            ] : [
              const SizedBox(
                width: 50,
                height: 40,
                
              ),
            ],
          ),
        ],
      ),
    );
  }
}
