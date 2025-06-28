import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/filter_screen.dart';
import 'package:health_care/src/commons/packages/swipeable_button_view.dart';
import 'package:health_care/src/features/doctors/search/searchWidgets/available_select_widget.dart';
import 'package:health_care/src/features/doctors/search/searchWidgets/filter_show_text_widget.dart';
import 'package:health_care/src/features/doctors/search/searchWidgets/key_word_widget.dart';
import 'package:health_care/src/features/doctors/search/searchWidgets/reset_filter_widget.dart';
// import 'package:health_care/src/features/doctors/search/searchWidgets/sort_by_selcet_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:session_storage/session_storage.dart';

class FilterBoxWidget extends StatefulWidget {
  final Map<String, String> queryParameters;
  final DoctorsProvider doctorsProvider;
  final void Function(bool) updateIsFinished;
  final void Function(String) updateSortBy;
  const FilterBoxWidget({
    super.key,
    required this.queryParameters,
    required this.doctorsProvider,
    required this.updateIsFinished,
    required this.updateSortBy,
  });

  @override
  State<FilterBoxWidget> createState() => _FilterBoxWidgetState();
}

class _FilterBoxWidgetState extends State<FilterBoxWidget> {
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  late List<Map<String, dynamic>> availabilityValues;
  late List<Map<String, dynamic>> sortByValues;
  final keyWordController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final session = SessionStorage();
  bool _isFinished = false;
  int perPage = 10;
  int page = 1;
  static late String _chosenModel;
  // static late String _sortByModel;
  String? specialitiesValue;
  String? genderValue;
  String? countryValue;
  String? stateValue;
  String? cityValue;
  String? keyWordValue;
  String? availabilityValue;
  String sortBy = 'profile.userName';

  @override
  void dispose() {
    keyWordController.dispose();
    scrollController.dispose();
    specialitiesValue = null;
    genderValue = null;
    countryValue = null;
    stateValue = null;
    cityValue = null;
    keyWordValue = null;
    availabilityValue = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      availabilityValues = [
        {"value": context.tr('availability'), "search": null},
        {"value": context.tr('available'), "search": "Available"},
        {"value": context.tr('today'), "search": "AvailableToday"},
        {"value": context.tr('tomorrow'), "search": "AvailableTomorrow"},
        {"value": context.tr('thisWeek'), "search": "AvailableThisWeek"},
        {"value": context.tr('thisMonth'), "search": "AvailableThisMonth"},
      ];
      // sortByValues = [
      //   {"value": context.tr('userName'), 'search': 'profile.userName'},
      //   {"value": context.tr('joinDate'), 'search': 'createdAt'},
      // ];

      // for (var element in sortByValues) {
      //   if (element['search'] == sortBy) {
      //     _sortByModel = element['value'];
      //   }
      // }
      for (var element in availabilityValues) {
        if (element['search'] == widget.queryParameters['available']) {
          _chosenModel = element['value'];
        }
      }
      _isProvidersInitialized = true;
    }
  }

  void updateFilterState(String? specialities, String? gender, String? country, String? state, String? city, String? keyWord, String? availability,
      Map<String, dynamic> localQueryParams) {
    setState(() {
      specialitiesValue = specialities;
      genderValue = gender;
      countryValue = country;
      stateValue = state;
      cityValue = city;
      keyWordValue = keyWord;
      availabilityValue = availability;
    });
    localQueryParams.removeWhere((k, v) => k == 'specialities' || k == 'gender' || k == 'country' || k == 'state' || k == 'city');
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
    // getDataOnUpdate();
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
      _chosenModel = context.tr('availability');
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

  void onAvaliablityChange(String? newValue, Map<String, String> localQueryParams) {
    // widget.doctorsProvider.setLoading(true);
    setState(() {
      _chosenModel = newValue!;
    });
    for (var element in availabilityValues) {
      if (element['value'] == newValue) {
        localQueryParams.remove('available');
        availabilityValue = element['search'];
        Map<String, String> searchFilters = {
          ...localQueryParams,
          ...element['search'] != null ? {"available": element['search']} : {},
        };
        context.replace(
          Uri(
            path: '/doctors/search',
            queryParameters: searchFilters,
          ).toString(),
        );
      }
    }
  }

  // void onSortByChange(String? newValue, Map<String, String> localQueryParams) {
  //   _sortByModel = newValue!;
  //   // widget.doctorsProvider.setLoading(true);
  //   for (var element in sortByValues) {
  //     if (element['value'] == newValue) {
  //       setState(() {
  //         sortBy = element['search'];
  //       });
  //       widget.updateSortBy(element['search']);
  //       context.replace(
  //         Uri(
  //           path: '/doctors/search',
  //           queryParameters: localQueryParams,
  //         ).toString(),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Padding(
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
              localQueryParams: widget.queryParameters,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  AvailableSelectWidget(
                    textColor: textColor,
                    chosenModel: _chosenModel,
                    availabilityValues: availabilityValues,
                    localQueryParams: widget.queryParameters,
                    onAvaliablityChange: onAvaliablityChange,
                  ),
                  // const SizedBox(width: 5),
                  // SortBySelcetWidget(
                  //   textColor: textColor,
                  //   sortByModel: _sortByModel,
                  //   sortByValues: sortByValues,
                  //   localQueryParams: widget.queryParameters,
                  //   onSortByChange: onSortByChange,
                  // )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SwipeableButtonView(
                indicatorColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
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
                            widget.queryParameters,
                          );
                        },
                        onReset: () {
                          resetFilterState(widget.queryParameters);
                        },
                      ),
                      type: PageTransitionType.fade,
                    ),
                  );

                  setState(() {
                    _isFinished = false;
                  });
                  widget.updateIsFinished(false);
                },
                onWaitingProcess: () {
                  Future.delayed(const Duration(microseconds: 300), () {
                    setState(() {
                      _isFinished = true;
                    });
                    widget.updateIsFinished(true);
                  });
                },
                activeColor: Theme.of(context).primaryColor,
                buttonColor: Theme.of(context).cardColor,
                buttonWidget: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: textColor,
                ),
                buttonText: context.tr('filters'),
                buttontextstyle: const TextStyle(color: Colors.black),
              ),
            ),
            if (widget.queryParameters.entries.isNotEmpty) ...[
              ResetFilterWidget(
                isFinished: _isFinished,
                localQueryParams: widget.queryParameters,
                resetFilterState: resetFilterState,
              ),
            ],
            FilterShowTextWidget(
              isFinished: _isFinished,
              genderValue: genderValue,
              availabilityValue: availabilityValue,
              specialitiesValue: specialitiesValue,
              keyWordController: keyWordController,
              countryValue: countryValue,
              stateValue: stateValue,
              cityValue: cityValue,
            ),
          ],
        ),
      ),
    );
  }
}
