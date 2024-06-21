import 'package:avatar_glow/avatar_glow.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter_slidable_panel/controllers/slide_controller.dart';
import 'package:flutter_slidable_panel/delegates/action_layout_delegate.dart';
import 'package:flutter_slidable_panel/models.dart';
import 'package:flutter_slidable_panel/widgets/slidable_panel.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/stream_socket.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:health_care/models/doctors.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/services/user_data_service.dart';
import 'package:health_care/src/commons/packages/swipeable_button_view.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/silver_scaffold_wrapper.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:health_care/theme_config.dart';
import 'package:session_storage/session_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  List<Doctors>? doctors;
  int? totalDoctors;
  late List<Map<String, dynamic>> availabilityValues;
  late List<Map<String, dynamic>> sortByValues;
  final keyWordController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ScrollController filterWidgetScrollController = ScrollController();
  final session = SessionStorage();
  bool _isFinished = false;
  int limit = 10;
  int currentPage = 0;
  bool isLoading = false;
  static late String _chosenModel;
  static late String _sortByModel;

  String? specialitiesValue;
  String? genderValue;
  String? countryValue;
  String? stateValue;
  String? cityValue;
  String? keyWordValue;
  String? availabilityValue;
  String? sortBy = 'profile.userName';

  void fetchDoctors() {
    doctorsService.searchDoctorsData(context, {
      "keyWord": widget.queryParameters['keyWord'],
      "specialities": widget.queryParameters['specialities'],
      "gender": widget.queryParameters['gender'],
      "available": widget.queryParameters['available'],
      "country": widget.queryParameters['country'],
      "state": widget.queryParameters['state'],
      "city": widget.queryParameters['city'],
      "sortBy": sortBy,
      "skip": 0,
    });
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    session['limit'] = '10';
    scrollController.addListener(loadMore);
    specialitiesValue = widget.queryParameters['specialities'];
    genderValue = widget.queryParameters['gender'];
    countryValue = widget.queryParameters['country'];
    stateValue = widget.queryParameters['state'];
    cityValue = widget.queryParameters['city'];
    keyWordValue = widget.queryParameters['keyWord'];
    availabilityValue = widget.queryParameters['available'];
    keyWordController.text = widget.queryParameters['keyWord'] ?? '';

    fetchDoctors();
  }

  @override
  void didChangeDependencies() {
    context.locale.toString();
    if (doctors.runtimeType != Null) {
      setState(() {
        isLoading = false;
      });
    }

    super.didChangeDependencies();
  }

  void loadMore() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLoading) {
      limit = limit + 10;
      isLoading = true;

      session['limit'] = '$limit';
      fetchDoctors();
    }
  }

  @override
  void didUpdateWidget(covariant DoctorSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(const Duration(milliseconds: 1000), () {
      fetchDoctors();
    });
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      filterWidgetScrollController.animateTo(
        filterWidgetScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  void scrollUp() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      filterWidgetScrollController.animateTo(
        filterWidgetScrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  void updateFilterState(
      String? specialities,
      String? gender,
      String? country,
      String? state,
      String? city,
      String? keyWord,
      String? availability,
      Map<String, dynamic> localQueryParams) {
    setState(() {
      specialitiesValue = specialities;
      genderValue = gender;
      countryValue = country;
      stateValue = state;
      cityValue = city;
      keyWordValue = keyWord;
      availabilityValue = availability;
      isLoading = true;
    });
    localQueryParams.removeWhere((k, v) =>
        k == 'specialities' ||
        k == 'gender' ||
        k == 'country' ||
        k == 'state' ||
        k == 'city');
    Map<String, String> searchFilters = {
      ...localQueryParams,
      ...specialities != null ? {"specialities": specialities} : {},
      ...gender != null ? {"gender": gender} : {},
      ...country != null ? {"country": country} : {},
      ...state != null ? {"state": state} : {},
      ...city != null ? {"city": city} : {},
    };
    context.replace(
      Uri(
        path: '/doctors/search',
        queryParameters: searchFilters,
      ).toString(),
    );
  }

  void resetFilterState(Map<String, dynamic> localQueryParams) {
    setState(() {
      specialitiesValue = null;
      genderValue = null;
      countryValue = null;
      stateValue = null;
      cityValue = null;
      keyWordValue = null;
      availabilityValue = null;
      isLoading = true;
    });
    localQueryParams = {};
    keyWordController.text = '';
    context.replace(
      Uri(
        path: '/doctors/search',
        queryParameters: {},
      ).toString(),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    filterWidgetScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    doctors = Provider.of<DoctorsProvider>(context).searchDoctors;
    totalDoctors = Provider.of<DoctorsProvider>(context).totalDoctors;
    var localQueryParams = {...widget.queryParameters};
    availabilityValues = [
      {"value": context.tr('availability'), "search": null},
      {"value": context.tr('available'), "search": "Available"},
      {"value": context.tr('today'), "search": "AvailableToday"},
      {"value": context.tr('tomorrow'), "search": "AvailableTomorrow"},
      {"value": context.tr('thisWeek'), "search": "AvailableThisWeek"},
      {"value": context.tr('thisMonth'), "search": "AvailableThisMonth"},
    ];
    sortByValues = [
      {"value": context.tr('userName'), 'search': 'profile.userName'},
      {"value": context.tr('joinDate'), 'search': 'createdAt'},
    ];

    for (var element in sortByValues) {
      if (element['search'] == sortBy) {
        _sortByModel = element['value'];
      }
    }
    for (var element in availabilityValues) {
      if (element['search'] == widget.queryParameters['available']) {
        _chosenModel = element['value'];
      }
    }
    return ScaffoldWrapper(
      title: 'search',
      children: SizedBox(
          child: SingleChildScrollView(
        controller: filterWidgetScrollController,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Column(
                children: [
                  KeyWordWidget(
                    keyWordController: keyWordController,
                    localQueryParams: localQueryParams,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          // flex: 3,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 10.0),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 1),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                iconEnabledColor:
                                    Theme.of(context).primaryColorLight,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                                isExpanded: true,
                                value: _chosenModel,
                                items: availabilityValues
                                    .map<DropdownMenuItem<String>>(
                                        (Map<String, dynamic> values) {
                                  return DropdownMenuItem<String>(
                                    value: values['value'],
                                    child: Text(
                                      values['value']!,
                                      style: TextStyle(
                                        color: brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  _chosenModel = newValue!;
                                  setState(() {
                                    isLoading = true;
                                  });
                                  for (var element in availabilityValues) {
                                    if (element['value'] == newValue) {
                                      localQueryParams.remove('available');
                                      availabilityValue = element['search'];
                                      Map<String, String> searchFilters = {
                                        ...localQueryParams,
                                        ...element['search'] != null
                                            ? {"available": element['search']}
                                            : {},
                                      };
                                      context.replace(
                                        Uri(
                                          path: '/doctors/search',
                                          queryParameters: searchFilters,
                                        ).toString(),
                                      );
                                    }
                                  }
                                },
                                hint: Text(
                                  context.tr('availability'),
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          fit: FlexFit.loose,
                          // flex: 3,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 10.0),
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 1),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                iconEnabledColor:
                                    Theme.of(context).primaryColorLight,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                                isExpanded: true,
                                value: _sortByModel,
                                items: sortByValues
                                    .map<DropdownMenuItem<String>>(
                                        (Map<String, dynamic> values) {
                                  return DropdownMenuItem<String>(
                                    value: values['value'],
                                    child: Text(
                                      values['value']!,
                                      style: TextStyle(
                                        color: brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  _sortByModel = newValue!;
                                  for (var element in sortByValues) {
                                    if (element['value'] == newValue) {
                                      setState(() {
                                        sortBy = element['search'];
                                        isLoading = true;
                                      });
                                      context.replace(
                                        Uri(
                                          path: '/doctors/search',
                                          queryParameters: localQueryParams,
                                        ).toString(),
                                      );
                                    }
                                  }
                                },
                                hint: Text(
                                  context.tr('availability'),
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SwipeableButtonView(
                      indicatorColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                      isFinished: _isFinished,
                      onFinish: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                            child: FilterScreen(
                              title: 'title',
                              description: 'description',
                              specialitiesValue: specialitiesValue,
                              genderValue: genderValue,
                              countryValue: countryValue,
                              stateValue: stateValue,
                              cityValue: cityValue,
                              onSubmit: (
                                String? specialities,
                                String? gender,
                                String? country,
                                String? state,
                                String? city,
                              ) {
                                updateFilterState(
                                    specialities,
                                    gender,
                                    country,
                                    state,
                                    city,
                                    keyWordValue,
                                    availabilityValue,
                                    localQueryParams);
                              },
                              onReset: () {
                                resetFilterState(localQueryParams);
                              },
                            ),
                            type: PageTransitionType.fade,
                          ),
                        );

                        setState(() {
                          _isFinished = false;
                        });
                      },
                      onWaitingProcess: () {
                        Future.delayed(const Duration(microseconds: 300), () {
                          setState(() {
                            _isFinished = true;
                          });
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                      buttonColor: Theme.of(context).cardColor,
                      buttonWidget: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      buttonText: context.tr('filters'),
                      buttontextstyle: const TextStyle(color: Colors.black),
                    ),
                  ),
                  if (localQueryParams.entries.isNotEmpty) ...[
                    AnimatedCrossFade(
                      crossFadeState: !_isFinished
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 1000),
                      firstChild: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).primaryColorLight,
                            fixedSize: const Size(double.maxFinite, 30),
                            elevation: 5.0,
                          ),
                          onPressed: () {
                            resetFilterState(localQueryParams);
                          },
                          child: Text(context.tr('reset')),
                        ),
                      ),
                      secondChild: const Text(''),
                    ),
                  ],
                  AnimatedCrossFade(
                    crossFadeState: !_isFinished
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 1000),
                    firstChild: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${genderValue ?? ''} ${availabilityValue ?? ''}  ${specialitiesValue ?? ''} ${keyWordController.text}  ${countryValue ?? ''} ${stateValue ?? ''} ${cityValue ?? ''}',
                      ),
                    ),
                    secondChild: const Text(''),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isFinished) ...[
                      if (!isLoading) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: ListTile(
                                textColor: brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                title: Text(
                                  context.tr('doctors'),
                                ),
                                subtitle: const Text('doctorsNumber').plural(
                                  (totalDoctors ?? 0) as num,
                                  format: NumberFormat.compact(
                                    locale: context.locale.toString(),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: scrollUp,
                              icon: Icon(
                                Icons.arrow_upward,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            IconButton(
                              onPressed: scrollDown,
                              icon: const Icon(Icons.arrow_downward),
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: ListTile(
                                  textColor: brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  subtitle: Text(context.tr('slideToSeeMore'))),
                            ),
                          ],
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: SizedBox(
                            height:
                                MediaQuery.of(context).size.height / 2 + 135,
                            child: Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                totalDoctors == 0
                                    ? const NoDataWidget()
                                    : ListView.builder(
                                        restorationId: 'doctorSearch',
                                        key: const ValueKey('doctorSearch'),
                                        controller: scrollController,
                                        shrinkWrap: true,
                                        itemCount: doctors!.length +
                                            (isLoading ? 1 : 0),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          if (index + 1 == doctors!.length &&
                                              doctors!.length < totalDoctors!) {
                                            return Center(
                                              child: SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: LoadingIndicator(
                                                    indicatorType: Indicator
                                                        .ballRotateChase,
                                                    colors: [
                                                      Theme.of(context)
                                                          .primaryColorLight,
                                                      Theme.of(context)
                                                          .primaryColor
                                                    ],
                                                    strokeWidth: 2.0,
                                                    pathBackgroundColor: null),
                                              ),
                                            );
                                          } else {
                                            return SlidableListTile(
                                              index: index,
                                              doctors: doctors!,
                                              onDeleted: () {
                                                // _titles.removeAt(index);
                                                setState(() {});
                                              },
                                            );
                                            // return ListTile(
                                            //   title: Text(
                                            //       '$index ${doctors![index].firstName}'),
                                            // );
                                          }
                                        },
                                      ),
                              ],
                            ),
                          ),
                        )
                      ] else ...[
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: LoadingIndicator(
                              indicatorType: Indicator.ballRotateChase,
                              colors: [
                                Theme.of(context).primaryColorLight,
                                Theme.of(context).primaryColor
                              ],
                              strokeWidth: 2.0,
                              pathBackgroundColor: null),
                        )
                      ]
                    ]
                  ],
                ),
              ),
            ),
            secondChild: const Text(''),
            crossFadeState: !_isFinished
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 1000),
          )
        ]),
      )),
    );
  }
}

class DoctorsListWidget extends StatefulWidget {
  final Map<String, String> queryParameters;
  final Orientation orientation;
  final List<Doctors>? doctors;
  final int totalDoctors;
  final ScrollController scrollController;
  const DoctorsListWidget({
    super.key,
    required this.queryParameters,
    required this.doctors,
    required this.orientation,
    required this.totalDoctors,
    required this.scrollController,
  });

  @override
  State<DoctorsListWidget> createState() => _DoctorsListWidgetState();
}

class _DoctorsListWidgetState extends State<DoctorsListWidget>
    with TickerProviderStateMixin {
  late List<Doctors> doctors;
  late int totalDoctors;

// This is what you're looking for!
  void _scrollDown() {
    widget.scrollController.animateTo(
      widget.scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _scrollUp() {
    widget.scrollController.animateTo(
      widget.scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();
    doctors = widget.doctors!;
    totalDoctors = widget.totalDoctors;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.orientation == Orientation.landscape
          ? 150
          : MediaQuery.of(context).size.height / 2 + 150,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          ListView.builder(
            restorationId: 'doctorSearch',
            itemCount: doctors.length,
            controller: widget.scrollController,
            // padding: const EdgeInsets.only(bottom: 280),
            itemBuilder: (context, index) {
              return SlidableListTile(
                index: index,
                doctors: doctors,
                onDeleted: () {
                  // _titles.removeAt(index);
                  setState(() {});
                },
              );
            },
          ),
          if (doctors.length > 9) ...[
            Positioned(
              top: 0,
              right: 0,
              child: FloatingActionButton.small(
                heroTag: 'upward',
                onPressed: _scrollUp,
                child: const Icon(Icons.arrow_upward),
              ),
            ),
            Positioned(
              top: 42,
              right: 0,
              child: FloatingActionButton.small(
                backgroundColor: Theme.of(context).primaryColor,
                splashColor: Theme.of(context).primaryColorLight,
                heroTag: 'downward',
                onPressed: _scrollDown,
                child: const Icon(Icons.arrow_downward),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SlidableListTile extends StatefulWidget {
  final int index;
  final List<Doctors> doctors;
  final VoidCallback? onDeleted;
  const SlidableListTile({
    super.key,
    required this.doctors,
    required this.index,
    this.onDeleted,
  });

  @override
  State<SlidableListTile> createState() => _SlidableListTileState();
}

class _SlidableListTileState extends State<SlidableListTile>
    with TickerProviderStateMixin {
  final SlideController _slideController = SlideController(
    usePreActionController: true,
    usePostActionController: true,
  );

  @override
  void dispose() {
    _slideController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  var height = 230.0;
  bool isFavIconLoading = false;
  late final AnimationController _heartController = AnimationController(
    vsync: this,
    lowerBound: 0.75,
    upperBound: 1,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);
  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: 0.6, end: 1.2).animate(_heartController);

  void addDoctorToFav(Doctors doctor, String patientId) {
    var doctorId = doctor.id;
    setState(() {
      isFavIconLoading = true;
    });
    socket.emit('addDocToFav', {'doctorId': doctorId, 'patientId': patientId});
    socket.on('addDocToFavReturn', (dynamic msg) {
      if (msg['status'] != 200) {
        showModalBottomSheet(
          context: context,
          useSafeArea: true,
          isDismissible: true,
          showDragHandle: true,
          barrierColor: Theme.of(context).cardColor.withOpacity(0.8),
          constraints: BoxConstraints(
            maxHeight: double.infinity,
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height / 5,
          ),
          scrollControlDisabledMaxHeightRatio: 1,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                msg['message'],
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            );
          },
        ).whenComplete(
          () {
            _slideController.toggleAction(0);
            setState(
              () {
                isFavIconLoading = false;
              },
            );
          },
        );
      } else {
        doctor.favIds.add(patientId);
        setState(
          () {
            isFavIconLoading = false;
          },
        );
        _slideController.toggleAction(0);
      }
    });
  }

  void removeDoctorToFav(Doctors doctor, String patientId) {
    var doctorId = doctor.id;
    setState(() {
      isFavIconLoading = true;
    });
    socket.emit(
        'removeDocFromFav', {'doctorId': doctorId, 'patientId': patientId});
    socket.on('removeDocFromFavReturn', (dynamic msg) {
      if (msg['status'] != 200) {
        showModalBottomSheet(
          context: context,
          useSafeArea: true,
          isDismissible: true,
          showDragHandle: true,
          barrierColor: Theme.of(context).cardColor.withOpacity(0.8),
          constraints: BoxConstraints(
            maxHeight: double.infinity,
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height / 5,
          ),
          scrollControlDisabledMaxHeightRatio: 1,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                msg['message'],
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            );
          },
        ).whenComplete(
          () {
            _slideController.toggleAction(0);
            setState(
              () {
                isFavIconLoading = false;
              },
            );
          },
        );
      } else {
        doctor.favIds.remove(patientId);
        setState(
          () {
            isFavIconLoading = false;
          },
        );
        _slideController.toggleAction(0);
      }
    });
  }

  void showArrayDataModal(
      BuildContext context, String name, List<dynamic> data) {
    Widget children = Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(name),
        if (name == 'specialitiesServices') ...[
          Table(
            border: TableBorder(
              horizontalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              verticalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              bottom:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              top:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              left:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              right:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              ...[
                ...[
                  ...data.map((e) {
                    return TableRow(children: [
                      Center(
                        child: Text(
                          e,
                        ),
                      ),
                    ]);
                  }),
                ]
              ]
            ],
          )
        ] else if (name == 'educations') ...[
          Table(
            border: TableBorder(
              horizontalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              verticalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              bottom:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              top:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              left:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              right:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  SizedBox(
                    height: 32,
                    child: Center(
                      child: Text(
                        context.tr('collage'),
                      ),
                    ),
                  ),
                  TableCell(
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                        child: Text(
                          context.tr('degree'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: Center(
                      child: Text(
                        context.tr('yearOfCompletion'),
                      ),
                    ),
                  ),
                ],
              ),
              ...[
                ...[
                  ...data.map((e) {
                    var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                        .parseUTC('${e.yearOfCompletion}')
                        .toLocal();
                    String formattedDate = DateFormat("yyyy").format(dateValue);
                    return TableRow(children: [
                      Center(
                        child: Text(
                          e.collage,
                        ),
                      ),
                      Center(
                        child: Text(
                          e.degree,
                        ),
                      ),
                      Center(
                        child: Text(
                          formattedDate,
                        ),
                      ),
                    ]);
                  }),
                ]
              ]
            ],
          )
        ] else if (name == 'experinces') ...[
          Table(
            border: TableBorder(
              horizontalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              verticalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              bottom:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              top:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              left:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              right:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  SizedBox(
                    height: 32,
                    child: Center(
                      child: Text(
                        context.tr('designation'),
                      ),
                    ),
                  ),
                  TableCell(
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                        child: Text(
                          context.tr('hospitalName'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: Center(
                      child: Text(
                        context.tr('from'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: Center(
                      child: Text(
                        context.tr('to'),
                      ),
                    ),
                  ),
                ],
              ),
              ...[
                ...[
                  ...data.map((e) {
                    var fromDateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                        .parseUTC('${e.from}')
                        .toLocal();
                    String formattedFromDate =
                        DateFormat("yyyy MMM dd").format(fromDateValue);
                    var toDateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                        .parseUTC('${e.from}')
                        .toLocal();
                    String formattedToDate =
                        DateFormat("yyyy MMM dd").format(toDateValue);
                    return TableRow(children: [
                      Center(
                        child: Text(
                          e.designation,
                        ),
                      ),
                      Center(
                        child: Text(
                          e.hospitalName,
                        ),
                      ),
                      Center(
                        child: Text(
                          formattedFromDate,
                        ),
                      ),
                      Center(
                        child: Text(
                          formattedToDate,
                        ),
                      ),
                    ]);
                  }),
                ]
              ]
            ],
          )
        ] else if (name == 'awards') ...[
          Table(
            border: TableBorder(
              horizontalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              verticalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              bottom:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              top:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              left:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              right:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  SizedBox(
                    height: 32,
                    child: Center(
                      child: Text(
                        context.tr('award'),
                      ),
                    ),
                  ),
                  TableCell(
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                        child: Text(
                          context.tr('year'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ...[
                ...[
                  ...data.map((e) {
                    var yearValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                        .parseUTC('${e.year}')
                        .toLocal();
                    String formattedYearDate =
                        DateFormat("yyyy").format(yearValue);
                    return TableRow(children: [
                      Center(
                        child: Text(
                          e.award,
                        ),
                      ),
                      Center(
                        child: Text(
                          formattedYearDate,
                        ),
                      ),
                    ]);
                  }),
                ]
              ]
            ],
          )
        ] else if (name == 'memberships') ...[
          Table(
            border: TableBorder(
              horizontalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              verticalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              bottom:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              top:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              left:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              right:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              ...[
                ...[
                  ...data.map((e) {
                    return TableRow(children: [
                      Center(
                        child: Text(
                          e.membership,
                        ),
                      ),
                    ]);
                  }),
                ]
              ]
            ],
          )
        ] else if (name == 'registrations') ...[
          Table(
            border: TableBorder(
              horizontalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              verticalInside:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              bottom:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              top:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              left:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
              right:
                  BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  SizedBox(
                    height: 32,
                    child: Center(
                      child: Text(
                        context.tr('registration'),
                      ),
                    ),
                  ),
                  TableCell(
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                        child: Text(
                          context.tr('year'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ...[
                ...[
                  ...data.map((e) {
                    var yearValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                        .parseUTC('${e.year}')
                        .toLocal();
                    String formattedYearDate =
                        DateFormat("yyyy").format(yearValue);
                    return TableRow(children: [
                      Center(
                        child: Text(
                          e.registration,
                        ),
                      ),
                      Center(
                        child: Text(
                          formattedYearDate,
                        ),
                      ),
                    ]);
                  }),
                ]
              ]
            ],
          )
        ]
      ],
    );
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      showDragHandle: false,
      barrierColor: Theme.of(context).cardColor.withOpacity(0.8),
      constraints: BoxConstraints(
        maxHeight: double.infinity,
        minWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height / 5,
      ),
      scrollControlDisabledMaxHeightRatio: 1,
      builder: (context) {
        return Padding(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(child: children));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    var isLogin = Provider.of<AuthProvider>(context).isLogin;
    var patientProfile = Provider.of<AuthProvider>(context).patientProfile;
    var doctorsProfile = Provider.of<AuthProvider>(context).doctorsProfile;
    var roleName = Provider.of<AuthProvider>(context).roleName;
    var index = widget.index;
    var doctors = widget.doctors;
    final isCollapsed = ValueNotifier<bool>(true);
    Doctors singleDoctor = doctors[index];
    var subheading = context.tr(singleDoctor.specialities[0].specialities);
    final specialitiesImageSrc = singleDoctor.specialities[0].image;
    final imageIsSvg = specialitiesImageSrc.endsWith('.svg');
    final name = "${singleDoctor.firstName} ${singleDoctor.lastName}";
    bool isFave = false;
    String patientId = "";
    if (isLogin) {
      if (roleName == 'patient') {
        isFave = singleDoctor.favIds.contains(patientProfile?.userId);
        patientId = patientProfile!.userId;
      } else if (roleName == 'doctors') {
        isFave = singleDoctor.favIds.contains(doctorsProfile?.userId);
        patientId = patientProfile!.userId;
      }
    }
    final doctorId = singleDoctor.id;

    final doctorIdEncrypted = encrypter.encrypt(doctorId, iv: iv);

    return SlidablePanel(
        controller: _slideController,
        maxSlideThreshold: 0.5,
        axis: Axis.horizontal,
        preActionLayout: ActionLayout.spaceEvenly(ActionMotion.drawer),
        onSlideStart: () {
          // print("onSlideStart: $index");
        },
        preActions: [
          IconButton(
            onPressed: () {
              bool favOpen = _slideController.hasExpandedAt(0);
              if (!favOpen) {
                _slideController.toggleAction(0);
              } else {
                if (!isLogin) {
                  showModalBottomSheet(
                    context: context,
                    useSafeArea: true,
                    isDismissible: true,
                    showDragHandle: true,
                    barrierColor: Theme.of(context).cardColor.withOpacity(0.8),
                    constraints: BoxConstraints(
                      maxHeight: double.infinity,
                      minWidth: MediaQuery.of(context).size.width,
                      minHeight: MediaQuery.of(context).size.height / 5,
                    ),
                    scrollControlDisabledMaxHeightRatio: 1,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          context.tr('favLoginError'),
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      );
                    },
                  ).whenComplete(
                    () => _slideController.toggleAction(0),
                  );
                } else {
                  if (!isFave) {
                    addDoctorToFav(singleDoctor, patientId);
                  } else {
                    removeDoctorToFav(singleDoctor, patientId);
                  }
                }
              }
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.all(0),
              foregroundColor: isFave
                  ? Colors.pink[600]
                  : Theme.of(context).primaryColorLight,
              splashFactory: NoSplash.splashFactory,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            icon: isFavIconLoading
                ? SizedBox(
                    height: 30,
                    width: 30,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballRotateChase,
                      colors: [
                        Theme.of(context).primaryColorLight,
                        Colors.pink
                      ],
                      strokeWidth: 2.0,
                      pathBackgroundColor: null,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          isLogin
                              ? isFave
                                  ? Icons.favorite
                                  : Icons.favorite_border
                              : Icons.favorite_outline,
                        ),
                      ),
                      Text('${singleDoctor.favIds.length}')
                    ],
                  ),
          ),
          TextButton(
              onPressed: () async {
                _slideController.toggleAction(1);
                final result = await Share.share(
                    'check out my website http://web-mjcode.ddns.net/');
                if (result.status == ShareResultStatus.dismissed) {
                  _slideController.toggleAction(1);
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: Theme.of(context).primaryColorLight,
                shape: const RoundedRectangleBorder(),
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.share), Text('')],
              )),
        ],
        postActions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(18), right: Radius.circular(18)),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.thumb_up_sharp),
                    Text('98%'),
                    Text(
                      '(252 votes)',
                    )
                  ],
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.maxFinite, 30),
                    elevation: 5.0,
                    foregroundColor: Theme.of(context).primaryColor,
                    animationDuration: const Duration(milliseconds: 1000),
                    backgroundColor: Theme.of(context).primaryColorLight,
                    shadowColor: Theme.of(context).primaryColorLight,
                  ),
                  onPressed: singleDoctor.timeslots.isEmpty ? null : () {},
                  child: Text(
                    context.tr('bookAppointment'),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.maxFinite, 30),
                    elevation: 5.0,
                    foregroundColor: Theme.of(context).primaryColor,
                    animationDuration: const Duration(milliseconds: 1000),
                    backgroundColor: Theme.of(context).primaryColor,
                    shadowColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: singleDoctor.timeslots.isEmpty ? null : () {},
                  child: Text(
                    context.tr('onlineConsult'),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          )
        ],
        child: GestureDetector(
          onTap: () {
            _slideController.dismiss();
          },
          child: badges.Badge(
            stackFit: StackFit.passthrough,
            badgeContent: Text(
              (index + 1).toString(),
              style: const TextStyle(fontSize: 12),
            ),
            position: badges.BadgePosition.custom(start: 20, bottom: 10),
            badgeStyle: badges.BadgeStyle(
              badgeColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(3),
            ),
            child: AnimatedContainer(
              height: height,
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).primaryColorLight, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 5.0,
                  clipBehavior: Clip.hardEdge,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                flex: 2,
                                fit: FlexFit.tight,
                                child: badges.Badge(
                                  stackFit: StackFit.passthrough,
                                  position: badges.BadgePosition.custom(
                                    start: 4,
                                    top: 4,
                                  ),
                                  badgeContent: AvatarGlow(
                                    startDelay:
                                        const Duration(milliseconds: 1000),
                                    glowColor: singleDoctor.online
                                        ? Colors.green
                                        : Colors.transparent,
                                    glowShape: BoxShape.circle,
                                    animate: singleDoctor.online,
                                    repeat: singleDoctor.online,
                                    curve: Curves.fastOutSlowIn,
                                    child: Material(
                                      elevation: 8.0,
                                      shape: const CircleBorder(),
                                      color: Colors.transparent,
                                      child: Icon(
                                        singleDoctor.online
                                            ? Icons.check
                                            : Icons.close,
                                        color: Colors.white,
                                        size: 7,
                                      ),
                                    ),
                                  ),
                                  badgeStyle: badges.BadgeStyle(
                                    padding: const EdgeInsets.all(1),
                                    shape: badges.BadgeShape.circle,
                                    badgeColor: singleDoctor.online
                                        ? Colors.green
                                        : Colors.pink,
                                    elevation: 12,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.pushNamed(
                                        'doctorsProfile',
                                        pathParameters: {
                                          'id': Uri.encodeComponent(
                                              doctorIdEncrypted.base64)
                                        },
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(8),
                                        ),
                                        image: DecorationImage(
                                          image:
                                              singleDoctor.profileImage.isEmpty
                                                  ? const AssetImage(
                                                      'assets/images/default-avatar.png',
                                                    ) as ImageProvider
                                                  : CachedNetworkImageProvider(
                                                      singleDoctor.profileImage,
                                                    ),
                                          fit: BoxFit.cover,
                                        ),

                                        // your own shape
                                        shape: BoxShape.rectangle,
                                      ),
                                      height: 90,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 3,
                                fit: FlexFit.tight,
                                child: SizedBox(
                                  height: 80,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Dr. $name",
                                              style: TextStyle(
                                                color: brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  context.pushNamed(
                                                    'doctorsProfile',
                                                    pathParameters: {
                                                      'id': Uri.encodeComponent(
                                                          doctorIdEncrypted
                                                              .base64)
                                                    },
                                                  );
                                                },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(subheading),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: imageIsSvg
                                                ? SvgPicture.network(
                                                    specialitiesImageSrc, //?random=${DateTime.now().millisecondsSinceEpoch}
                                                    width: 20,
                                                    height: 20,
                                                    fit: BoxFit.fitHeight,
                                                  )
                                                : CachedNetworkImage(
                                                    key: ValueKey(
                                                      specialitiesImageSrc,
                                                    ),
                                                    width: 20,
                                                    height: 20,
                                                    imageUrl:
                                                        specialitiesImageSrc,
                                                    errorWidget:
                                                        (ccontext, url, error) {
                                                      return Image.asset(
                                                        'assets/images/default-avatar.png',
                                                      );
                                                    },
                                                  ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                fit: FlexFit.tight,
                                child: SizedBox(
                                    height: 80,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        RatingStars(
                                          value: 3.5,
                                          onValueChanged: (v) {},
                                          starCount: 5,
                                          starSize: 10,
                                          valueLabelVisibility: false,
                                          maxValue: 5,
                                          starSpacing: 2,
                                          maxValueVisibility: true,
                                          animationDuration: const Duration(
                                              milliseconds: 1000),
                                          starOffColor: const Color(0xffe7e8ea),
                                          starColor: Colors.yellow,
                                        ),
                                        Text(
                                          'Gender: ${singleDoctor.gender == 'Mr' ? '👨' : '👩'} ${singleDoctor.gender}',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                        if (singleDoctor
                                            .clinicImages.isNotEmpty) ...[
                                          CarouselSlider(
                                              options: CarouselOptions(
                                                height: 50.0,
                                                autoPlay: true,
                                                enlargeCenterPage: true,
                                              ),
                                              items: singleDoctor.clinicImages
                                                  .map((i) {
                                                return Card(
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColorLight,
                                                        width: 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  elevation: 5.0,
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Image.network(
                                                    semanticLabel:
                                                        i.tags[0].title,
                                                    fit: BoxFit.cover,
                                                    i.src,
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                                );
                                              }).toList())
                                        ]else ...[const SizedBox(height: 30,)]
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                            color: Theme.of(context).primaryColor,
                            indent: 0,
                            endIndent: 0,
                            height: 5),
                        IntrinsicHeight(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 12,
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        singleDoctor.city,
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        singleDoctor.state,
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        singleDoctor.country,
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                VerticalDivider(
                                  width: 3,
                                  thickness: 1,
                                  indent: 0,
                                  endIndent: 0,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          context.tr('about'),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: isCollapsed,
                                        builder: (context, value, child) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    style: TextStyle(
                                                      color: brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                    text: singleDoctor.aboutMe
                                                                .length <=
                                                            100
                                                        ? singleDoctor.aboutMe
                                                        : singleDoctor.aboutMe
                                                            .substring(0, 100),
                                                  ),
                                                  if (singleDoctor
                                                          .aboutMe.length >=
                                                      100) ...[
                                                    TextSpan(
                                                        text: value
                                                            ? context
                                                                .tr('readMore')
                                                            : context
                                                                .tr('readLess'),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () {
                                                                isCollapsed
                                                                        .value =
                                                                    !isCollapsed
                                                                        .value;
                                                                showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  useSafeArea:
                                                                      true,
                                                                  isDismissible:
                                                                      true,
                                                                  showDragHandle:
                                                                      true,
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                    maxHeight:
                                                                        double
                                                                            .infinity,
                                                                  ),
                                                                  scrollControlDisabledMaxHeightRatio:
                                                                      1,
                                                                  builder:
                                                                      (context) {
                                                                    return Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      child:
                                                                          Text(
                                                                        singleDoctor
                                                                            .aboutMe,
                                                                        textAlign:
                                                                            TextAlign.justify,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              18.0,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).whenComplete(
                                                                    () {
                                                                  isCollapsed
                                                                          .value =
                                                                      !isCollapsed
                                                                          .value;
                                                                });
                                                              })
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                        ),
                        Divider(
                          color: Theme.of(context).primaryColor,
                          indent: 0,
                          endIndent: 0,
                          height: 1,
                        ),
                        if (height == 230) ...[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                visualDensity: const VisualDensity(
                                    horizontal: -4, vertical: -4),
                                onPressed: () {
                                  setState(() {
                                    height = 280.0;
                                  });
                                },
                                icon: const Icon(Icons.arrow_drop_down),
                              )
                            ],
                          )
                        ] else ...[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                visualDensity: const VisualDensity(
                                    horizontal: -4, vertical: -4),
                                onPressed: () {
                                  setState(() {
                                    height = 230.0;
                                  });
                                },
                                icon: const Icon(Icons.arrow_drop_up),
                              )
                            ],
                          ),
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 200),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showArrayDataModal(
                                          context,
                                          'specialitiesServices',
                                          singleDoctor.specialitiesServices,
                                        );
                                      },
                                      child: Chip(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        visualDensity: const VisualDensity(
                                            horizontal: 4, vertical: -3),
                                        padding: const EdgeInsets.all(0),
                                        label: Text(context.tr('services')),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showArrayDataModal(
                                          context,
                                          'educations',
                                          singleDoctor.educations,
                                        );
                                      },
                                      child: Chip(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        visualDensity: const VisualDensity(
                                            horizontal: 4, vertical: -3),
                                        padding: const EdgeInsets.all(0),
                                        label: Text(context.tr('educations')),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showArrayDataModal(
                                          context,
                                          'experinces',
                                          singleDoctor.experinces,
                                        );
                                      },
                                      child: Chip(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        visualDensity: const VisualDensity(
                                            horizontal: 4, vertical: -3),
                                        padding: const EdgeInsets.all(0),
                                        label: Text(context.tr('experinces')),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showArrayDataModal(
                                          context,
                                          'awards',
                                          singleDoctor.awards,
                                        );
                                      },
                                      child: Chip(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        visualDensity: const VisualDensity(
                                            horizontal: 4, vertical: -3),
                                        padding: const EdgeInsets.all(0),
                                        label: Text(context.tr('awards')),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showArrayDataModal(
                                          context,
                                          'memberships',
                                          singleDoctor.memberships,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Chip(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColorLight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          visualDensity: const VisualDensity(
                                              horizontal: 4, vertical: -3),
                                          padding: const EdgeInsets.all(0),
                                          label:
                                              Text(context.tr('memberships')),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showArrayDataModal(
                                          context,
                                          'registrations',
                                          singleDoctor.registrations,
                                        );
                                      },
                                      child: Chip(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        visualDensity: const VisualDensity(
                                            horizontal: 4, vertical: -3),
                                        padding: const EdgeInsets.all(0),
                                        label:
                                            Text(context.tr('registrations')),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

class KeyWordWidget extends StatelessWidget {
  final TextEditingController keyWordController;
  final Map<String, dynamic> localQueryParams;
  const KeyWordWidget({
    super.key,
    required this.keyWordController,
    required this.localQueryParams,
  });

  @override
  Widget build(BuildContext context) {
    void onChange(value) {
      keyWordController.text = value;
      localQueryParams.remove('keyWord');
      Map<String, String> searchFilters = {
        ...localQueryParams,
        ...keyWordController.text.isNotEmpty
            ? {"keyWord": keyWordController.text}
            : {},
      };
      context.replace(
        Uri(
          path: '/doctors/search',
          queryParameters: searchFilters,
        ).toString(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        controller: keyWordController,
        keyboardType: TextInputType.text,
        onChanged: (value) {
          onChange(value);
        },
        decoration: InputDecoration(
          suffixIcon: keyWordController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    onChange('');
                  },
                  icon: const Icon(Icons.close)),
          suffixIconColor: Theme.of(context).primaryColor,
          contentPadding: const EdgeInsets.all(8),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          label: Text(context.tr('keyWord')),
          labelStyle: const TextStyle(
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;

    final primaryLightColorCode = primaryLightColorCodeReturn(homeThemeName);
    final primaryDarkColorCode = primaryDarkColorCodeReturn(homeThemeName);
    final secondaryLightColorCode =
        secondaryLightColorCodeReturn(homeThemeName);
    final secondaryDarkColorCode = secondaryDarkColorCodeReturn(homeThemeName);
    var brightness = Theme.of(context).brightness;
    return Lottie.asset("assets/images/emptyResult.json",
        animate: true,
        delegates: LottieDelegates(values: [
          ValueDelegate.strokeColor(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['line', 'Shape 1', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.strokeColor(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['line', 'Shape 2', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.strokeColor(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['line', 'Shape 3', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'line', '**'],
            value: Colors.amber,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'hand', '1', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 13', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 17', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 20', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 22', '**'],
            value: Theme.of(context).primaryColor,
          ),

          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 23', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 26', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 27', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 28', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 29', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 30', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 31', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 32', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 34', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 35', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 36', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 39', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 44', 'Fill 1'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          //  ValueDelegate.opacity(
          //   const ['**', 'Group 44', '**'],
          //   value: 0,
          // ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 49', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 52', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 54', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 55', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 56', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 57', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 58', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 59', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 60', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 61', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 62', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 63', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 64', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 65', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 66', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 67', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 68', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 69', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 70', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 71', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 72', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 73', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 74', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 75', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 76', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 77', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 78', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 79', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 80', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 81', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 82', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 83', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 84', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 85', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 86', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 87', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 88', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 89', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 90', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 91', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 92', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 93', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 94', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 95', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 96', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 97', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 98', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 99', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 100', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 101', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 102', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 103', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 104', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 105', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 106', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 107', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 108', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 109', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 110', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 111', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 112', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 113', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 114', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 115', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 116', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 117', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 118', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 119', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 120', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 121', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 122', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 123', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 124', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 125', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 126', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 127', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 128', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 129', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 130', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 131', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 132', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 133', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 134', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 135', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 136', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 137', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 138', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 139', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 140', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 141', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 142', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 143', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 144', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 145', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 146', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 147', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 148', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 149', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 150', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 151', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 152', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 153', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 154', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 155', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 156', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 157', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 158', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 159', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 160', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 161', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 163', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 165', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 168', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 171', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 174', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 176', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
// Color.fromARGB(255, 255, 0, 212)
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 275', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 278', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 285', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 289', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 294', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 299', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 303', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 304', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 305', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 306', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 311', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 314', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 316', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 317', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 318', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 319', '**'],
            value: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 321', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 324', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 326', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 328', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 330', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 333', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 334', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 335', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 338', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 339', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 342', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 343', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 345', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 346', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 349', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 350', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 351', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 352', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 354', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 357', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 358', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 359', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 360', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 362', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 363', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 364', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 365', '**'],
            value: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 367', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 370', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 372', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 373', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 374', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 376', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 378', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 379', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 380', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 381', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 386', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 387', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 388', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 389', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 391', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 392', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 393', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 397', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 398', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 399', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 400', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 401', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 403', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 404', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 405', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 406', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 408', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 409', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 410', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 411', '**'],
            value: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 413', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 416', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 422', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 423', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 426', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 427', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 428', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 434', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 435', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 436', '**'],
            value: hexToColor(primaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 437', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 438', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 441', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 442', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 446', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 448', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 449', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 450', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 451', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 452', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 453', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 454', '**'],
            value: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 455', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 456', '**'],
            value: Theme.of(context).primaryColorLight,
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 457', '**'],
            value: Theme.of(context).primaryColor,
          ),
          ValueDelegate.color(
              // keyPath order: ['layer name', 'group name', 'shape name']
              const ['**', 'Group 458', '**'],
              value: hexToColor(secondaryDarkColorCode)),
          ValueDelegate.color(
              // keyPath order: ['layer name', 'group name', 'shape name']
              const ['**', 'Group 460', '**'],
              value: Theme.of(context).primaryColorLight),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 462', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
              // keyPath order: ['layer name', 'group name', 'shape name']
              const ['**', 'Group 467', '**'],
              value: Theme.of(context).primaryColor),
          ValueDelegate.color(
              // keyPath order: ['layer name', 'group name', 'shape name']
              const ['**', 'Group 479', '**'],
              value: Theme.of(context).canvasColor),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 480', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 482', '**'],
            value: hexToColor(secondaryLightColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 485', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 487', '**'],
            value: hexToColor(secondaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 488', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 489', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 490', '**'],
            value: hexToColor(primaryDarkColorCode),
          ),
          ValueDelegate.color(
            // keyPath order: ['layer name', 'group name', 'shape name']
            const ['**', 'Group 491', '**'],
            value: Colors.grey,
          ),
          ValueDelegate.color(
              // keyPath order: ['layer name', 'group name', 'shape name']
              const ['**', 'Group 492', '**'],
              value: Theme.of(context).canvasColor),
        ]));
  }
}
