
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StatusBadgeAvatar extends StatefulWidget {
  final String imageUrl;
  final bool online;
  final bool idle;
  final VoidCallback onTap;
  final String userType;

  const StatusBadgeAvatar({
    super.key,
    required this.imageUrl,
    required this.online,
    required this.idle,
    required this.onTap,
    required this.userType,
  });

  @override
  State<StatusBadgeAvatar> createState() => _StatusBadgeAvatarState();
}

class _StatusBadgeAvatarState extends State<StatusBadgeAvatar> with SingleTickerProviderStateMixin {

  Color get statusColor {
    if (widget.idle) return const Color(0xFFFFA812); // amber
    if (widget.online) return const Color(0xFF44B700); // green
    return Colors.pinkAccent; // offline
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    widget.userType == 'doctors' ? Image.asset('assets/images/doctors_profile.jpg') : Image.asset('assets/images/default-avatar.png'),
              ),
            ),
          ),

          // Badge with ripple
          Positioned(
            right: -1,
            bottom: -1,
            child: SizedBox(
              width: 14,
              height: 14,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Actual dot
                  AvatarGlow(
                    glowColor: statusColor,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
