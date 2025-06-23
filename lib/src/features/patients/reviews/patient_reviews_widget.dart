
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/reviews.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/review_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/review_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/patients/reviews/patient_review_show_card.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientReviewsWidget extends StatefulWidget {
  static const String routeName = '/patient/dashboard/review';
  const PatientReviewsWidget({super.key});

  @override
  State<PatientReviewsWidget> createState() => _PatientReviewsWidgetState();
}

class _PatientReviewsWidgetState extends State<PatientReviewsWidget> {
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final ReviewService reviewService = ReviewService();
  late final ReviewProvider reviewProvider;
  late final DataGridProvider dataGridProvider;
  late List<String> deleteIds;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate() async {
    reviewService.getAuthorReviews(context);
    setState(() {
      deleteIds.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    deleteIds= [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  Future<void> getConfirmationForDeleteReview(
    BuildContext context,
    List<String> deleteIds,
  ) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColorLight,
            title: const Text("deleteReviewRequest").plural(
              deleteIds.length,
              format: NumberFormat.compact(
                locale: context.locale.toString(),
              ),
            ),
            automaticallyImplyLeading: false, // Removes the back button
            actions: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    elevation: 6,
                    color: Theme.of(context).canvasColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColorLight),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Text(
                        context.tr("confirmDeleteReview"),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).primaryColor,
                        ),
                      )),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, deleteIds);
                    },
                    child: Text(context.tr("submit")),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    if (!context.mounted) return;

    if (result != null) {
      deleteDependentRequestSubmit(context, result);
    }
  }

  Future<void> deleteDependentRequestSubmit(BuildContext context, List<String> deleteIds) async {
    bool success = await reviewService.deleteReview(context, deleteIds);

    if (success) {
      if (context.mounted) {
        showErrorSnackBar(context, "${deleteIds.length} Reviews(s) was deleted.");
      }
      setState(() {
        deleteIds.clear();
      });
    }
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
    socket.off('deleteReviewReturn');
    socket.off('getAuthorReviewsReturn');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        final List<PatientReviews> patientReviews = reviewProvider.patientReviews;
        bool isLoading = reviewProvider.isLoading;
        final int totalReviews = reviewProvider.total;
        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        final ThemeData theme = Theme.of(context);
        final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'doctorProfile.fullName', label: Text(context.tr('doctorName'))), dataType: 'string'),
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
                      // confirmed delete
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.vertical,
                            child: child,
                          );
                        },
                        child: deleteIds.isNotEmpty
                            ? Padding(
                                key: const ValueKey("buttonVisible"),
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  child: GradientButton(
                                    onPressed: () async {
                                      getConfirmationForDeleteReview(context, deleteIds);
                                    },
                                    colors: const [
                                      Colors.pink,
                                      Colors.red,
                                    ],
                                    child: Center(
                                      child: Text(
                                        "deleteReviewRequest",
                                        style: TextStyle(fontSize: 12, color: textColor),
                                      ).plural(
                                        deleteIds.length,
                                        format: NumberFormat.compact(
                                          locale: context.locale.toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey("buttonHidden")),
                      ),
                      const SizedBox(height: 10),
                      CustomPaginationWidget(
                        count: totalReviews,
                        getDataOnUpdate: getDataOnUpdate,
                      ),
                      const SizedBox(height: 10),
                     Row(
                        children: [
                          Checkbox(
                            splashRadius: 0,
                            checkColor: theme.primaryColorLight,
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            value: deleteIds.isNotEmpty,
                            onChanged: (bool? value) {
                              if (value == false) {
                                setState(() {
                                  deleteIds.clear();
                                });
                              } else {
                                setState(() {
                                  deleteIds = patientReviews.map((rev) => rev.id.toString()).toList();
                                });
                              }
                            },
                          ),
                          Text('taggleReviewsForDelete',
                              style: TextStyle(
                                fontSize: 18,
                                color: theme.primaryColorLight,
                              )).plural(
                            patientReviews.length,
                            format: NumberFormat.compact(
                              locale: context.locale.toString(),
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        restorationId: 'doctorsReview',
                        key: const ValueKey('doctorsReview'),
                        physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                        itemCount: patientReviews.length,
                        itemBuilder: (context, index) {
                          final review = patientReviews[index];
                          return FadeinWidget(
                            isCenter: true,
                            child: PatientReviewShowCard(
                              review: review,
                              getDataOnUpdate: getDataOnUpdate,
                              getConfirmationForDeleteReview: getConfirmationForDeleteReview,
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
