
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/services/review_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/src/features/auth/login_screen.dart';
import 'package:health_care/src/features/doctors/profile/reviews/review_button_sheet.dart';

class AddReviewWidget extends StatefulWidget {
  const AddReviewWidget({
    super.key,
    required this.theme,
    required this.roleName,
    required this.canAddReview,
    required this.doctorUserProfile,
    required this.userId,
    required this.textColor,
    required this.userReviewArray,
  });

  final ThemeData theme;
  final String roleName;
  final bool canAddReview;
  final DoctorUserProfile doctorUserProfile;
  final String? userId;
  final Color textColor;
  final List<String> userReviewArray;

  @override
  State<AddReviewWidget> createState() => _AddReviewWidgetState();
}

class _AddReviewWidgetState extends State<AddReviewWidget> {
  final ReviewService reviewService = ReviewService();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: alreadyHasReview(widget.doctorUserProfile.reviewsArray, widget.userReviewArray)
      && widget.userId != widget.doctorUserProfile.id
          ? Text(
              context.tr('addReviewAlready', args: [widget.doctorUserProfile.fullName]),
              style: const TextStyle(
                fontSize: 20,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            )
          : Container(
              height: widget.canAddReview ? 35 : 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.theme.primaryColor,
                    widget.theme.primaryColorLight,
                  ],
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(8),
                  right: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.all(1),
              child: GestureDetector(
                onTap: () async {
                  if (widget.roleName.isEmpty) {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      useSafeArea: true,
                      isDismissible: true,
                      enableDrag: true,
                      showDragHandle: true,
                      context: context,
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: LoginScreen(),
                      ),
                    );
                  }
                  if (widget.canAddReview) {
                    final result = await showModalBottomSheet<Map<String, dynamic>>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => FractionallySizedBox(
                        heightFactor: 1,
                        child: ReviewButtonSheet(doctorUserProfile: widget.doctorUserProfile),
                      ),
                    );

                    if (result != null) {
                      var payload = {
                        "authorId": widget.userId,
                        "role": widget.roleName,
                        "rating": result["rating"],
                        "doctorId": widget.doctorUserProfile.id,
                        "title": result["title"],
                        "body": result["body"],
                        "recommend": result["recommend"],
                        "replies": [],
                      };
                      if (context.mounted) {
                        bool success = await reviewService.updateReview(context, payload);

                        if (success) {
                          if (context.mounted) {
                            showErrorSnackBar(context, context.tr('reviewAdded', args: [widget.doctorUserProfile.fullName]));
                          }
                        }
                      }
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.theme.primaryColorLight,
                        widget.theme.primaryColor,
                      ],
                    ),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(7),
                      right: Radius.circular(7),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.roleName.isEmpty
                          ? context.tr('loginToAddReview')
                          : widget.userId == widget.doctorUserProfile.id
                              ? context.tr('cantAddReviewToOwnDoctor')
                              : widget.canAddReview
                                  ? context.tr('addReview', args: [widget.doctorUserProfile.fullName])
                                  : context.tr('cantAddReviewWithoutReservation', args: [widget.doctorUserProfile.fullName]),
                      style: TextStyle(color: widget.textColor),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

bool alreadyHasReview(List<String> list1, List<String> list2) {
  final set1 = Set<String>.from(list1);
  return list2.any((item) => set1.contains(item));
}
