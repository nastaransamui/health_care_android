import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/reviews.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/services/review_service.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/reply_button_sheet.dart';
import 'package:health_care/shared/review_reply_card.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/shared/star_review_widget.dart';
import 'package:health_care/src/features/patients/dependents/patients_dependants_show_box.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:readmore/readmore.dart';
import 'package:timezone/timezone.dart' as tz;

class PatientReviewShowCard extends StatefulWidget {
  final PatientReviews review;
  final VoidCallback getDataOnUpdate;
  final Future<void> Function(BuildContext, List<String>) getConfirmationForDeleteReview;
  const PatientReviewShowCard({
    super.key,
    required this.review,
    required this.getDataOnUpdate,
    required this.getConfirmationForDeleteReview,
  });

  @override
  State<PatientReviewShowCard> createState() => _PatientReviewShowCardState();
}

class _PatientReviewShowCardState extends State<PatientReviewShowCard> {
  final ReviewService reviewService = ReviewService();
  @override
  Widget build(BuildContext context) {
    final PatientReviews review = widget.review;
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final DoctorUserProfile doctorUserProfile = review.doctorProfile;
    final String doctorProfileImage = doctorUserProfile.profileImage;
    final bangkok = tz.getLocation('Asia/Bangkok');
    final encodeddoctorId = base64.encode(utf8.encode(doctorUserProfile.id.toString()));
    final String doctorName = "Dr. ${doctorUserProfile.fullName}";
    final ImageProvider<Object> avatarImage = doctorProfileImage.isEmpty
        ? const AssetImage('assets/images/default-avatar.png') as ImageProvider
        : CachedNetworkImageProvider(doctorProfileImage);
    final Color statusColor = doctorUserProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : doctorUserProfile.online
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
              //Profile row
              ProfileRow(
                  encodeddoctorId: encodeddoctorId,
                  avatarImage: avatarImage,
                  statusColor: statusColor,
                  theme: theme,
                  doctorName: doctorName,
                  widget: widget,
                  review: review),
              MyDevider(theme: theme),
              // RateRow
              RateRow(review: review, textColor: textColor, widget: widget),
              MyDevider(theme: theme),
              CreatedRow(review: review, bangkok: bangkok, widget: widget),
              MyDevider(theme: theme),
              review.recommend ? RecommendedRow(widget: widget) : NotRecommended(widget: widget),
              MyDevider(theme: theme),
              TitleRow(review: review, widget: widget),
              MyDevider(theme: theme),
              MessageRow(widget: widget),
              // Text(review.body),
              BodyRow(review: review, theme: theme),
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
              ButtonRow(review: review, reviewService: reviewService, theme: theme, textColor: textColor, doctorName: doctorName),

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
                            widget.getConfirmationForDeleteReview(context, [review.id]);
                          },
                          colors: const [
                            Colors.pink,
                            Colors.red,
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, size: 13, color: textColor),
                              const SizedBox(width: 5),
                              Text(
                                context.tr("delete"),
                                style: TextStyle(fontSize: 12, color: textColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
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

class ButtonRow extends StatelessWidget {
  const ButtonRow({
    super.key,
    required this.review,
    required this.reviewService,
    required this.theme,
    required this.textColor,
    required this.doctorName,
  });

  final PatientReviews review;
  final ReviewService reviewService;
  final ThemeData theme;
  final Color textColor;
  final String doctorName;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        patientReviews: review,
                        replyTo: 'doctors',
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
                      context.tr("replyTo", args: [doctorName]),
                      style: TextStyle(fontSize: 12, color: textColor),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BodyRow extends StatelessWidget {
  const BodyRow({
    super.key,
    required this.review,
    required this.theme,
  });

  final PatientReviews review;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class MessageRow extends StatelessWidget {
  const MessageRow({
    super.key,
    required this.widget,
  });

  final PatientReviewShowCard widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class TitleRow extends StatelessWidget {
  const TitleRow({
    super.key,
    required this.review,
    required this.widget,
  });

  final PatientReviews review;
  final PatientReviewShowCard widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class NotRecommended extends StatelessWidget {
  const NotRecommended({
    super.key,
    required this.widget,
  });

  final PatientReviewShowCard widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class RecommendedRow extends StatelessWidget {
  const RecommendedRow({
    super.key,
    required this.widget,
  });

  final PatientReviewShowCard widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class CreatedRow extends StatelessWidget {
  const CreatedRow({
    super.key,
    required this.review,
    required this.bangkok,
    required this.widget,
  });

  final PatientReviews review;
  final tz.Location bangkok;
  final PatientReviewShowCard widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class RateRow extends StatelessWidget {
  const RateRow({
    super.key,
    required this.review,
    required this.textColor,
    required this.widget,
  });

  final PatientReviews review;
  final Color textColor;
  final PatientReviewShowCard widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
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
    );
  }
}

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.encodeddoctorId,
    required this.avatarImage,
    required this.statusColor,
    required this.theme,
    required this.doctorName,
    required this.widget,
    required this.review,
  });

  final String encodeddoctorId;
  final ImageProvider<Object> avatarImage;
  final Color statusColor;
  final ThemeData theme;
  final String doctorName;
  final PatientReviewShowCard widget;
  final PatientReviews review;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
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
              //DoctorName row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
                      },
                      child: Text(
                        doctorName,
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
                    columnName: 'doctorProfile.fullName',
                    getDataOnUpdate: widget.getDataOnUpdate,
                  )
                ],
              ),
              const SizedBox(height: 5),
              // Id row
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
    );
  }
}
