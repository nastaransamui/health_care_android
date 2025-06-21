
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/shared/rating_progress.dart';
import 'package:health_care/shared/review_show_card.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/shared/star_review_widget.dart';
import 'package:health_care/src/utils/calculate_average_rating.dart';
import 'package:health_care/src/utils/get_star_rating_proportion.dart';
import 'package:provider/provider.dart';

import 'package:health_care/models/reviews.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/review_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/review_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/stream_socket.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DoctorsReviews extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/reviews';
  const DoctorsReviews({super.key});

  @override
  State<DoctorsReviews> createState() => _DoctorsReviewsState();
}

class _DoctorsReviewsState extends State<DoctorsReviews> {
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final ReviewService reviewService = ReviewService();
  late final ReviewProvider reviewProvider;
  late final DataGridProvider dataGridProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate() async {
    reviewService.getDoctorReviews(context);
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
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    dataGridProvider.setMongoFilterModel({}, notify: false);
    socket.off('updateGetDoctorReviews');
    socket.off('getDoctorReviewsReturn');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        final List<Reviews> doctorsReviews = reviewProvider.reviews;
        final DoctorsProfile? doctorUserProfile = authProvider.doctorsProfile;
        bool isLoading = reviewProvider.isLoading;
        final int totalReviews = reviewProvider.total;
        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        final ThemeData theme = Theme.of(context);
        final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        List<double> rateArray = doctorUserProfile?.userProfile.rateArray ?? [];
        double averageRating = calculateAverageRating(rateArray);
        // Calculate proportions for each star rating
        final double fiveStarProportion = getStarRatingProportion(rateArray, 5.0);
        final double fourStarProportion = getStarRatingProportion(rateArray, 4.0);
        final double threeStarProportion = getStarRatingProportion(rateArray, 3.0);
        final double twoStarProportion = getStarRatingProportion(rateArray, 2.0);
        final double oneStarProportion = getStarRatingProportion(rateArray, 1.0);

        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'patientProfile.fullName', label: Text(context.tr('patientName'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'recommend', label: Text(context.tr('recommend'))), dataType: 'boolean'),
          FilterableGridColumn(column: GridColumn(columnName: 'rating', label: Text(context.tr('rating'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'updatedAt', label: Text(context.tr('updateAt'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'title', label: Text(context.tr('title'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'body', label: Text(context.tr('message'))), dataType: 'string'),
        ];

        return ScaffoldWrapper(
          title: context.tr('reviews'),
          children: Stack(
            children: [
              // Wrap the entire Column with SingleChildScrollView
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  double per = 0;
                  if (scrollController.hasClients) {
                    per = ((scrollController.offset / scrollController.position.maxScrollExtent));
                  }
                  if (per >= 0) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        setState(() {
                          scrollPercentage = 307 * per;
                        });
                      }
                    });
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      FadeinWidget(
                        isCenter: true,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
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
                                child: Text(
                                  'totalReviews',
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
                        ),
                      ),
                      if (rateArray.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        FadeinWidget(
                          isCenter: true,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
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
                                            )),
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
                                        NumberFormat("#,##0", "en_US").format(rateArray.length),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                              ),
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
                          return FadeinWidget(
                            isCenter: true,
                            child: ReviewShowCard(
                              review: review,
                              getDataOnUpdate: getDataOnUpdate,
                            ),
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
                  ),
                ),
              ),
              // The ScrollButton and FloatingActionButton remain outside the SingleChildScrollView
              // so they are positioned relative to the ScaffoldWrapper's body.
              ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
              Positioned(
                bottom: 10,
                left: 10,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: FloatingActionButton(
                    tooltip: context.tr('filter'),
                    mini: true,
                    onPressed: () async {
                      final result = await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => FractionallySizedBox(
                          heightFactor: 0.9,
                          child: SfDataGridFilterWidget(columns: filterableColumns, columnName: 'id'),
                        ),
                      );

                      if (result != null) {
                        dataGridProvider.setPaginationModel(0, 10);
                        dataGridProvider.setMongoFilterModel({...result});
                        await getDataOnUpdate();
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 25,
                          color: theme.primaryColor,
                        ),
                        if (isFilterActive)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
