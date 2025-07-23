import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart' hide MessageType;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/shared/chat/single-chat-widgets/single_chat_scaffold.dart';

class VoiceCallWidget extends StatelessWidget {
  const VoiceCallWidget({
    super.key,
    required this.currentRoom,
    required this.currentUserId,
    required this.messageData,
    this.incomingCall,
    required this.isAccept,
    required this.setIncomingCall,
  });
  final ChatDataType currentRoom;
  final String currentUserId;
  final MessageType messageData;
  final IncomingCall? incomingCall;
  final bool isAccept;
  final void Function(IncomingCall?) setIncomingCall;

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
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primaryColor, theme.primaryColorLight],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(
            //   width: 20,
            //   height: 20,
            //   child: RTCVideoView(remoteRenderer),
            // ),
            Stack(
              alignment: Alignment.center,
              children: [
                AvatarGlow(
                  glowRadiusFactor: 0.12,
                  glowColor: theme.cardColor,
                  child: Container(
                    width: 200, // Actual avatar image size
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: theme.cardColor, width: 10),
                      borderRadius: BorderRadius.circular(200),
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: finalImage,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 25,
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: AvatarGlow(
                      glowColor: statusColor,
                      duration: const Duration(milliseconds: 1500),
                      repeat: true,
                      glowCount: 2,
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
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '${profileToShow.roleName == 'doctors' ? "Dr. " : ''}${profileToShow.fullName}',
              style: const TextStyle(color: Colors.black, fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              !isAccept ? context.tr('voiceCallConnecting') : context.tr('voiceCallConnected...........'),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: incomingCall == null
                        ? null
                        : () {
                            if (incomingCall != null) {
                              // log('incomingC?: $incomingCall');
                              acceptVoiceCall(incomingCall!, setIncomingCall);
                            }
                          },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration:
                          BoxDecoration(color: incomingCall == null ? theme.disabledColor : Colors.green, borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child: Transform.rotate(
                          angle: 360,
                          child: const FaIcon(
                            FontAwesomeIcons.phone,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      endVoiceCall(context, messageData);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child: Transform.rotate(
                          angle: -8.6,
                          child: const FaIcon(
                            FontAwesomeIcons.phone,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
