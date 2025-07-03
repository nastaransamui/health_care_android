
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/reviews.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/review_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/review_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/rating_progress.dart';
import 'package:health_care/shared/review_show_card.dart';
import 'package:health_care/shared/star_review_widget.dart';
import 'package:health_care/src/features/doctors/profile/reviews/add_review_widget.dart';
import 'package:health_care/src/utils/calculate_average_rating.dart';
import 'package:health_care/src/utils/get_star_rating_proportion.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class PublicReviewWidget extends StatefulWidget {
  final DoctorUserProfile doctorUserProfile;
  const PublicReviewWidget({
    super.key,
    required this.doctorUserProfile,
  });

  @override
  State<PublicReviewWidget> createState() => _PublicReviewWidgetState();
}

class _PublicReviewWidgetState extends State<PublicReviewWidget> {
  final ReviewService reviewService = ReviewService();
  final AuthService authService = AuthService();
  late final ReviewProvider reviewProvider;
  late final AuthProvider authProvider;
  bool _isProvidersInitialized = false;
  Future<void> getDataOnUpdate() async {
    String? doctorId = widget.doctorUserProfile.id;
    reviewService.getDoctorReviews(context, doctorId!);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('updateGetDoctorReviews');
    socket.off('getDoctorReviewsReturn');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ReviewProvider>(
      builder: (context, authProvider, reviewProvider, child) {
        final List<Reviews> doctorsReviews = reviewProvider.reviews;
        final DoctorUserProfile doctorUserProfile = widget.doctorUserProfile;
        final String roleName = authProvider.roleName;
        final String? userId = authProvider.isLogin
            ? roleName == 'patient'
                ? authProvider.patientProfile?.userId
                : authProvider.doctorsProfile?.userId
            : "";
        final List<String>? userReviewArray = authProvider.isLogin
            ? roleName == 'patient'
                ? authProvider.patientProfile?.userProfile.reviewsArray 
                : authProvider.doctorsProfile?.userProfile.reviewsArray
            : [];
        bool canAddReview = doctorUserProfile.patientsId.contains(userId); 
        // || doctorUserProfile.favsId.contains(userId);
        bool isLoading = reviewProvider.isLoading;
        final int totalReviews = reviewProvider.total;
        final ThemeData theme = Theme.of(context);
        final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        List<double> rateArray = doctorUserProfile.rateArray;
        double averageRating = calculateAverageRating(rateArray);
        // Calculate proportions for each star rating
        final double fiveStarProportion = getStarRatingProportion(rateArray, 5.0);
        final double fourStarProportion = getStarRatingProportion(rateArray, 4.0);
        final double threeStarProportion = getStarRatingProportion(rateArray, 3.0);
        final double twoStarProportion = getStarRatingProportion(rateArray, 2.0);
        final double oneStarProportion = getStarRatingProportion(rateArray, 1.0);

        return Column(
          children: [
            AddReviewWidget(
              theme: theme,
              roleName: roleName,
              canAddReview: canAddReview,
              doctorUserProfile: doctorUserProfile,
              userId: userId,
              textColor: textColor,
              userReviewArray: userReviewArray ?? [],
            ),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.primaryColorLight),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          'totalPublicReviews',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ).plural(
                          totalReviews,
                          format: NumberFormat.compact(
                            locale: context.locale.toString(),
                          ),
                        ),
                ),
              ),
            ),
            if (rateArray.isNotEmpty) ...[
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.primaryColorLight),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '$averageRating',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 9,
                            child: Column(
                              children: [
                                RatingProgress(theme: theme, star: 5, value: fiveStarProportion),
                                RatingProgress(theme: theme, star: 4, value: fourStarProportion),
                                RatingProgress(theme: theme, star: 3, value: threeStarProportion),
                                RatingProgress(theme: theme, star: 2, value: twoStarProportion),
                                RatingProgress(theme: theme, star: 1, value: oneStarProportion),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StarReviewWidget(
                        rate: averageRating,
                        textColor: textColor,
                        starSize: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          NumberFormat("#,##0", "en_US").format(totalReviews),
                          style: const TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),
            CustomPaginationWidget(
              count: totalReviews,
              getDataOnUpdate: getDataOnUpdate,
            ),
            const SizedBox(height: 10),
            // Remove Expanded here, as SingleChildScrollView handles the scrollable area
            ListView.builder(
              shrinkWrap: true,
              restorationId: 'doctorsReview',
              key: const ValueKey('doctorsReview'),
              physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
              itemCount: doctorsReviews.length,
              itemBuilder: (context, index) {
                final review = doctorsReviews[index];
                return ReviewShowCard(
                  review: review,
                  getDataOnUpdate: getDataOnUpdate,
                  doctorName: doctorUserProfile.fullName,
                );
              },
            ),
            if (isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            ],
          ],
        );
      },
    );
  }
}
