
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/filter_screen.dart';
import 'package:health_care/src/features/doctors/search/doctor_slideable_widget.dart';
import 'package:health_care/src/features/doctors/search/key_word_widget.dart';
import 'package:health_care/src/features/doctors/search/no_data_widget.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/doctors.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/services/user_data_service.dart';
import 'package:health_care/src/commons/packages/swipeable_button_view.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
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
          child: Column(
            children: [
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
                                        color:
                                            Theme.of(context).primaryColorLight,
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
                                                ? {
                                                    "available":
                                                        element['search']
                                                  }
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
                                        color:
                                            Theme.of(context).primaryColorLight,
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
                            Future.delayed(const Duration(microseconds: 300),
                                () {
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
                                    subtitle:
                                        const Text('doctorsNumber').plural(
                                      (totalDoctors ?? 0) as num,
                                      format: NumberFormat.compact(
                                        locale: context.locale.toString(),
                                      ),
                                    ),
                                  ),
                                ),
                                if(doctors != null && doctors!.isNotEmpty) ...[IconButton(
                                  onPressed: scrollUp,
                                  icon: Icon(
                                    Icons.arrow_upward,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),],
                                if(doctors != null && doctors!.isNotEmpty) ...[IconButton(
                                  onPressed: scrollDown,
                                  icon: const Icon(Icons.arrow_downward),
                                ),],
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: ListTile(
                                      textColor: brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      subtitle:
                                          Text(context.tr('slideToSeeMore'))),
                                ),
                              ],
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height / 2 +
                                    200,
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
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              if (index + 1 ==
                                                      doctors!.length &&
                                                  doctors!.length <
                                                      totalDoctors!) {
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
                                                        pathBackgroundColor:
                                                            null),
                                                  ),
                                                );
                                              } else {
                                                return DoctorSlideableWidget(
                                                  index: index,
                                                  doctors: doctors!,
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
            ],
          ),
        ),
      ),
    );
  }
}
