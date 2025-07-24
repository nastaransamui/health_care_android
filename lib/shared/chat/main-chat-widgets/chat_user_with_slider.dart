import 'dart:convert';
import 'dart:developer';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as badges;
import 'package:flutter_slidable_panel/controllers/slide_controller.dart';
import 'package:flutter_slidable_panel/delegates/action_layout_delegate.dart';
import 'package:flutter_slidable_panel/models.dart';
import 'package:flutter_slidable_panel/widgets/slidable_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/chat/chat-share/custom_lightbox.dart';
import 'package:health_care/shared/chat/chat_helpers/get_file_icon.dart';
import 'package:health_care/shared/chat/chat-share/read_status_widget.dart';
import 'package:health_care/shared/chat/chat_helpers/save_bytes_to_file.dart';
import 'package:health_care/shared/chat/chat-share/show_delete_confirmation_dialog.dart';
import 'package:health_care/shared/chat/main-chat-widgets/slide_manager.dart';
import 'package:health_care/src/utils/encrupt_decrypt.dart';

class ChatUserWithSlider extends StatefulWidget {
  final int index;
  final ChatDataType chatRoom;
  final String currentUserId;
  final bool isTheLast;
  const ChatUserWithSlider({
    super.key,
    required this.index,
    required this.chatRoom,
    required this.currentUserId,
    required this.isTheLast,
  });

  @override
  State<ChatUserWithSlider> createState() => _ChatUserWithSliderState();
}

class _ChatUserWithSliderState extends State<ChatUserWithSlider> {
  final ChatService chatService = ChatService();
  late final SlideController slideController;

  @override
  void initState() {
    super.initState();
    slideController = SlideController(
      usePreActionController: true,
      usePostActionController: true,
    );
  }

  @override
  void dispose() {
    SlideManager.clear(slideController);
    slideController.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatDataType chatData = widget.chatRoom;
    // final int index = widget.index;
    final String currentUserId = widget.currentUserId;
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final ChatUserType profileToShow = chatData.createrData.userId == currentUserId ? chatData.receiverData : chatData.createrData;
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

    final sortedMessages = [...chatData.messages]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final MessageType? lastMessage = sortedMessages.isNotEmpty ? sortedMessages.first : null;
    final int? timestamp = lastMessage?.timestamp;
    final int numberOfNotRead = chatData.messages.where((m) => !m.read && m.receiverId == currentUserId).length;
    final bool hasMessage = chatData.messages.isNotEmpty;
   final String unreadMessagesLength =
    hasMessage ? (numberOfNotRead == 0 ? '' : numberOfNotRead.toString()) : '';
    late String displayValue = '';
    if (timestamp != null) {
      final DateTime lastMessageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final DateTime now = DateTime.now();
      final bool isToday = lastMessageTime.year == now.year && lastMessageTime.month == now.month && lastMessageTime.day == now.day;

      final bool isThisWeek = lastMessageTime.isAfter(now.subtract(const Duration(days: 7)));

      final bool isThisYear = lastMessageTime.year == now.year;

      final String dayName = DateFormat.EEEE().format(lastMessageTime);

      final String timeValue = DateFormat.Hm().format(lastMessageTime);
      final String thisWeekValue = "$dayName $timeValue";
      final String thisYearValue = "${DateFormat.MMMd().format(lastMessageTime)} $timeValue";
      final String defaultValue = "${DateFormat('d MMM yy').format(lastMessageTime)} $timeValue";

      displayValue = isToday
          ? timeValue
          : isThisWeek
              ? thisWeekValue
              : isThisYear
                  ? thisYearValue
                  : defaultValue;
    }
    final encodedRoomId = base64.encode(utf8.encode(chatData.roomId));

    return SlidablePanel(
      controller: slideController,
      onSlideStart: () => SlideManager.activate(slideController),
      maxSlideThreshold: 0.1,
      axis: Axis.horizontal,
      preActionLayout: ActionLayout.spaceEvenly(ActionMotion.drawer),
      preActions: [
        GestureDetector(
          onTap: () {
            showDeleteConfirmationDialog(context, () async {
              var payload = {"deleteType": "room", "currentUserId": currentUserId, "roomId": widget.chatRoom.roomId, "valueToSearch": "room"};
              await chatService.deleteChat(context, payload);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.canvasColor,
              border: Border(
                top: BorderSide(
                  color: theme.primaryColor,
                  width: 1,
                ),
                bottom: BorderSide(
                  color: widget.isTheLast ? theme.primaryColor : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: const Icon(Icons.delete_forever, color: Colors.red),
          ),
        )
      ],
      child: GestureDetector(
        onTap: () {
          if (profileToShow.roleName == 'doctors') {
            context.push(
              Uri(path: '/patient/dashboard/patient-chat/single/$encodedRoomId').toString(),
            );
          } else {
            context.push(
              Uri(path: '/doctors/dashboard/doctors-chat/single/$encodedRoomId').toString(),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: theme.cardTheme.color?.withOpacity(1.0),
            border: Border(
              top: BorderSide(
                color: theme.primaryColor,
                width: 1,
              ),
              bottom: BorderSide(
                color: widget.isTheLast ? theme.primaryColor : Colors.transparent,
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Stack(
                children: [
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
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${profileToShow.roleName == 'doctors' ? "Dr. " : ""}${profileToShow.fullName}",
                          ),
                        ),
                        const SizedBox(width: 1),
                        Padding(
                          padding: const EdgeInsets.only(right: 13.0),
                          child: Text(displayValue),
                        )
                      ],
                    ),
                    if (lastMessage != null) ...[
                      Row(
                        mainAxisAlignment: lastMessage.attachment.isNotEmpty ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
                        children: [
                          if (lastMessage.message == null || lastMessage.message!.trim().isEmpty)
                            const SizedBox(height: 13)
                          else ...[
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Give Text a max width from constraints
                                    ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: lastMessage.attachment.isNotEmpty ? 100 : MediaQuery.of(context).size.width / 2),
                                      child: Text(
                                        decrypt(lastMessage.message!),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 12), // adjust if needed
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    ReadStatusWidget(lastMessage: lastMessage),
                                  ],
                                );
                              },
                            )
                          ],
                          if (lastMessage.attachment.isNotEmpty) ...[
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: lastMessage.attachment.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // ✅ 2 items per row
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 4.0, // Adjust for row height
                                ),
                                itemBuilder: (context, index) {
                                  final attach = lastMessage.attachment[index];
                                  final fileType = attach.type;
                                  final fileName = attach.name;
                                  final isImage = attach.isImage;
                                  final imageBytes = attach.imageBytes;
                                  final fallbackSrc = attach.src;

                                  return InkWell(
                                    onTap: () async {
                                      if (isImage) {
                                        final imageAttachments = lastMessage.attachment.where((e) => e.isImage).toList();
                                        final imageIndex = imageAttachments.indexOf(attach);
                                        showDialog(
                                          context: context,
                                          builder: (_) => CustomLightbox(
                                            initialIndex: imageIndex,
                                            memoryImages: imageAttachments.map((e) => e.imageBytes).toList(),
                                            fallbackAssets: imageAttachments.map((e) => e.src).toList(),
                                          ),
                                        );
                                      } else {
                                        if (imageBytes != null) {
                                          await saveBytesToFile(
                                            bytes: imageBytes,
                                            fileName: fileName,
                                            context: context,
                                            onDone: (path) {
                                              showErrorSnackBar(context, context.tr('savedToDownload', args: [path]));
                                            },
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 2),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context).primaryColorLight,
                                          width: 0.5,
                                        ),
                                        color: theme.disabledColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(1),
                                            child: isImage
                                                ? imageBytes != null
                                                    ? Image.memory(
                                                        imageBytes,
                                                        width: 20,
                                                        height: 20,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.asset(
                                                        fallbackSrc,
                                                        width: 20,
                                                        height: 20,
                                                        fit: BoxFit.cover,
                                                      )
                                                : Image.asset(
                                                    getFileIcon(fileType),
                                                    width: 20,
                                                    height: 20,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          const SizedBox(width: 2),
                                          Expanded(
                                            child: Text(
                                              fileName,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (lastMessage.message == null)
                              Transform.translate(
                                offset: Offset(
                                  lastMessage.attachment.length == 1 ? -(MediaQuery.of(context).size.width / 2) / 2 : 4,
                                  0,
                                ),
                                child: ReadStatusWidget(lastMessage: lastMessage),
                              ),
                            const Spacer()
                          ],
                          if (lastMessage.calls.isNotEmpty) ...[
                            ...lastMessage.calls.map((call) {
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
                                  log('voiceCallToggleFunction()');
                                },
                                child: Container(
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
                              );
                            }),
                            const SizedBox(width: 3),
                            ReadStatusWidget(lastMessage: lastMessage),
                            const Spacer(),
                          ],
                          const SizedBox(width: 1),
                          if (unreadMessagesLength.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 13.0),
                              child: badges.Badge(
                                offset: const Offset(0, -5),
                                backgroundColor: theme.primaryColorLight,
                                label: Text(
                                  unreadMessagesLength,
                                  style: TextStyle(color: textColor),
                                ),
                                child: const SizedBox(),
                              ),
                            )
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 13)
                    ]
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
