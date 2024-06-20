

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/cities.dart';
import 'package:health_care/models/countries.dart';
import 'package:health_care/models/states.dart';
import 'package:health_care/stream_socket.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';

import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/specialities.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/services/specialities_service.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/end_drawer.dart';
import 'package:health_care/src/commons/start_drawer.dart';
import 'package:health_care/src/commons/packages/swipeable_button_view.dart';

class SilverScaffoldWrapper extends StatefulWidget {
  final Widget children;
  final String title;

  const SilverScaffoldWrapper({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  State<SilverScaffoldWrapper> createState() => _SilverScaffoldWrapperState();
}

class _SilverScaffoldWrapperState extends State<SilverScaffoldWrapper> {
  final _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      drawer: const StartDrawer(),
      endDrawer: const EndDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              floating: true,
              delegate: CustomSilverAppBar(
                title: widget.title,
                expandedHeight: expandedHeight,
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: widget.children,
              // child: Container(
              //   margin: const EdgeInsets.only(top: kToolbarHeight),
              //   child: widget.children,
              // ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(showLogin: true),
    );
  }
}

class CustomSilverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final bool hideTitleWhenExpanded;
  final String title;
  CustomSilverAppBar({
    required this.expandedHeight,
    required this.title,
    this.hideTitleWhenExpanded = false,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = expandedHeight - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;

    return SizedBox(
      height: expandedHeight + expandedHeight / 2,
      child: Stack(
        children: <Widget>[
          SizedBox(
            height: overlapsContent
                ? kToolbarHeight
                : appBarSize < kToolbarHeight
                    ? kToolbarHeight
                    : appBarSize,
            child: AppBar(
              leading: Builder(builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(
                    Icons.menu,
                    size: 32,
                  ),
                );
              }),
              elevation: 10,
              title: AnimatedCrossFade(
                crossFadeState: percent == 0
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 400),
                firstChild: Text(
                  context.tr(title),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.black),
                ),
                secondChild: Text(
                  context.tr('appTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.black),
                ),
              ),
              actions: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                      icon: const Icon(
                        Icons.notifications,
                        size: 32,
                      ),
                      tooltip: 'More',
                    );
                  },
                ),
                PopupMenuButton<int>(
                  icon: const Icon(
                    Icons.language,
                    size: 32,
                    // color: hexToColor('#76ff02'),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/lang/en.png"),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('English'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/lang/th.png"),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Thai'),
                        ],
                      ),
                    )
                  ],
                  elevation: 4,
                  onSelected: (value) {
                    if (value == 1) {
                      context.setLocale(const Locale("en", 'US'));
                    } else if (value == 2) {
                      context.setLocale(const Locale("th", "TH"));
                    }
                  },
                ),
              ],
            ),
          ),
          //Prevent finddoctor card to ovelap header buttons
          percent == 0 || overlapsContent
              ? const SizedBox(
                  height: 100,
                )
              : FindDoctorsCard(
                  expandedHeight: expandedHeight,
                  shrinkOffset: shrinkOffset,
                  percent: percent,
                ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight + expandedHeight / 2;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class FindDoctorsCard extends StatefulWidget {
  final double expandedHeight;
  final double shrinkOffset;
  final double percent;
  const FindDoctorsCard({
    super.key,
    required this.expandedHeight,
    required this.shrinkOffset,
    required this.percent,
  });

  @override
  State<FindDoctorsCard> createState() => _FindDoctorsCardState();
}

class _FindDoctorsCardState extends State<FindDoctorsCard> {
  var height = 200.0;

  String? specialitiesValue;
  String? genderValue;
  String? countryValue;
  String? stateValue;
  String? cityValue;

  void updateFilterState(
    String? specialities,
    String? gender,
    String? country,
    String? state,
    String? city,
  ) {
    setState(() {
      specialitiesValue = specialities;
      genderValue = gender;
      countryValue = country;
      stateValue = state;
      cityValue = city;
    });
  }

  void resetFilterState() {
    setState(() {
      specialitiesValue = null;
      genderValue = null;
      countryValue = null;
      stateValue = null;
      cityValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardTopPosition = widget.expandedHeight / 2 - widget.shrinkOffset;
    return Positioned(
      left: 0.0,
      right: 0.0,
      top: cardTopPosition > 0 ? cardTopPosition - 70 : 0,
      bottom: 0,
      child: Opacity(
        opacity: widget.percent,
        child: DoctorsCard(
          specialitiesValue: specialitiesValue,
          genderValue: genderValue,
          countryValue: countryValue,
          stateValue: stateValue,
          cityValue: cityValue,
          updateFilterState: updateFilterState,
          resetFilterState: resetFilterState,
        ),
      ),
    );
  }
}

class DoctorsCard extends StatefulWidget {
  final String? genderValue;
  final String? specialitiesValue;
  final String? countryValue;
  final String? stateValue;
  final String? cityValue;
  final Function updateFilterState;
  final Function resetFilterState;
  const DoctorsCard({
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
  State<DoctorsCard> createState() => _DoctorsCardState();
}

class _DoctorsCardState extends State<DoctorsCard> {
  static late String _chosenModel;
  late List<Map<String, dynamic>> availabilityValues;
  String? availabilityValue;
  final keyWordController = TextEditingController();
  String keyWordValue = '';
  bool selected = false;
  bool _isFinished = false;
  double paddingTop = 15;
  // void init(BuildContext context) {
  //   _chosenModel = context.tr('availability');
  // }

  @override
  void didChangeDependencies() {
    context.locale.toString(); // OK
    super.didChangeDependencies();
  }

  void updatePadding(double value) {
    setState(() {
      paddingTop = value;
    });
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
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.only(top: paddingTop),
                  child: Text(context.tr('filterSelection')),
                ),
                AnimatedPadding(
                  duration: const Duration(seconds: 2),
                  padding:
                      EdgeInsets.only(top: paddingTop, left: 18, right: 18),
                  child: TextField(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        if (isFiltersHaveValue) {
                          paddingTop = 6;
                        } else {
                          paddingTop = 15;
                        }
                      });
                    },
                    controller: keyWordController,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      keyWordController.text = value;
                      setState(() {
                        keyWordValue = value;
                        if (isFiltersHaveValue && value != '') {
                          paddingTop = 6;
                        } else {
                          paddingTop = 15;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      prefixIconColor: Theme.of(context).primaryColor,
                      suffixIcon: keyWordController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                keyWordController.text = '';
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
                  duration: const Duration(seconds: 2),
                  padding:
                      EdgeInsets.only(top: paddingTop, left: 18, right: 18),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Icon(
                        Icons.event_available,
                        size: 19,
                      ),
                      prefixIconColor: Theme.of(context).primaryColor,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 10.0),
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
                        items: availabilityValues.map<DropdownMenuItem<String>>(
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
                  duration: const Duration(seconds: 2),
                  padding:
                      EdgeInsets.only(top: paddingTop, right: 10, left: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(double.maxFinite, 30),
                      elevation: 5.0,
                    ),
                    onPressed: () {
                      Map<String, String> searchFilters = {
                        ...widget.cityValue != null
                            ? {"city": widget.cityValue!}
                            : {},
                        ...widget.stateValue != null
                            ? {"state": widget.stateValue!}
                            : {},
                        ...widget.countryValue != null
                            ? {"country": widget.countryValue!}
                            : {},
                        ...widget.specialitiesValue != null
                            ? {"specialities": widget.specialitiesValue!}
                            : {},
                        ...widget.genderValue != null
                            ? {"gender": widget.genderValue!}
                            : {},
                        ...keyWordController.text.isNotEmpty
                            ? {"keyWord": keyWordController.text}
                            : {},
                        ...availabilityValue != null
                            ? {"available": availabilityValue!}
                            : {}
                      };
                      context.push(Uri(
                              path: '/doctors/search',
                              queryParameters: searchFilters)
                          .toString());
                    },
                    child: Text(
                      context.tr('searchNow'),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                AnimatedPadding(
                  duration: const Duration(seconds: 2),
                  padding:
                      EdgeInsets.only(top: paddingTop, right: 10, left: 10),
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
                                setState(() {
                                  if (specialities != null ||
                                      gender != null ||
                                      country != null ||
                                      state != null ||
                                      city != null) {
                                    paddingTop = 6;
                                  } else {
                                    paddingTop = 15;
                                  }
                                });
                                widget.updateFilterState(
                                    specialities, gender, country, state, city);
                              },
                              onReset: () {
                                keyWordController.text = '';
                                setState(() {
                                  keyWordValue = '';
                                  availabilityValue = null;
                                  paddingTop = 15;
                                });
                                widget.resetFilterState();
                              }),
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
                    activeColor: Theme.of(context).primaryColorLight,
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
                AnimatedCrossFade(
                  crossFadeState: !_isFinished
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
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
                              setState(() {
                                keyWordValue = '';
                                availabilityValue = null;
                                paddingTop = 15;
                              });
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
          )),
    );
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  // ignore: prefer_typing_uninitialized_variables
  final color;

  const DashedLineVerticalPainter({
    Key? key,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 5;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FilterScreen extends StatefulWidget {
  final String title;
  final String description;
  final dynamic onSubmit;
  final Function onReset;
  final String? genderValue;
  final String? specialitiesValue;
  final String? countryValue;
  final String? stateValue;
  final String? cityValue;
  const FilterScreen({
    super.key,
    required this.title,
    required this.description,
    required this.onSubmit,
    required this.onReset,
    required this.genderValue,
    required this.specialitiesValue,
    required this.countryValue,
    required this.stateValue,
    required this.cityValue,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final SpecialitiesService specialitiesService = SpecialitiesService();
  final GlobalObjectKey countryKey = const GlobalObjectKey('country');
  final countryController = TextEditingController();
  final GlobalObjectKey stateKey = const GlobalObjectKey('state');
  final stateController = TextEditingController();
  final GlobalObjectKey cityKey = const GlobalObjectKey('city');
  final cityController = TextEditingController();
  String? genderValue;
  String? specialitiesValue;
  String? countryValue;
  String? stateValue;
  String? cityValue;
  @override
  void initState() {
    super.initState();
    genderValue = widget.genderValue;
    specialitiesValue = widget.specialitiesValue;
    countryValue = widget.countryValue;
    stateValue = widget.stateValue;
    cityValue = widget.cityValue;
    countryController.text = widget.countryValue ?? '';
    stateController.text = widget.stateValue ?? '';
    cityController.text = widget.cityValue ?? '';
    specialitiesService.getSpecialitiesData(context);
  }

  @override
  void dispose() {
    super.dispose(); // Always call super.dispose() at the end.
  }

  Future<List<Countries>> countrySuggestionsCallback(String search) async {
    if (search.isNotEmpty) {
      socket.emit('countrySearch', {
        'searchText': search,
        "fieldValue": 'name',
        "state": "",
        "country": ""
      });
    }
    List<Countries> countries = [];
    socket.on(
      'countrySearchReturn',
      (data) async {
        if (data['status'] == 200) {
          countries.clear();
          var m = data['country'];

          for (int i = 0; i < m.length; i++) {
            final countriesFromAdmin = Countries.fromMap(m[i]);
            countries.add(countriesFromAdmin);
          }

          return countries;
        } else {
          return countries;
        }
      },
    );
    return Future<List<Countries>>.delayed(
      const Duration(milliseconds: 300),
      () async {
        return countries.toList();
      },
    );
  }

  Future<List<States>> stateSuggestionsCallback(String search) async {
    if (search.isNotEmpty) {
      socket.emit('stateSearch', {
        'searchText': search,
        "fieldValue": 'name',
        "country": countryValue,
      });
    }
    List<States> states = [];
    socket.on(
      'stateSearchReturn',
      (data) async {
        if (data['status'] == 200) {
          states.clear();
          var m = data['state'];
          for (int i = 0; i < m.length; i++) {
            final statesFromAdmin = States.fromMap(m[i]);
            states.add(statesFromAdmin);
          }

          return states;
        } else {
          return states;
        }
      },
    );
    return Future<List<States>>.delayed(
      const Duration(milliseconds: 300),
      () async {
        return states.toList();
      },
    );
  }

  Future<List<Cities>> citySuggestionsCallback(String search) async {
    if (search.isNotEmpty) {
      socket.emit('citySearch', {
        'searchText': search,
        "fieldValue": 'name',
        "country": countryValue,
        "state": stateValue,
      });
    }
    List<Cities> cities = [];
    socket.on(
      'citySearchReturn',
      (data) async {
        if (data['status'] == 200) {
          cities.clear();
          var m = data['city'];
          for (int i = 0; i < m.length; i++) {
            final citiesFromAdmin = Cities.fromMap(m[i]);
            cities.add(citiesFromAdmin);
          }

          return cities;
        } else {
          return cities;
        }
      },
    );
    return Future<List<Cities>>.delayed(
      const Duration(milliseconds: 300),
      () async {
        return cities.toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final specialities =
        Provider.of<SpecialitiesProvider>(context).specialities;
    var brightness = Theme.of(context).brightness;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColorLight,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            context.tr("filters"),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColorLight),
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          context.tr("chooseFilters"),
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      if (specialities.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 28.0, left: 8.0, right: 8.0, bottom: 8.0),
                          child: SearchChoices.single(
                            closeButton: context.tr('close'),
                            iconSize: 24.0,
                            fieldDecoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0,
                                ),
                                top: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0,
                                ),
                                left: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0,
                                ),
                                right: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            displayClearIcon:
                                specialitiesValue == null ? false : true,
                            icon: null,
                            clearIcon: Icon(
                              Icons.clear,
                              color: Theme.of(context).primaryColorLight,
                            ),
                            items: specialities.map<DropdownMenuItem<String>>(
                              (Specialities value) {
                                var brightness = Theme.of(context).brightness;
                                final name = context.tr(value.specialities);
                                final imageSrc = value.image;
                                final imageIsSvg = imageSrc.endsWith('.svg');
                                return DropdownMenuItem<String>(
                                  value: value.specialities,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: imageIsSvg
                                            ? SvgPicture.network(
                                                imageSrc, //?random=${DateTime.now().millisecondsSinceEpoch}
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.fitHeight,
                                              )
                                            : Image.network(
                                                imageSrc, //?random=${DateTime.now().millisecondsSinceEpoch}
                                                width: 20,
                                                height: 20,
                                              ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        name,
                                        style: TextStyle(
                                            color: brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                            value: specialitiesValue,
                            hint: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                tr('specialities'),
                              ),
                            ),
                            onClear: () {
                              setState(() {
                                specialitiesValue = null;
                              });
                            },
                            searchHint: tr('specialities'),
                            onChanged: (value) {
                              setState(() {
                                specialitiesValue = value;
                              });
                            },
                            isExpanded: true,
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 95.0,
                          left: 8.0,
                          right: 8.0,
                          bottom: 8.0,
                        ),
                        child: SearchChoices.single(
                          iconSize: 24.0,
                          fieldDecoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                              top: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                              left: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                              right: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                            ),
                          ),
                          closeButton: context.tr('close'),
                          displayClearIcon: genderValue == null ? false : true,
                          icon: null,
                          clearIcon: Icon(
                            Icons.clear,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          items: <Map<String, String>>[
                            {"title": context.tr('Mr'), 'icon': '👨'},
                            {"title": context.tr('Mrs'), 'icon': '👩'},
                            {"title": context.tr('Mss'), 'icon': '👩'},
                          ].map<DropdownMenuItem<String>>(
                            (Map<String, String> value) {
                              var brightness = Theme.of(context).brightness;
                              return DropdownMenuItem<String>(
                                value: value['title'],
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 12.0),
                                      child: Text(value['icon']!),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      value['title']!,
                                      style: TextStyle(
                                        color: brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                          value: genderValue,
                          hint: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              tr('gender'),
                            ),
                          ),
                          searchHint: tr('gender'),
                          onClear: () {
                            setState(() {
                              genderValue = null;
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              genderValue = value;
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 173.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0,
                        ),
                        child: TypeAheadField<Countries>(
                          controller: countryController,
                          hideWithKeyboard: false,
                          suggestionsCallback: (search) =>
                              countrySuggestionsCallback(search),
                          itemSeparatorBuilder: (context, index) {
                            return Divider(
                              height: 1,
                              color: Theme.of(context).primaryColor,
                            );
                          },
                          emptyBuilder: (context) => ListTile(
                            title: Text(
                              context.tr('noItem'),
                            ),
                          ),
                          errorBuilder: (context, error) {
                            return ListTile(
                              title: Text(
                                error.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            );
                          },
                          loadingBuilder: (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Theme.of(context).primaryColorLight,
                                  )
                                ],
                              ),
                            );
                          },
                          builder: (context, controller, focusNode) {
                            return TextField(
                              key: countryKey,
                              controller: controller,
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              focusNode: focusNode,
                              autofocus: false,
                              onChanged: (value) {
                                countryController.text = value;
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14.0,
                                  horizontal: 8,
                                ),
                                suffixIcon: countryValue == null
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          countryController.text = '';
                                          stateController.text = '';
                                          cityController.text = '';
                                          setState(() {
                                            countryValue = null;
                                            stateValue = null;
                                            cityValue = null;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                      ),
                                border: const OutlineInputBorder(),
                                labelStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                labelText: context.tr('country'),
                              ),
                            );
                          },
                          decorationBuilder: (context, child) {
                            return Material(
                              type: MaterialType.card,
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              borderOnForeground: true,
                              child: child,
                            );
                          },
                          offset: const Offset(0, 2),
                          constraints: const BoxConstraints(maxHeight: 500),
                          itemBuilder: (context, country) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Text(
                                    country.emoji,
                                    style: const TextStyle(fontSize: 24.0),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: ListTile(
                                    title: Text(
                                      country.name,
                                      style: TextStyle(
                                          color: brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    subtitle: Text(
                                      country.subtitle ??
                                          '{$country.region} - ${country.subregion}',
                                      style: TextStyle(
                                          color: brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                          onSelected: (country) {
                            setState(() {
                              countryValue = country.name;
                            });
                            countryController.text =
                                '${country.emoji} - ${country.name}';
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 245.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0,
                        ),
                        child: TypeAheadField<States>(
                          controller: stateController,
                          hideWithKeyboard: false,
                          suggestionsCallback: (search) =>
                              stateSuggestionsCallback(search),
                          itemSeparatorBuilder: (context, index) {
                            return Divider(
                              height: 1,
                              color: Theme.of(context).primaryColor,
                            );
                          },
                          emptyBuilder: (context) => ListTile(
                            title: Text(
                              context.tr('noItem'),
                            ),
                          ),
                          errorBuilder: (context, error) {
                            return ListTile(
                              title: Text(
                                error.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            );
                          },
                          loadingBuilder: (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Theme.of(context).primaryColorLight,
                                  )
                                ],
                              ),
                            );
                          },
                          builder: (context, controller, focusNode) {
                            return TextField(
                              key: stateKey,
                              controller: controller,
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              focusNode: focusNode,
                              autofocus: false,
                              onChanged: (value) {
                                stateController.text = value;
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14.0,
                                  horizontal: 8,
                                ),
                                suffixIcon: stateValue == null
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          stateController.text = '';
                                          cityController.text = '';
                                          cityValue = null;
                                          setState(() {
                                            stateValue = null;
                                            cityValue = null;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                      ),
                                border: const OutlineInputBorder(),
                                labelStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                labelText: context.tr('state'),
                              ),
                            );
                          },
                          decorationBuilder: (context, child) {
                            return Material(
                              type: MaterialType.card,
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              borderOnForeground: true,
                              child: child,
                            );
                          },
                          offset: const Offset(0, 2),
                          constraints: const BoxConstraints(maxHeight: 500),
                          itemBuilder: (context, state) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Text(
                                    state.emoji,
                                    style: const TextStyle(fontSize: 24.0),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: ListTile(
                                    title: Text(
                                      state.name,
                                      style: TextStyle(
                                          color: brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    subtitle: Text(
                                      state.subtitle ??
                                          '{$state.countryName} - ${state.iso2}',
                                      style: TextStyle(
                                        color: brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                          onSelected: (state) {
                            setState(() {
                              countryValue = state.countryName;
                              stateValue = state.name;
                            });
                            stateController.text =
                                '${state.emoji} - ${state.name}';
                            countryController.text =
                                '${state.emoji} - ${state.countryName}';
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 315.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0,
                        ),
                        child: TypeAheadField<Cities>(
                          controller: cityController,
                          hideWithKeyboard: false,
                          suggestionsCallback: (search) =>
                              citySuggestionsCallback(search),
                          itemSeparatorBuilder: (context, index) {
                            return Divider(
                              height: 1,
                              color: Theme.of(context).primaryColor,
                            );
                          },
                          emptyBuilder: (context) => ListTile(
                            title: Text(
                              context.tr('noItem'),
                            ),
                          ),
                          errorBuilder: (context, error) {
                            return ListTile(
                              title: Text(
                                error.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            );
                          },
                          loadingBuilder: (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Theme.of(context).primaryColorLight,
                                  )
                                ],
                              ),
                            );
                          },
                          builder: (context, controller, focusNode) {
                            return TextField(
                              key: cityKey,
                              controller: controller,
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              focusNode: focusNode,
                              autofocus: false,
                              onChanged: (value) {
                                cityController.text = value;
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14.0,
                                  horizontal: 8,
                                ),
                                suffixIcon: cityValue == null
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          cityController.text = '';
                                          setState(() {
                                            cityValue = null;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                      ),
                                border: const OutlineInputBorder(),
                                labelStyle: const TextStyle(color: Colors.grey),
                                labelText: context.tr('city'),
                              ),
                            );
                          },
                          decorationBuilder: (context, child) {
                            return Material(
                              type: MaterialType.card,
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              borderOnForeground: true,
                              child: child,
                            );
                          },
                          offset: const Offset(0, 2),
                          constraints: const BoxConstraints(maxHeight: 500),
                          itemBuilder: (context, city) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Text(
                                    city.emoji,
                                    style: const TextStyle(fontSize: 24.0),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: ListTile(
                                    title: Text(
                                      city.name,
                                      style: TextStyle(
                                          color: brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    subtitle: Text(
                                      city.subtitle ??
                                          '{$city.countryName} - ${city.stateName}',
                                      style: TextStyle(
                                          color: brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                          onSelected: (city) {
                            setState(() {
                              countryValue = city.countryName;
                              stateValue = city.stateName;
                              cityValue = city.name;
                            });

                            stateController.text =
                                '${city.emoji} - ${city.stateName}';
                            countryController.text =
                                '${city.emoji} - ${city.countryName}';
                            cityController.text =
                                '${city.emoji} - ${city.name}';
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 378.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(double.maxFinite, 30),
                            elevation: 5.0,
                            foregroundColor: Theme.of(context).primaryColor,
                            animationDuration:
                                const Duration(milliseconds: 1000),
                            backgroundColor:
                                Theme.of(context).primaryColorLight,
                            shadowColor: Theme.of(context).primaryColorLight,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onSubmit(
                              specialitiesValue,
                              genderValue,
                              countryValue,
                              stateValue,
                              cityValue,
                            );
                          },
                          child: Text(
                            context.tr('submit'),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 440.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(double.maxFinite, 30),
                            elevation: 5.0,
                            foregroundColor: Theme.of(context).primaryColor,
                            animationDuration:
                                const Duration(milliseconds: 1000),
                            backgroundColor: Theme.of(context).primaryColor,
                            shadowColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              specialitiesValue = null;
                              genderValue = null;
                              countryValue = null;
                              stateValue = null;
                              cityValue = null;
                            });
                            countryController.text = '';
                            stateController.text = '';
                            cityController.text = '';
                            widget.onReset();
                          },
                          child: Text(
                            context.tr('reset'),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
