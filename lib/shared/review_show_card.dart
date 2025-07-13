import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/reply_button_sheet.dart';
import 'package:health_care/shared/review_reply_card.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/shared/star_review_widget.dart';
import 'package:health_care/src/features/patients/dependents/patients_dependants_show_box.dart';
import 'package:health_care/src/utils/hex_to_color.dart';

import 'package:health_care/models/reviews.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/services/review_service.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:timezone/timezone.dart' as tz;

class ReviewShowCard extends StatefulWidget {
  final Reviews review;
  final VoidCallback getDataOnUpdate;
  final String doctorName;
  const ReviewShowCard({
    super.key,
    required this.review,
    required this.getDataOnUpdate,
    required this.doctorName,
  });

  @override
  State<ReviewShowCard> createState() => _ReviewShowCardState();
}

class _ReviewShowCardState extends State<ReviewShowCard> {
  final ReviewService reviewService = ReviewService();
  late final AuthProvider authProvider;
  late String roleName = "";
  String userId = '';
  bool _isProvidersInitialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
    roleName = authProvider.roleName;
    final id = roleName == 'patient' ? authProvider.patientProfile?.userId : authProvider.doctorsProfile?.userId;

    final newPatientId = id ?? '';

    if (userId != newPatientId) {
      setState(() {
        userId = newPatientId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Reviews review = widget.review;
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final PatientUserProfile patientUserProfile = review.patientProfile;
    final String patientProfileImage = patientUserProfile.profileImage;
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    final encodedpatientId = base64.encode(utf8.encode(patientUserProfile.id.toString()));
    final String patientName = "${patientUserProfile.gender}${patientUserProfile.gender.isNotEmpty ? '. ' : ''}${patientUserProfile.fullName}";
    final ImageProvider<Object> avatarImage = patientProfileImage.isEmpty
        ? const AssetImage('assets/images/default-avatar.png') as ImageProvider
        : CachedNetworkImageProvider(patientProfileImage);
    final Color statusColor = patientUserProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : patientUserProfile.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile
              Row(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedpatientId').toString());
                        },
                        child: CircleAvatar(
                          backgroundImage: avatarImage,
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  context.push(Uri(path: '/doctors/dashboard/patient-profile/$encodedpatientId').toString());
                                },
                                child: Text(
                                  patientName,
                                  style: TextStyle(
                                    color: theme.primaryColorLight,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(
                              columnName: 'patientProfile.fullName',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '#${review.reviewId}',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(
                              columnName: 'id',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              MyDevider(theme: theme),
              // Rating
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: StarReviewWidget(
                        rate: review.rating,
                        textColor: textColor,
                        starSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'rating',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // created
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('${context.tr('createdAt')}: '),
                          Text(
                            DateFormat('dd MMM yyyy HH:mm').format(
                              tz.TZDateTime.from(review.updatedAt, bangkok),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'createdAt',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Recomended
              review.recommend
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.thumbsUp,
                                  color: hexToColor('#28a745'),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  context.tr('iRecommendTheDoctor'),
                                  style: TextStyle(color: hexToColor('#28a745'), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          SortIconWidget(
                            columnName: 'recommend',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          )
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.thumbsDown,
                                color: Colors.pink[700],
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.tr('iNotRecommendTheDoctor'),
                                style: TextStyle(color: Colors.pink[700], fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          SortIconWidget(
                            columnName: 'recommend',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          )
                        ],
                      ),
                    ),
              MyDevider(theme: theme),
              // title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text("${context.tr('title')}: "),
                          Text(review.title),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'title',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Message
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("${context.tr('message')}: ")),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'body',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              // Text(review.body),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ReadMoreText(
                  review.body,
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: context.tr('readMore'),
                  trimExpandedText: context.tr('readLess'),
                  moreStyle: TextStyle(color: theme.primaryColorLight),
                  lessStyle: TextStyle(color: theme.primaryColor),
                ),
              ),
              if (review.replies.isNotEmpty) ...[
                MyDevider(theme: theme),
                Column(
                  children: [
                    ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -4),
                      title: Text(
                        context.tr('replies'),
                      ),
                    ),
                    ...review.replies.map(
                      (reply) {
                        return ReviewReplyCard(
                          reply: reply,
                          getDataOnUpdate: widget.getDataOnUpdate,
                          isNested: false, // This is the first level of replies
                        );
                      },
                    )
                  ],
                ),
              ],
              //  MyDevider(theme: theme),
              
              if (roleName.isNotEmpty) ...[
                if (userId == review.doctorId || userId == review.authorId)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 35,
                            child: GradientButton(
                              onPressed: () async {
                                final payload = await showModalBottomSheet<Map<String, dynamic>>(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  builder: (context) => FractionallySizedBox(
                                    heightFactor: 1,
                                    child: ReplyButtonSheet(
                                      review: review,
                                      replyTo: 'patient',
                                    ),
                                  ),
                                );

                                if (payload != null) {
                                  if (context.mounted) {
                                    reviewService.updateReply(context, payload);
                                  }
                                }
                              },
                              colors: [
                                theme.primaryColorLight,
                                theme.primaryColor,
                              ],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(FontAwesomeIcons.reply, size: 13, color: textColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    context.tr("replyTo", args: [roleName == 'patient' ? 'Dr. ${widget.doctorName}' : patientName]),
                                    style: TextStyle(fontSize: 12, color: textColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
