// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_choice_chip/flutter_3d_choice_chip.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pretty_gauge/pretty_gauge.dart';
import 'package:provider/provider.dart';

import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/vital_signs.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/vital_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/vital_service.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/stream_socket.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class PatientDashboard extends StatefulWidget {
  static const String routeName = '/patient/dashboard';
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final AuthService authService = AuthService();
  final VitalService vitalService = VitalService();

  final Map<String, TextEditingController> vitalSignsController = {
    'heartRate': TextEditingController(),
    'bodyTemp': TextEditingController(),
    'weight': TextEditingController(),
    'height': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    vitalService.getVitalSignsData(context);
    authService.updateLiveAuth(context);
  }

  @override
  void dispose() {
    for (var key in vitalSignsController.keys) {
      vitalSignsController[key]?.dispose();
    }
    super.dispose(); // Always call super.dispose() at the end.
  }

  void showCustomDialog(
    BuildContext context,
    String title,
    String unit,
    List<Map<String, dynamic>> dataTable,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
          titlePadding: const EdgeInsets.all(0),
          title: Column(
            children: [
              ListTile(
                dense: true,
                title: Center(child: Text(context.tr(title))),
              ),
              Divider(
                color: Theme.of(context).primaryColorLight,
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DataTable(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                    verticalInside: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                    bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                    top: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                    left: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                    right: BorderSide(color: Theme.of(context).primaryColor, width: 0.7),
                  ),
                  headingRowHeight: 32.0,
                  showBottomBorder: true,
                  horizontalMargin: dataTable.isNotEmpty ? 16 : 50,
                  columns: [
                    DataColumn(
                      label: Flexible(
                        fit: FlexFit.tight,
                        child: Center(
                          child: Text(
                            context.tr('id'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Flexible(
                        fit: FlexFit.tight,
                        child: Center(
                          child: Text(
                            "${context.tr('value')} / $unit",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Flexible(
                        fit: FlexFit.tight,
                        child: Center(
                          child: Text(
                            context.tr('date'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: dataTable.map((e) {
                    String formattedDate = DateFormat("yyyy MMM dd HH:mm").format(e['date']);
                    return DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: Text(
                              e['id'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              e['value'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(double.maxFinite, 30),
                      elevation: 5.0,
                      foregroundColor: Theme.of(context).primaryColor,
                      animationDuration: const Duration(milliseconds: 1000),
                      backgroundColor: Theme.of(context).primaryColorLight,
                      shadowColor: Theme.of(context).primaryColorLight,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      context.tr('close'),
                      style: const TextStyle(color: Colors.black),
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

  @override
  Widget build(BuildContext context) {
    var patientProfile = Provider.of<AuthProvider>(context).patientProfile;

    final vitalSigns = Provider.of<VitalProvider>(context).vitalSign;
    late String years = '--';
    late String months = '--';
    late String days = '--';
    late String imageUrl = '';
   if (patientProfile != null) {
  DateTime? birthDate;

  if (patientProfile.userProfile.dob is DateTime) {
    // If dob is already a DateTime object
    birthDate = patientProfile.userProfile.dob as DateTime;
  } else if (patientProfile.userProfile.dob is String && patientProfile.userProfile.dob.isNotEmpty) {
    // If dob is a non-empty string, try to parse it
    try {
      // Assuming the string format is parsable by Jiffy, like "yyyy-MM-ddTHH:mm:ssZ"
      birthDate = Jiffy.parse(patientProfile.userProfile.dob as String).dateTime;
    // ignore: empty_catches
    } catch (e) {}
  }

  if (birthDate != null) {
    DateTime today = DateTime.now();
    // Use the actual birthDate directly for calculation
    int totalDays = today.difference(birthDate).inDays;

    // Basic calculation for years, months, days.
    // Note: This is an approximation as months have different lengths.
    // For precise age, consider using a date utility package or more complex logic.
    int y = totalDays ~/ 365;
    int remainingDaysAfterYears = totalDays - (y * 365);
    int m = remainingDaysAfterYears ~/ 30; // Approx months
    int d = remainingDaysAfterYears - (m * 30); // Remaining days

    years = '$y';
    months = '$m';
    days = '$d';
  }
}
    if (patientProfile != null) {
      if (patientProfile.userProfile.profileImage.isNotEmpty) {
        imageUrl = patientProfile.userProfile.profileImage;
      }
    }
    var brightness = Theme.of(context).brightness;
    CarouselSlider vitalSignScrollView = CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: false,
        enlargeCenterPage: true,
      ),
      items: vitalBoxList.map(
        (i) {
          return Builder(
            builder: (BuildContext context) {
              dynamic vitalMap;
              if (vitalSigns != null) {
                vitalMap = vitalSigns.toMap();
                if (vitalMap[i['title']].isNotEmpty) {
                  vitalSignsController[i['title']]?.text = vitalMap[i['title']][0]['value'].toString();
                }
              }
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 5.0,
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.all(0),
                  child: InkWell(
                    splashColor: Theme.of(context).primaryColor,
                    onTap: () {
                      showCustomDialog(
                        context,
                        i['title'],
                        i['unit'],
                        vitalMap == null ? [] : vitalMap[i['title']],
                      );
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: 45,
                          child: ListTile(
                            title: Center(
                              child: Text(
                                context.tr(i['title']!),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          // height: 100,
                          child: i['image']!.isEmpty
                              ? Lottie.asset(i['icon']!,
                                  animate: true,
                                  delegates: LottieDelegates(values: [
                                    ValueDelegate.colorFilter(
                                      ['Line', '**'],
                                      value: ColorFilter.mode(
                                        Theme.of(context).primaryColorLight,
                                        BlendMode.src,
                                      ),
                                    ),
                                    ValueDelegate.colorFilter(
                                      ["Layer 6 Outlines", '**'],
                                      value: ColorFilter.mode(
                                        brightness == Brightness.dark ? Colors.white : Colors.black,
                                        BlendMode.src,
                                      ),
                                    ),
                                    ValueDelegate.colorFilter(
                                      ["Layer 5 Outlines", '**'],
                                      value: ColorFilter.mode(
                                        brightness == Brightness.dark ? Colors.white : Colors.black,
                                        BlendMode.src,
                                      ),
                                    ),
                                    ValueDelegate.colorFilter(
                                      ["Layer 4 Outlines", '**'],
                                      value: ColorFilter.mode(
                                        brightness == Brightness.dark ? Colors.white : Colors.black,
                                        BlendMode.src,
                                      ),
                                    ),
                                    ValueDelegate.colorFilter(
                                      ["Layer 3 Outlines", '**'],
                                      value: ColorFilter.mode(
                                        brightness == Brightness.dark ? Colors.white : Colors.black,
                                        BlendMode.src,
                                      ),
                                    ),
                                    ValueDelegate.colorFilter(
                                      ["therometer outline", '**'],
                                      value: ColorFilter.mode(
                                        brightness == Brightness.dark ? Colors.white : Colors.black,
                                        BlendMode.src,
                                      ),
                                    ),
                                    ValueDelegate.colorFilter(
                                      ["Layer 2 Outlines", '**'],
                                      value: ColorFilter.mode(
                                        brightness == Brightness.dark ? Colors.white : Colors.black,
                                        BlendMode.src,
                                      ),
                                    ),
                                    ValueDelegate.colorFilter(
                                      ["Sun", '**'],
                                      value: ColorFilter.mode(
                                        Theme.of(context).primaryColorLight,
                                        BlendMode.src,
                                      ),
                                    ),
                                    ValueDelegate.colorFilter(
                                      ["Place 1", '**'],
                                      value: ColorFilter.mode(
                                        Theme.of(context).primaryColorLight,
                                        BlendMode.src,
                                      ),
                                    ),
                                    ValueDelegate.colorFilter(
                                      ["Place 2", '**'],
                                      value: ColorFilter.mode(
                                        Theme.of(context).primaryColorLight,
                                        BlendMode.src,
                                      ),
                                    ),
                                    ValueDelegate.colorFilter(
                                      ["Main", '**'],
                                      value: ColorFilter.mode(
                                        Theme.of(context).primaryColor,
                                        BlendMode.src,
                                      ),
                                    )
                                  ]))
                              : Image.asset(i['image']!),
                        ),
                        SizedBox(
                          height: 45,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                child: TextField(
                                  onEditingComplete: () {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    var name = i['title'];
                                    var value = vitalSignsController[i['title']]?.text;
                                    var userId = patientProfile!.userId;
                                    if (value!.isNotEmpty) {
                                      socket.emit(
                                        'vitalSignsUpdate',
                                        {"name": name, "value": int.tryParse(value), "userId": userId},
                                      );
                                    }
                                  },
                                  maxLength: 3,
                                  controller: vitalSignsController[i['title']],
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    hintText: "-- ",
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ], // Only numbers can be entered
                                ),
                              ),
                              Text(
                                "${i['unit']}",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // Text(
                  //   context.tr(i),
                  //   style: const TextStyle(fontSize: 16.0),
                  // ),
                ),
              );
            },
          );
        },
      ).toList(),
    );
    CarouselSlider datasScrollView = CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 2.0,
        height: 110,
        enlargeCenterPage: true,
        scrollDirection: Axis.vertical,
        autoPlay: true,
      ),
      items: patinetDataScroll.map((i) {
        final name = context.tr(i['title']);
        return InkWell(
          splashColor: Theme.of(context).primaryColor,
          onTap: () {
            context.push(i['routeName']);
          },
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: InkWell(
              splashColor: Theme.of(context).primaryColor,
              onTap: () {
                context.push(i['routeName']);
              },
              child: SizedBox(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: i['icon'],
                  title: Text(name),
                  trailing: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );

    return ScaffoldWrapper(
      key: const Key('patientDashboard'),
      title: context.tr('patientDashboard'),
      children: patientProfile == null
          ? const LoadingScreen()
          : SingleChildScrollView(
              child: FadeinWidget(
                isCenter: true,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 5.0,
                        clipBehavior: Clip.hardEdge,
                        margin: const EdgeInsets.all(0),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                top: 8.0,
                              ),
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: imageUrl.isEmpty
                                      ? const AssetImage(
                                          'assets/images/default-avatar.png',
                                        ) as ImageProvider
                                      : CachedNetworkImageProvider(imageUrl),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                                "${patientProfile.userProfile.gender} ${patientProfile.userProfile.firstName} ${patientProfile.userProfile.lastName}"),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(patientProfile.userProfile.userName),
                            const SizedBox(
                              height: 5,
                            ),
                            Text("As: ${context.tr(patientProfile.roleName)}"),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cake,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                Text(
                                  patientProfile.userProfile.dob is DateTime ? DateFormat("yyyy MMM dd ").format(patientProfile.userProfile.dob as DateTime) : (patientProfile.userProfile.dob is String && (patientProfile.userProfile.dob as String).isNotEmpty) ? DateFormat("yyyy MMM dd ").format(DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(patientProfile.userProfile.dob as String).toLocal()) : '---- -- --'
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text("$years ${context.tr('years')} $months ${context.tr('month')} $days ${context.tr('days')}"),
                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).primaryColor,
                                ),
                                Column(
                                  children: [
                                    Text(patientProfile.userProfile.city),
                                    Text(patientProfile.userProfile.state),
                                    Text(patientProfile.userProfile.country)
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(context.tr('vitalSigns')),
                    ),
                    vitalSignScrollView,
                    ListTile(
                      title: Text(context.tr('bmiStatus')),
                    ),
                    Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 5.0,
                        clipBehavior: Clip.hardEdge,
                        margin: const EdgeInsets.all(0),
                        child: InkWell(
                          splashColor: Theme.of(context).primaryColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BMIScreen(
                                  vitalSigns: vitalSigns,
                                  age: years == '--' ? 1 : int.parse(years),
                                  gender: patientProfile.userProfile.gender,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 45,
                                child: ListTile(
                                  title: Center(
                                    child: Text(
                                      context.tr('bmiStatus'),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                // height: 100,
                                child: PrettyGauge(
                                  gaugeSize: 210,
                                  minValue: 0,
                                  maxValue: 40,
                                  segments: [
                                    GaugeSegment('UnderWeight', 18.5, Colors.red),
                                    GaugeSegment('Normal', 6.4, Colors.green),
                                    GaugeSegment('OverWeight', 5, Colors.orange),
                                    GaugeSegment('Obese', 10.1, Colors.pink),
                                  ],
                                  valueWidget: const Text(
                                    "",
                                    style: TextStyle(fontSize: 40),
                                  ),
                                  currentValue: 0.5,
                                  needleColor: Theme.of(context).primaryColorLight,
                                  startMarkerStyle: const TextStyle(
                                    fontSize: 10,
                                  ),
                                  endMarkerStyle: const TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Container(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  height: 50,
                                  width: 140,
                                  child: Center(
                                    child: Text(
                                      context.tr("bmi"),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Roboto_Condensed',
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(context.tr('informations')),
                    ),
                    Container(
                      // height: 250,
                      width: MediaQuery.of(context).size.width / 1.2,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      height: 110,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return datasScrollView;
                        },
                        itemCount: 1,
                      ),
                    ),
                    ListTile(
                      title: Text(context.tr('links')),
                    ),
                    ...patientsDashboardLink.where((item) {
                      // Hide 'changePassword' if services (e.g. Google login) is present
                      if (item['name'] == 'changePassword' && patientProfile.services == "google") {
                        return false;
                      }
                      return true;
                    }).map((i) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        child: InkWell(
                          splashColor: Theme.of(context).primaryColor,
                          onTap: () {
                            context.push(i['routeName']);
                          },
                          child: SizedBox(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              leading: i['icon'],
                              title: Text(context.tr(i['name'])),
                              trailing: const Icon(Icons.arrow_forward),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }
}

class BMIScreen extends StatefulWidget {
  final VitalSigns? vitalSigns;

  final int age;
  final String gender;
  const BMIScreen({
    super.key,
    required this.vitalSigns,
    required this.age,
    required this.gender,
  });

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  int _gender = 0;
  int _height = 30;
  int _age = 1;
  int _weight = 3;
  bool _isFinished = false;
  double _bmiScore = 0;

  void calculateBmi() {
    _bmiScore = _weight / pow(_height / 100, 2);
  }

  @override
  Widget build(BuildContext context) {
    var vitalSigns = widget.vitalSigns;
    _age = widget.age;
    if (vitalSigns != null) {
      dynamic vitalMap;
      vitalMap = vitalSigns.toMap();

      if (vitalMap['height'].length > 0) {
        var heightFromVital = vitalMap['height'][vitalMap['height'].length - 1]['value'];
        _height = int.parse(heightFromVital);
      }
      if (vitalMap['weight'].length > 0) {
        var weightFromVital = vitalMap['weight'][vitalMap['weight'].length - 1]['value'];
        _weight = int.parse(weightFromVital);
      }
    }
    if (_gender == 0) {
      _gender = widget.gender == 'Mr' ? 1 : 2;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(context.tr('bmiCalculator')),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColor),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  GenderWidget(
                    onChange: (genderVal) {
                      _gender = genderVal;
                    },
                    gender: _gender,
                  ),
                  SliderWidget(
                    value: _height,
                    name: "height",
                    unit: 'cm',
                    min: 20,
                    max: 240,
                    onChange: (heightVal) {
                      _height = heightVal;
                    },
                  ),
                  SliderWidget(
                    value: _age,
                    name: "age",
                    unit: 'years',
                    min: 1,
                    max: 110,
                    onChange: (ageVal) {
                      _age = ageVal;
                    },
                  ),
                  SliderWidget(
                    value: _weight,
                    name: "weight",
                    unit: 'Kg',
                    min: 3.0,
                    max: 240.0,
                    onChange: (weightVal) {
                      _weight = weightVal;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    child: SwipeableButtonView(
                      isFinished: _isFinished,
                      onFinish: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                              child: ScoreScreen(
                                bmiScore: _bmiScore,
                                age: _age,
                              ),
                              type: PageTransitionType.fade),
                        );

                        setState(() {
                          _isFinished = false;
                        });
                      },
                      onWaitingProcess: () {
                        //Calculate BMI here
                        calculateBmi();

                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _isFinished = true;
                          });
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                      buttonWidget: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.black,
                      ),
                      buttonText: context.tr('calculate'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        // bottomNavigationBar: const BottomBar(showLogin: true)),
      ),
    );
  }
}

class GenderWidget extends StatefulWidget {
  final Function(int) onChange;
  final int gender;
  const GenderWidget({
    super.key,
    required this.onChange,
    required this.gender,
  });

  @override
  State<GenderWidget> createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  int _gender = 0;

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    final ChoiceChip3DStyle selectedStyle = ChoiceChip3DStyle(
        topColor: Theme.of(context).cardColor, backColor: Theme.of(context).primaryColorLight, borderRadius: BorderRadius.circular(20));

    final ChoiceChip3DStyle unselectedStyle = ChoiceChip3DStyle(
        topColor: brightness == Brightness.dark ? Colors.white : Colors.black,
        backColor: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20));
    if (_gender == 0) {
      _gender = widget.gender;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip3D(
              border: Border.all(
                color: _gender == 1 ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
              ),
              style: _gender == 1 ? selectedStyle : unselectedStyle,
              onSelected: () {
                setState(() {
                  _gender = 1;
                });
                widget.onChange(_gender);
              },
              onUnSelected: () {},
              selected: _gender == 1,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.asset(
                      "assets/images/man.png",
                      width: 50,
                    ),
                  ),
                  Text(
                    context.tr('male'),
                    style: TextStyle(
                      color: brightness == Brightness.dark
                          ? _gender == 1
                              ? Colors.white
                              : Colors.black
                          : _gender == 1
                              ? Colors.black
                              : Colors.white,
                    ),
                  )
                ],
              )),
          const SizedBox(
            width: 20,
          ),
          ChoiceChip3D(
              border: Border.all(
                color: _gender == 2 ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
              ),
              style: _gender == 2 ? selectedStyle : unselectedStyle,
              onSelected: () {
                setState(() {
                  _gender = 2;
                });
                widget.onChange(_gender);
              },
              selected: _gender == 2,
              onUnSelected: () {},
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.asset(
                      "assets/images/woman.png",
                      width: 50,
                    ),
                  ),
                  Text(
                    context.tr('female'),
                    style: TextStyle(
                      color: brightness == Brightness.dark
                          ? _gender == 2
                              ? Colors.white
                              : Colors.black
                          : _gender == 2
                              ? Colors.black
                              : Colors.white,
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}

class SliderWidget extends StatefulWidget {
  late Function(int) onChange;
  late int value;
  late String name;
  late String unit;

  final double min;

  final double max;
  SliderWidget({
    super.key,
    required this.onChange,
    required this.value,
    required this.name,
    required this.unit,
    required this.min,
    required this.max,
  });

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant SliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          elevation: 12,
          shape: const RoundedRectangleBorder(),
          child: Column(
            children: [
              Text(
                context.tr(widget.name),
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: TextField(
                      maxLength: 3,
                      controller: _controller,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        counterText: '',
                        hintText: "-- ",
                        hintStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        int? intValue = int.tryParse(value);
                        if (intValue != null && intValue >= widget.min.toInt() && intValue <= widget.max.toInt()) {
                          setState(() {
                            widget.value = intValue;
                            _controller.text = intValue.toString(); // update text safely
                            _controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: _controller.text.length),
                            );
                          });
                          widget.onChange(intValue);
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    context.tr(widget.unit),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  )
                ],
              ),
              Slider(
                min: widget.min,
                max: widget.max,
                value: widget.value.toDouble(),
                thumbColor: Theme.of(context).primaryColor,
                activeColor: Theme.of(context).primaryColorLight,
                onChanged: (value) {
                  _controller = TextEditingController(text: "${value.toInt()}");
                  setState(() {
                    widget.value = value.toInt();
                  });
                  widget.onChange(widget.value);
                },
              )
            ],
          )),
    );
  }
}

class ScoreScreen extends StatefulWidget {
  final double bmiScore;

  final int age;

  const ScoreScreen({
    super.key,
    required this.bmiScore,
    required this.age,
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  String? bmiStatus;

  String? bmiInterpretation;

  Color? bmiStatusColor;

  @override
  Widget build(BuildContext context) {
    setBmiInterpretation(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(context.tr("bmiScore")),
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColor),
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr("yourScore"),
                  style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(
                  height: 10,
                ),
                PrettyGauge(
                  gaugeSize: 300,
                  minValue: 0,
                  maxValue: 40,
                  segments: [
                    GaugeSegment('UnderWeight', 18.5, Colors.red),
                    GaugeSegment('Normal', 6.4, Colors.green),
                    GaugeSegment('OverWeight', 5, Colors.orange),
                    GaugeSegment('Obese', 10.1, Colors.pink),
                  ],
                  valueWidget: Text(
                    widget.bmiScore.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 40),
                  ),
                  currentValue: widget.bmiScore.toDouble(),
                  needleColor: Theme.of(context).primaryColorLight,
                  startMarkerStyle: const TextStyle(
                    fontSize: 10,
                  ),
                  endMarkerStyle: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  bmiStatus!,
                  style: TextStyle(fontSize: 20, color: bmiStatusColor!),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  bmiInterpretation!,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(context.tr('Re-calculate'))),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          // Share.share(
                          //     "Your BMI is ${bmiScore.toStringAsFixed(1)} at age $age");
                        },
                        child: Text(context.tr("Share"))),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setBmiInterpretation(context) {
    if (widget.bmiScore > 30) {
      bmiStatus = tr("Obese");
      bmiInterpretation = tr("ObeseDesc");
      bmiStatusColor = Colors.pink;
    } else if (widget.bmiScore >= 25) {
      bmiStatus = tr("Overweight");
      bmiInterpretation = tr("OverweightDesc");
      bmiStatusColor = Colors.orange;
    } else if (widget.bmiScore >= 18.5) {
      bmiStatus = tr("Normal");
      bmiInterpretation = tr("NormalDesc");
      bmiStatusColor = Colors.green;
    } else if (widget.bmiScore < 18.5) {
      bmiStatus = tr("Underweight");
      bmiInterpretation = tr("UnderweightDesc");
      bmiStatusColor = Colors.red;
    }
  }
}
