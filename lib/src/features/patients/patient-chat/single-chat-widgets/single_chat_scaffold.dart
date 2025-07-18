import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/src/commons/bottom_bar.dart';

class SingleChatScaffold extends StatelessWidget {
  final Widget children;
  final ChatDataType currentRoom;
  final String currentUserId;
  const SingleChatScaffold({
    super.key,
    required this.currentRoom,
    required this.children,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ChatUserType profileToShow = currentRoom.createrData.userId == currentUserId ? currentRoom.receiverData : currentRoom.createrData;
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          titleSpacing: 0.0,
          title: Row(
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
          actions: [
            IconButton(
              onPressed: () {
                
              },
              icon: const Icon(Icons.local_phone, size: 25),
              tooltip: context.tr('phoneCall'),
            ),
            IconButton(
              onPressed: () {
                
              },
              icon: const Icon(Icons.videocam, size: 25),
              tooltip: context.tr('videoCall'),
            ),
            IconButton(
              onPressed: () {
                
              },
              icon: const Icon(Icons.more_vert, size: 25),
              tooltip: context.tr('more'),
            ),
          ],
        ),
        body: children,
        bottomNavigationBar: const BottomBar(showLogin: true),
      ),
    );
  }
}
