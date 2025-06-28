
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/doctors.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/services/user_data_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/search/doctor_slideable_widget.dart';
import 'package:health_care/src/features/doctors/search/searchWidgets/filter_box_widget.dart';
import 'package:health_care/src/features/doctors/search/searchWidgets/no_data_widget.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:session_storage/session_storage.dart';

class DoctorSearch extends StatefulWidget {
  final Map<String, String> queryParameters;
  const DoctorSearch({
    super.key,
    required this.queryParameters,
  });

  @override
  State<DoctorSearch> createState() => _DoctorSearchState();
}

class _DoctorSearchState extends State<DoctorSearch> {
  final DoctorsService doctorsService = DoctorsService();
  final UserDataService userDataService = UserDataService();
  final AuthService authService = AuthService();
  late final DoctorsProvider doctorsProvider;
  late final DataGridProvider dataGridProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  bool isLoading = true;
  int? expandedIndex;
  final keyWordController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final session = SessionStorage();
  bool isFinished = false;
  int perPage = 10;
  int page = 1;
  // String sortBy = 'profile.userName';

  Future<void> getDataOnUpdate() async {
    final paginationModel = dataGridProvider.paginationModel;
    final sortModel = dataGridProvider.sortModel;
    int page = paginationModel.values.first;
    int perPage = paginationModel.values.last;
    int limit = page == 0 ? perPage : page * perPage;
    int skip = page == 0 ? page : limit - perPage;

    var payload = {
      "keyWord": widget.queryParameters['keyWord'],
      "specialities": widget.queryParameters['specialities'],
      "gender": widget.queryParameters['gender'],
      "available": widget.queryParameters['available'],
      "country": widget.queryParameters['country'],
      "state": widget.queryParameters['state'],
      "city": widget.queryParameters['city'],
      "limit": limit,
      "skip": skip,
      "sortModel": sortModel,
    };
    await doctorsService.doctorSearch(context, payload, () {
      if (context.mounted) {
        setState(() => isLoading = false);
      }
    });
    setState(() {
      expandedIndex = null;
    });
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);

    keyWordController.text = widget.queryParameters['keyWord'] ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      doctorsProvider = Provider.of<DoctorsProvider>(context, listen: false);
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      dataGridProvider.setSortModel([
        {"field": "profile.userName", "sort": 'asc'}
      ], notify: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('doctorSearchReturn');
    socket.off('updateDoctorSearch');
    doctorsProvider.setDoctorsSearch([], notify: false);
    doctorsProvider.setTotal(0, notify: false);
    keyWordController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DoctorSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    getDataOnUpdate();
  }

  void updateIsFinished(bool value) {
    setState(() {
      isFinished = value;
    });
  }

  void updateSortBy(String value) {
    dataGridProvider.setSortModel([
      {"field": value, "sort": 'desc'}
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorsProvider>(
      builder: (context, doctorsProvider, child) {
        final searchDoctors = doctorsProvider.searchDoctors;
        int totalDoctors = doctorsProvider.total;
        // bool isLoading = doctorsProvider.isLoading;
        final theme = Theme.of(context);
        final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        final Map<String, String> localQueryParams = {...widget.queryParameters};

        return ScaffoldWrapper(
          title: 'search',
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
                      if (mounted) {
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
                      FilterBoxWidget(
                        doctorsProvider: doctorsProvider,
                        queryParameters: localQueryParams,
                        updateIsFinished: updateIsFinished,
                        updateSortBy: updateSortBy,
                      ),
                      if (!isFinished) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: ListTile(
                                textColor: textColor,
                                title: Text(
                                  context.tr('doctors'),
                                ),
                                subtitle: const Text('doctorsNumber').plural(
                                  (totalDoctors),
                                  format: NumberFormat.compact(
                                    locale: context.locale.toString(),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: ListTile(textColor: textColor, subtitle: Text(context.tr('slideToSeeMore'))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomPaginationWidget(
                          count: totalDoctors,
                          getDataOnUpdate: getDataOnUpdate,
                        ),
                        if (isLoading && searchDoctors.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (searchDoctors.isEmpty)
                          const NoDataWidget()
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            restorationId: 'doctorFavorite',
                            key: const ValueKey('doctorFavorite'),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: searchDoctors.length,
                            itemBuilder: (context, index) {
                              final Doctors doctor = searchDoctors[index];
                              return DoctorSlideableWidget(
                                doctor: doctor,
                                getDataOnUpdate: getDataOnUpdate,
                                isExpanded: expandedIndex == index,
                                index: index,
                                onToggle: (tappedIndex) {
                                  setState(() {
                                    expandedIndex = (expandedIndex == tappedIndex) ? null : tappedIndex;
                                  });
                                },
                              );
                            },
                          )
                      ]
                    ],
                  ),
                ),
              ),
              ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
            ],
          ),
        );
      },
    );
  }
}
