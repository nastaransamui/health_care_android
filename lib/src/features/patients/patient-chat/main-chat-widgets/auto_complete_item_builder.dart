import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';

class AutoCompleteItemBuilder extends StatelessWidget {
  const AutoCompleteItemBuilder({
    super.key,
    required this.roleName,
    required this.suggestion,
  });

  final String roleName;
  final ChatUserAutocompleteData suggestion;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ImageProvider<Object> finalImage = roleName == 'doctors'
        ? suggestion.profileImage.isEmpty
            ? const AssetImage('assets/images/default-avatar.png') as ImageProvider
            : CachedNetworkImageProvider(suggestion.profileImage)
        : suggestion.profileImage.isEmpty
            ? const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider
            : CachedNetworkImageProvider(suggestion.profileImage);
    final Color statusColor = suggestion.lastLogin.idle ?? false
        ? const Color(0xFFFFA812)
        : suggestion.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
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
                      border: Border.all(color: theme.primaryColor, width: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 13),
          Text(suggestion.searchString)
        ],
      ),
    );
  }
}
