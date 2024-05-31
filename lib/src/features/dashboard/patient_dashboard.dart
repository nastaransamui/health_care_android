import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/vital_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/vital_service.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/stream_socket.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:jiffy/jiffy.dart';

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

    if (patientProfile!.userProfile.dob.isNotEmpty) {
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
                                    var userId = patientProfile.userId;

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
      children: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 8.0,
              ),
              height: 180,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                border: Border.all(color: Theme.of(context).primaryColorLight),
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                      '${patientProfile.userProfile.profileImage}?random=${DateTime.now().millisecondsSinceEpoch}'),
                  onError: (exception, stackTrace) =>
                      const AssetImage("assets/images/default-avatar.png"),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
                "${patientProfile.userProfile.firstName} ${patientProfile.userProfile.lastName}"),
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
                      color: Theme.of(context).primaryColorLight, width: 2.0),
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
                          builder: (context) => const BMIScreen()),
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
                          child: Lottie.asset(
                        'assets/images/BMI.json',
                        animate: true,
                      )),
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
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(context.tr('bmiCalculator')),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(),
              ],
            ),
          ),
          bottomNavigationBar: const BottomBar(showLogin: true)),
    );
  }
}
