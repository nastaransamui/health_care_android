import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import 'package:health_care/models/reviews.dart';
import 'package:health_care/models/users.dart';
import 'package:readmore/readmore.dart';
import 'package:timezone/timezone.dart' as tz;

class ReviewReplyCard extends StatefulWidget {
  final ReviewsReplies reply;
  final Function getDataOnUpdate; // Pass this down for sorting or updates
  final bool isNested; // To apply extra padding for nested replies

  const ReviewReplyCard({
    super.key,
    required this.reply,
    required this.getDataOnUpdate,
    this.isNested = false,
  });

  @override
  State<ReviewReplyCard> createState() => _ReviewReplyCardState();
}

class _ReviewReplyCardState extends State<ReviewReplyCard> {
  @override
  Widget build(BuildContext context) {
    final ReviewsReplies reply = widget.reply;
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    // Determine if it's a doctor's reply or patient's reply
    final bool isDoctorReply = reply.role == 'doctors';
    final dynamic authorProfile = isDoctorReply? reply.doctorProfile : reply.patientProfile;

    final String profileImage =
        isDoctorReply ? (authorProfile as DoctorUserProfile).profileImage : (authorProfile as PatientUserProfile).profileImage;
    final String encodedAuthorId = base64.encode(utf8.encode(authorProfile.id.toString()));
    final String authorName = isDoctorReply
        ? "Dr. ${(authorProfile).fullName}"
        : "${(authorProfile as PatientUserProfile).gender}${(authorProfile).gender != '' ? '. ' : ''}${(authorProfile).fullName}";

    final ImageProvider<Object> avatarImage =
        profileImage.isEmpty ? const AssetImage('assets/images/default-avatar.png') as ImageProvider : CachedNetworkImageProvider(profileImage);

    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    final Color statusColor = authorProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : authorProfile.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);

    return Padding(
      // Add indentation for nested replies
      padding: EdgeInsets.only(left: widget.isNested ? 20.0 : 0.0, top: 8.0, bottom: 8.0),
      child: Card(
        elevation: 6, // Slightly less elevation for replies
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.dividerColor), // Lighter border for replies
          borderRadius: const BorderRadius.all(Radius.circular(10)), // Slightly smaller radius
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // Slightly less padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigate to appropriate profile based on role
                              if (isDoctorReply) {
                                // context.push(Uri(path: '/doctors/dashboard/doctor-profile/$encodedAuthorId').toString()); // Assuming a route for doctor profiles
                              } else {
                                context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedAuthorId').toString());
                              }
                            },
                            child: CircleAvatar(
                              backgroundImage: avatarImage,
                              radius: 20, // Smaller avatar for replies
                            ),
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
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
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isDoctorReply) {
                                // context.push(Uri(path: '/doctors/dashboard/doctor-profile/$encodedAuthorId').toString());
                              } else {
                                context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedAuthorId').toString());
                              }
                            },
                            child: Text(
                              authorName,
                              style: TextStyle(
                                color: isDoctorReply ? theme.primaryColor : theme.primaryColorLight, // Doctor's name different color
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy HH:mm').format(
                              tz.TZDateTime.from(reply.createdAt, bangkok),
                            ),
                            style: TextStyle(fontSize: 10, color: textColor),
                          ),
                          Text(
                            '#${reply.replyId}',
                            style: TextStyle(fontSize: 10, color: theme.primaryColorLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // No reply button for replies, or a different action if needed
                ],
              ),
              const SizedBox(height: 8),
              // Reply Title (optional for replies)
              if (reply.title.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${context.tr('title')}: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Expanded(
                      child: Text(
                        reply.title,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
              ],
              // Reply Body
              Text("${context.tr('message')}: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ReadMoreText(
                reply.body,
                trimLines: 2,
                trimMode: TrimMode.Line,
                trimCollapsedText: context.tr('readMore'),
                trimExpandedText: context.tr('readLess'),
                moreStyle: TextStyle(color: theme.primaryColorLight, fontSize: 13),
                lessStyle: TextStyle(color: theme.primaryColor, fontSize: 13),
                style: TextStyle(fontSize: 13, color: textColor),
              ),
              // Recursively display nested replies
              if (reply.replies.isNotEmpty)
                Column(
                  children: reply.replies.map((nestedReply) {
                    return ReviewReplyCard(
                      reply: nestedReply,
                      getDataOnUpdate: widget.getDataOnUpdate,
                      isNested: true, // Mark as nested for further indentation
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
