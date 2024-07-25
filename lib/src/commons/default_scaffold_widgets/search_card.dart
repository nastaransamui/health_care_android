import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/filter_screen.dart';
import 'package:health_care/src/commons/packages/swipeable_button_view.dart';
import 'package:page_transition/page_transition.dart';

class SearchCard extends StatefulWidget {
  final String? genderValue;
  final String? specialitiesValue;
  final String? countryValue;
  final String? stateValue;
  final String? cityValue;
  final Function updateFilterState;
  final Function resetFilterState;
  const SearchCard({
    super.key,
    required this.genderValue,
    required this.specialitiesValue,
    required this.countryValue,
    required this.stateValue,
    required this.cityValue,
    required this.updateFilterState,
    required this.resetFilterState,
  });

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  static late String _chosenModel;
  late List<Map<String, dynamic>> availabilityValues;
  String? availabilityValue;
  final keyWordController = TextEditingController();
  String keyWordValue = '';
  bool selected = false;
  bool _isFinished = false;
  double paddingTop = 15;

  @override
  void didChangeDependencies() {
    context.locale.toString(); // OK
    super.didChangeDependencies();
  }

  void updatePadding(double value) {
    if (mounted) {
      setState(() {
        paddingTop = value;
      });
    }
  }

  @override
  void dispose() {
    keyWordController.dispose();
    super.dispose(); // Always call super.dispose() at the end.
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    List<Map<String, dynamic>> availabilityValues = [
      {"value": context.tr('availability'), "search": null},
      {"value": context.tr('available'), "search": "Available"},
      {"value": context.tr('today'), "search": "AvailableToday"},
      {"value": context.tr('tomorrow'), "search": "AvailableTomorrow"},
      {"value": context.tr('thisWeek'), "search": "AvailableThisWeek"},
      {"value": context.tr('thisMonth'), "search": "AvailableThisMonth"},
    ];
    for (var element in availabilityValues) {
      if (element['search'] == availabilityValue) {
        _chosenModel = element['value'];
      }
    }

    bool isFiltersHaveValue = keyWordValue != '' ||
        widget.genderValue != null ||
        widget.specialitiesValue != null ||
        widget.countryValue != null ||
        widget.stateValue != null ||
        widget.cityValue != null ||
        availabilityValue != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).primaryColorLight),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AnimatedPadding(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(top: paddingTop),
                child: Text(context.tr('filterSelection')),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 500),
                padding: EdgeInsets.only(top: paddingTop, left: 18, right: 18),
                child: TextField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (mounted) {
                      setState(() {
                        if (isFiltersHaveValue) {
                          paddingTop = 6;
                        } else {
                          paddingTop = 15;
                        }
                      });
                    }
                  },
                  controller: keyWordController,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    keyWordController.text = value;
                    if (mounted) {
                      setState(() {
                        keyWordValue = value;
                        if (isFiltersHaveValue && value != '') {
                          paddingTop = 6;
                        } else {
                          paddingTop = 15;
                        }
                      });
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    prefixIconColor: Theme.of(context).primaryColor,
                    suffixIcon: keyWordController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              keyWordController.text = '';
                              if (mounted) {
                                setState(() {
                                  keyWordValue = '';
                                  if (widget.genderValue != null ||
                                      widget.specialitiesValue != null ||
                                      widget.countryValue != null ||
                                      widget.stateValue != null ||
                                      widget.cityValue != null ||
                                      availabilityValue != null) {
                                    paddingTop = 6;
                                  } else {
                                    paddingTop = 15;
                                  }
                                });
                              }
                            },
                            icon: const Icon(Icons.close)),
                    suffixIconColor: Theme.of(context).primaryColorLight,
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
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 500),
                padding: EdgeInsets.only(top: paddingTop, left: 18, right: 18),
                child: InputDecorator(
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(
                      Icons.event_available,
                      size: 19,
                    ),
                    prefixIconColor: Theme.of(context).primaryColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    enabledBorder: OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                        width: 1,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      iconEnabledColor: Theme.of(context).primaryColorLight,
                      style: const TextStyle(
                        fontSize: 12.0,
                      ),
                      isExpanded: true,
                      value: _chosenModel,
                      items: availabilityValues.map<DropdownMenuItem<String>>((Map<String, dynamic> values) {
                        return DropdownMenuItem<String>(
                          value: values['value'],
                          child: Text(
                            values['value']!,
                            style: TextStyle(
                              color: brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (mounted) {
                          setState(() {
                            _chosenModel = newValue!;
                            for (var element in availabilityValues) {
                              if (element['value'] == newValue) {
                                availabilityValue = element['search'];
                                if (keyWordValue != '' ||
                                    widget.genderValue != null ||
                                    widget.specialitiesValue != null ||
                                    widget.countryValue != null ||
                                    widget.stateValue != null ||
                                    widget.cityValue != null ||
                                    element['search'] != null) {
                                  paddingTop = 6;
                                } else {
                                  paddingTop = 15;
                                }
                              }
                            }
                          });
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
              AnimatedPadding(
                duration: const Duration(milliseconds: 500),
                padding: EdgeInsets.only(top: paddingTop, right: 10, left: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.maxFinite, 30),
                    elevation: 5.0,
                  ),
                  onPressed: () {
                    Map<String, String> searchFilters = {
                      ...widget.cityValue != null ? {"city": widget.cityValue!} : {},
                      ...widget.stateValue != null ? {"state": widget.stateValue!} : {},
                      ...widget.countryValue != null ? {"country": widget.countryValue!} : {},
                      ...widget.specialitiesValue != null ? {"specialities": widget.specialitiesValue!} : {},
                      ...widget.genderValue != null ? {"gender": widget.genderValue!} : {},
                      ...keyWordController.text.isNotEmpty ? {"keyWord": keyWordController.text} : {},
                      ...availabilityValue != null ? {"available": availabilityValue!} : {}
                    };
                    context.push(
                      Uri(path: '/doctors/search', queryParameters: searchFilters).toString(),
                    );
                  },
                  child: Text(
                    context.tr('searchNow'),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 500),
                padding: EdgeInsets.only(top: paddingTop, right: 10, left: 10),
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
                            specialitiesValue: widget.specialitiesValue,
                            genderValue: widget.genderValue,
                            countryValue: widget.countryValue,
                            stateValue: widget.stateValue,
                            cityValue: widget.cityValue,
                            onSubmit: (
                              String? specialities,
                              String? gender,
                              String? country,
                              String? state,
                              String? city,
                            ) {
                              if (mounted) {
                                setState(() {
                                  if (specialities != null || gender != null || country != null || state != null || city != null) {
                                    paddingTop = 6;
                                  } else {
                                    paddingTop = 15;
                                  }
                                });
                              }
                              widget.updateFilterState(specialities, gender, country, state, city);
                            },
                            onReset: () {
                              keyWordController.text = '';
                              if (mounted) {
                                setState(() {
                                  keyWordValue = '';
                                  availabilityValue = null;
                                  paddingTop = 15;
                                });
                              }
                              widget.resetFilterState();
                            }),
                        type: PageTransitionType.fade,
                      ),
                    );
          
                    if (mounted) {
                      setState(() {
                        _isFinished = false;
                      });
                    }
                  },
                  onWaitingProcess: () {
                    Future.delayed(const Duration(microseconds: 300), () {
                      if (mounted) {
                        setState(() {
                          _isFinished = true;
                        });
                      }
                    });
                  },
                  activeColor: Theme.of(context).primaryColorLight,
                  buttonColor: Theme.of(context).cardColor,
                  buttonWidget: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                  buttonText: context.tr('filters'),
                  buttontextstyle: const TextStyle(color: Colors.black),
                ),
              ),
              AnimatedCrossFade(
                crossFadeState: !_isFinished ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 1000),
                firstChild: Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 11,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '$keyWordValue ${availabilityValue == null ? '' : _chosenModel} ${widget.genderValue ?? ''}  ${widget.specialitiesValue ?? ''}\n${widget.countryValue ?? ''} ${widget.stateValue ?? ''} ${widget.cityValue ?? ''}',
                        ),
                      ),
                    ),
                    if (isFiltersHaveValue) ...[
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.all(0),
                            splashFactory: NoSplash.splashFactory,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          onPressed: () {
                            widget.resetFilterState();
                            keyWordController.text = '';
                            if (mounted) {
                              setState(() {
                                keyWordValue = '';
                                availabilityValue = null;
                                paddingTop = 15;
                              });
                            }
                          },
                          icon: const Icon(Icons.close),
                        ),
                      )
                    ]
                  ],
                ),
                secondChild: const Text(''),
              )
            ],
          ),
        ),
      ),
    );
  }
}
