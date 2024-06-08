import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
              // Opacity(
              //   opacity: percent,
              //   child: Text(
              //     context.tr(title),
              //     style: const TextStyle(
              //       color: Colors.black,
              //       fontSize: 24,
              //     ),
              //   ),
              // ),
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
  const DoctorsCard({
    super.key,
    required this.genderValue,
    required this.specialitiesValue,
    required this.countryValue,
    required this.stateValue,
    required this.cityValue,
    required this.updateFilterState,
  });

  @override
  State<DoctorsCard> createState() => _DoctorsCardState();
}

class _DoctorsCardState extends State<DoctorsCard> {
  static late String _chosenModel;
  bool selected = false;
  bool _isFinished = false;
  void init(BuildContext context) {
    _chosenModel = context.tr('none');
  }

  @override
  void didChangeDependencies() {
    context.locale.toString(); // OK
    _chosenModel = context.tr('none');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    Transform.translate(
                      offset: const Offset(5.0, 20.0),
                      child: Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        child: const SizedBox(
                          width: 45,
                          height: 45,
                          child: Icon(
                            Icons.search,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(top: 20),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          
                          hintText: context.tr('keyWord'),
                          hintStyle: const TextStyle(
                            fontSize: 12.0,
                          ),
                          // counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 32.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 30.0,
                  child: CustomPaint(
                    size: const Size(1, double.infinity),
                    painter: DashedLineVerticalPainter(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Transform.translate(
                  offset: const Offset(0, -25),
                  child: Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(6, 12),
                        child: Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          child: const SizedBox(
                            width: 45,
                            height: 45,
                            child: Icon(
                              Icons.event_available,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: DropdownButton<String>(
                          iconEnabledColor: Theme.of(context).primaryColor,
                          style: const TextStyle(
                            fontSize: 12.0,
                          ),
                          underline: Container(
                            height: 1.6,
                            color: Theme.of(context).primaryColor,
                          ),
                          isExpanded: true,
                          value: _chosenModel,
                          items: <String>[
                            context.tr('none'),
                            context.tr('available'),
                            context.tr('today'),
                            context.tr('tomorrow'),
                            context.tr('thisWeek'),
                            context.tr('thisMonth'),
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
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
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.maxFinite, 30),
                    elevation: 5.0,
                  ),
                  onPressed: () {},
                  child: Text(
                    context.tr('searchNow'),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
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
                            widget.updateFilterState(
                                specialities, gender, country, state, city);
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
                // child: ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     fixedSize: const Size(double.maxFinite, 30),
                //     elevation: 5.0,
                //     foregroundColor: Theme.of(context).primaryColor,
                //     animationDuration: const Duration(milliseconds: 1000),
                //     backgroundColor: Theme.of(context).primaryColorLight,
                //     shadowColor: Theme.of(context).primaryColorLight,
                //   ),
                //   onPressed: () {
                //     widget.toggleFilters();
                //   },
                //   child: Text(
                //     context.tr('filters'),
                //     style: const TextStyle(color: Colors.black),
                //   ),
                // ),
              ),
              // Text()
              AnimatedCrossFade(
                crossFadeState: !_isFinished
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 1000),
                firstChild: Text(
                    '${widget.genderValue ?? ''}  ${widget.specialitiesValue ?? ''}\n${widget.countryValue ?? ''} ${widget.stateValue ?? ''} ${widget.cityValue ?? ''}'),
                secondChild: const Text(''),
              )
            ],
          ),
        ),
      ),
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
                                                '$imageSrc?random=${DateTime.now().millisecondsSinceEpoch}',
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.fitHeight,
                                              )
                                            : Image.network(
                                                '$imageSrc?random=${DateTime.now().millisecondsSinceEpoch}',
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
