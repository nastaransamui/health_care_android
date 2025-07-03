
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/services/review_service.dart';
import 'package:health_care/shared/dashboard_main_card_under_header.dart';
import 'package:health_care/shared/patient_doctor_profile_header.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/profile/availablity/availablity_widget.dart';
import 'package:health_care/src/features/doctors/profile/businesshours/business_hours_widget.dart';
import 'package:health_care/src/features/doctors/profile/overview/over_view_widget.dart';
import 'package:health_care/src/features/doctors/profile/reviews/public_review_widget.dart';
import 'package:health_care/src/features/doctors/profile/search_profile_booking_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DoctorsSearchProfile extends StatefulWidget {
  static const String routeName = '/doctors/profile';
  final String doctorId;
  const DoctorsSearchProfile({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorsSearchProfile> createState() => _DoctorsSearchProfileState();
}

class _DoctorsSearchProfileState extends State<DoctorsSearchProfile> {
  final DoctorsService doctorsService = DoctorsService();
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  late final DoctorsProvider doctorsProvider;
  late final AuthProvider authProvider;
  late final DataGridProvider dataGridProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  bool _hasRedirected = false;
  bool isLoading = true;
  int _currentTabIndex = 0;
  Future<void> getDataOnUpdate() async {
    await doctorsService.findUserById(
      context,
      widget.doctorId,
      () {
        if (context.mounted) {
          setState(() => isLoading = false);
        }
      },
    );
  }

  final ReviewService reviewService = ReviewService();
  Future<void> getReviewDataOnUpdate() async {
    String doctorId = widget.doctorId;
    reviewService.getDoctorReviews(context, doctorId);
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
      doctorsProvider = Provider.of<DoctorsProvider>(context, listen: false);
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('findUserByIdReturn');
    socket.off('updateFindUserById');
    dataGridProvider.setMongoFilterModel({}, notify: false);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorsProvider>(
      builder: (context, doctorsProvider, child) {
        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'patientProfile.fullName', label: Text(context.tr('patientName'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'recommend', label: Text(context.tr('recommend'))), dataType: 'boolean'),
          FilterableGridColumn(column: GridColumn(columnName: 'rating', label: Text(context.tr('rating'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'updatedAt', label: Text(context.tr('updateAt'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'title', label: Text(context.tr('title'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'body', label: Text(context.tr('message'))), dataType: 'string'),
        ];
        final DoctorUserProfile? doctorUserProfile = doctorsProvider.singleDoctor;
        if (isLoading) {
          return ScaffoldWrapper(
            title: context.tr('doctorsProfile'),
            children: const Center(child: CircularProgressIndicator()),
          );
        }
        //Redirect if id is empty
        if ((doctorUserProfile!.id?.isEmpty ?? true) && !_hasRedirected) {
          _hasRedirected = true;
          Future.microtask(() {
            if (context.mounted) {
              context.push('/doctors/search');
            }
          });
        }
        final ThemeData theme = Theme.of(context);

        return DefaultTabController(
          length: 4,
          child: ScaffoldWrapper(
            title: 'Dr. ${doctorUserProfile.fullName}',
            children: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    double per = 0;
                    if (scrollController.hasClients) {
                      per = (scrollController.offset / scrollController.position.maxScrollExtent);
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PatientDoctorProfileHeader(doctorUserProfile: doctorUserProfile),
                        DashboardMainCardUnderHeader(
                          children: [
                            SearchProfileBookingBox(doctorUserProfile: doctorUserProfile),
                            TabBar(
                              onTap: (index) {
                                setState(() {
                                  _currentTabIndex = index;
                                });
                              },
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                              dividerColor: theme.primaryColorLight,
                              tabs: [
                                Tab(text: context.tr('overView')),
                                Tab(text: context.tr('availability')),
                                Tab(text: context.tr('reviews')),
                                Tab(text: context.tr('businessHours')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTabContent(_currentTabIndex, doctorUserProfile),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
                if (_currentTabIndex == 2)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: FloatingActionButton(
                        tooltip: context.tr('filter'),
                        mini: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: theme.primaryColor, width: 1),
                        ),
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
                            await getReviewDataOnUpdate();
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
          ),
        );
      },
    );
  }

  Widget _buildTabContent(int index, DoctorUserProfile doctorUserProfile) {
    switch (index) {
      case 0:
        return OverViewWidget(doctorUserProfile: doctorUserProfile);
      case 1:
        return AvailablityWidget(doctorUserProfile: doctorUserProfile);
      case 2:
        return PublicReviewWidget(doctorUserProfile: doctorUserProfile);
      case 3:
        return BusinessHoursWidget(doctorUserProfile: doctorUserProfile);
      default:
        return const SizedBox.shrink();
    }
  }
}
