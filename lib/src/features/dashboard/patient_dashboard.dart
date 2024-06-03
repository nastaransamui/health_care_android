// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_choice_chip/flutter_3d_choice_chip.dart';
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
  static const String routeName = '/patient_dashboard';
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
          contentPadding:
              const EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
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
                    horizontalInside: BorderSide(
                        color: Theme.of(context).primaryColor, width: 0.7),
                    verticalInside: BorderSide(
                        color: Theme.of(context).primaryColor, width: 0.7),
                    bottom: BorderSide(
                        color: Theme.of(context).primaryColor, width: 0.7),
                    top: BorderSide(
                        color: Theme.of(context).primaryColor, width: 0.7),
                    left: BorderSide(
                        color: Theme.of(context).primaryColor, width: 0.7),
                    right: BorderSide(
                        color: Theme.of(context).primaryColor, width: 0.7),
                  ),
                  headingRowHeight: 32.0,
                  showBottomBorder: true,
                  horizontalMargin: dataTable.isNotEmpty ? 24 : 66,
                  columns: [
                    DataColumn(label: Text("${context.tr('value')} / $unit")),
                    DataColumn(label: Text(context.tr('date'))),
                  ],
                  rows: dataTable.map((e) {
                    var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                        .parseUTC(e['date'])
                        .toLocal();
                    String formattedDate =
                        DateFormat("yyyy MMM dd HH:mm").format(dateValue);
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            e['value'],
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
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
    if (patientProfile != null && patientProfile.userProfile.dob.isNotEmpty) {
      var dob = Jiffy.parse(patientProfile.userProfile.dob);
      DateTime today = DateTime.now();
      DateTime b = DateTime(dob.year, dob.month, dob.date);
      int totalDays = today.difference(b).inDays;
      int y = totalDays ~/ 365;
      int m = (totalDays - y * 365) ~/ 30;
      int d = totalDays - y * 365 - m * 30;
      years = '$y';
      months = '$m';
      days = '$d';
    }
    if (patientProfile != null) {
      if (patientProfile.userProfile.profileImage.isNotEmpty) {
        imageUrl =
            '${patientProfile.userProfile.profileImage}?random=${DateTime.now().millisecondsSinceEpoch}';
      }
    }

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
                  vitalSignsController[i['title']]?.text = vitalMap[i['title']]
                          [vitalMap[i['title']].length - 1]['value']
                      .toString();
                }
              }
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).primaryColorLight, width: 2.0),
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
                              ? Lottie.asset(
                                  i['icon']!,
                                  animate: true,
                                )
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
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    var name = i['title'];
                                    var value =
                                        vitalSignsController[i['title']]?.text;
                                    var userId = patientProfile!.userId;

                                    if (value!.isNotEmpty) {
                                      socket.emit(
                                        'vitalSignsUpdate',
                                        {
                                          "name": name,
                                          "value": value,
                                          "userId": userId
                                        },
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

    return ScaffoldWrapper(
      title: context.tr('patientDashboard'),
      children: patientProfile == null
          ? const LoadingScreen()
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 8.0,
                    ),
                    height: 180,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      border: Border.all(
                          color: Theme.of(context).primaryColorLight),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageUrl.isEmpty
                            ? const AssetImage(
                                'assets/images/default-avatar.png',
                              ) as ImageProvider
                            : CachedNetworkImageProvider(imageUrl),
                        // image: NetworkImage(
                        //   '${patientProfile.userProfile.profileImage}?random=${DateTime.now().millisecondsSinceEpoch}',
                        // ),
                        // onError: (exception, stackTrace) => const AssetImage(
                        //   "assets/images/default-avatar.png",
                        // ),
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
                          " ${patientProfile.userProfile.dob.isNotEmpty ? DateFormat("yyyy MMM dd ").format(DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(patientProfile.userProfile.dob).toLocal()) : '---- -- --'}"),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text("$years years $months months $days days"),
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
                        side: BorderSide(
                            color: Theme.of(context).primaryColorLight,
                            width: 2.0),
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
                                needleColor:
                                    Theme.of(context).primaryColorLight,
                                startMarkerStyle: const TextStyle(
                                  fontSize: 10,
                                ),
                                endMarkerStyle: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 45,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 40,
                                      child: Text(
                                        "bmi",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ))
                                ],
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
        var heightFromVital =
            vitalMap['height'][vitalMap['height'].length - 1]['value'];
        _height = int.parse(heightFromVital);
      }
      if (vitalMap['weight'].length > 0) {
        var weightFromVital =
            vitalMap['weight'][vitalMap['weight'].length - 1]['value'];
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 60),
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
                                  type: PageTransitionType.fade));

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
                        buttonText: "CALCULATE"),
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
        topColor: Theme.of(context).cardColor,
        backColor: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(20));

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
                color: _gender == 1
                    ? Theme.of(context).primaryColorLight
                    : Theme.of(context).primaryColor,
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
                color: _gender == 2
                    ? Theme.of(context).primaryColorLight
                    : Theme.of(context).primaryColor,
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
                  Text(
                    widget.value.toString(),
                    style: const TextStyle(fontSize: 40),
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

// class AgeWeightWidget extends StatefulWidget {
//   final Function(int) onChange;

//   final String title;

//   final int initValue;

//   final int min;

//   final int max;

//   const AgeWeightWidget(
//       {super.key,
//       required this.onChange,
//       required this.title,
//       required this.initValue,
//       required this.min,
//       required this.max});

//   @override
//   State<AgeWeightWidget> createState() => _AgeWeightWidgetState();
// }

// class _AgeWeightWidgetState extends State<AgeWeightWidget> {
//   int counter = 0;

//   @override
//   void initState() {
//     super.initState();
//     counter = widget.initValue;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Card(
//         elevation: 12,
//         shape: const RoundedRectangleBorder(),
//         child: Column(
//           children: [
//             Text(
//               widget.title,
//               style: const TextStyle(
//                 fontSize: 20,
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   InkWell(
//                     child: CircleAvatar(
//                       radius: 12,
//                       backgroundColor: Theme.of(context).primaryColor,
//                       child: const Icon(
//                         Icons.remove,
//                       ),
//                     ),
//                     onTap: () {
//                       setState(() {
//                         if (counter > widget.min) {
//                           counter--;
//                         }
//                       });
//                       widget.onChange(counter);
//                     },
//                   ),
//                   const SizedBox(
//                     width: 15,
//                   ),
//                   Text(
//                     counter.toString(),
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 15,
//                   ),
//                   InkWell(
//                     child: CircleAvatar(
//                       radius: 12,
//                       backgroundColor: Theme.of(context).primaryColorLight,
//                       child: const Icon(Icons.add, color: Colors.white),
//                     ),
//                     onTap: () {
//                       setState(() {
//                         if (counter < widget.max) {
//                           counter++;
//                         }
//                       });
//                       widget.onChange(counter);
//                     },
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class ScoreScreen extends StatelessWidget {
  final double bmiScore;

  final int age;

  String? bmiStatus;

  String? bmiInterpretation;

  Color? bmiStatusColor;

  ScoreScreen({super.key, required this.bmiScore, required this.age});

  @override
  Widget build(BuildContext context) {
    setBmiInterpretation(context);
    return Scaffold(
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
                      style: TextStyle(
                          fontSize: 30, color: Theme.of(context).primaryColor),
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
                        bmiScore.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 40),
                      ),
                      currentValue: bmiScore.toDouble(),
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
                  ]))),
    );
  }

  void setBmiInterpretation(context) {
    if (bmiScore > 30) {
      bmiStatus = "Obese";
      bmiInterpretation = "Please work to reduce obesity";
      bmiStatusColor = Colors.pink;
    } else if (bmiScore >= 25) {
      bmiStatus = "Overweight";
      bmiInterpretation = "Do regular exercise & reduce the weight";
      bmiStatusColor = Colors.orange;
    } else if (bmiScore >= 18.5) {
      bmiStatus = "Normal";
      bmiInterpretation = "Enjoy, You are fit";
      bmiStatusColor = Colors.green;
    } else if (bmiScore < 18.5) {
      bmiStatus = "Underweight";
      bmiInterpretation = "Try to increase the weight";
      bmiStatusColor = Colors.red;
    }
  }
}
