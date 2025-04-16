import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:jiffy/jiffy.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class DoctorDashboard extends StatefulWidget {
  static const String routeName = '/doctors/dashboard';
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
  }

  @override
  Widget build(BuildContext context) {
    DoctorsProfile? doctorProfile = Provider.of<AuthProvider>(context).doctorsProfile;
    late String years = '--';
    late String months = '--';
    late String days = '--';
    late String imageUrl = '';

    if (doctorProfile != null &&  doctorProfile.userProfile.dob != '') {
      DateTime dob = doctorProfile.userProfile.dob; // Already DateTime
      DateTime today = DateTime.now();

      DateTime b = DateTime(dob.year, dob.month, dob.day); // use dob.day instead of dob.date

      int totalDays = today.difference(b).inDays;
      int y = totalDays ~/ 365;
      int m = (totalDays - y * 365) ~/ 30;
      int d = totalDays - y * 365 - m * 30;

      years = '$y';
      months = '$m';
      days = '$d';
    }
    if (doctorProfile != null &&  doctorProfile.userProfile.profileImage.isNotEmpty) {
      imageUrl = doctorProfile.userProfile.profileImage;
    }
    var brightness = Theme.of(context).brightness;
    CarouselSlider patientsScrollView = CarouselSlider(
      options: CarouselOptions(
        height: 215.0,
        autoPlay: false,
        enlargeCenterPage: true,
      ),
      items: dcotorsDashboarPatientHeader.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 5.0,
                clipBehavior: Clip.hardEdge,
                margin: const EdgeInsets.all(0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            context.tr(i['title']!, args: ['${doctorProfile?.userProfile.patientsId.length}']),
                            style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CircularPercentIndicator(
                        radius: 40.0,
                        animation: true,
                        animationDuration: 1200,
                        lineWidth: 5.0,
                        percent: i['percent']!,
                        center: i['image']!.isEmpty
                            ? const Text('load Lottie')
                            : Image.asset(
                                i['image']!,
                                width: 85,
                                height: 85,
                                color: brightness == Brightness.dark ? Colors.white : Colors.black,
                              ),
                        circularStrokeCap: CircularStrokeCap.butt,
                        backgroundColor: Theme.of(context).primaryColorLight,
                        progressColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            Jiffy.now().yMMMEd,
                            style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
    CarouselSlider datasScrollView = CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 2.0,
        height: 110,
        enlargeCenterPage: true,
        scrollDirection: Axis.vertical,
        autoPlay: true,
      ),
      items: doctorDataScroll.map((i) {
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
      title: context.tr('doctorDashboard'),
      children:
          // ignore: unnecessary_null_comparison
          doctorProfile == null
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
                                              'assets/images/doctors_profile.jpg',
                                            ) as ImageProvider
                                          : CachedNetworkImageProvider(
                                              imageUrl,
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Dr. ${doctorProfile.userProfile.gender} ${doctorProfile.userProfile.fullName}",
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(doctorProfile.userProfile.userName),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text("As: ${context.tr(doctorProfile.roleName)}"),
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
                                      " ${doctorProfile.userProfile.dob != "" ? DateFormat("dd MMM yyyy").format(doctorProfile.userProfile.dob.toLocal()) : '---- -- --'}",
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
                                        Text(doctorProfile.userProfile.city),
                                        Text(doctorProfile.userProfile.state),
                                        Text(doctorProfile.userProfile.country)
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
                          title: Text(context.tr('patientsData')),
                        ),
                        patientsScrollView,
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
                        ...doctorsDashboardLink.map((i) {
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
