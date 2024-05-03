// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/providers/clinics_provider.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/router.dart';
import 'package:health_care/services/clinics_service.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/services/specialities_service.dart';
// import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/silver_scaffold_wrapper.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/stream_socket.dart';
import 'package:health_care/theme_config.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  final StreamSocket streamSocket;
  const MyApp({super.key, required this.streamSocket});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  // This widget is the root of your application.
  final ClinicsService clinicsService = ClinicsService();
  final SpecialitiesService specialitiesService = SpecialitiesService();
  final DoctorsService doctorsService = DoctorsService();
  late final AnimationController _controller = AnimationController(vsync: this);
  String homeThemeName = '';
  String homeThemeType = '';
  String homeActivePage = '';

  @override
  void initState() {
    super.initState();
    clinicsService.getClinicData(context);
    specialitiesService.getSpecialitiesData(context);
    doctorsService.getDoctorsData(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: streamSocket.getResponse,
        initialData: '',
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            if (data!.isNotEmpty) {
              var response = jsonDecode(data);
              homeThemeName = response['homeThemeName'];
              homeThemeType = response['homeThemeType'];
              homeActivePage = response['homeActivePage'];
            }
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            restorationScopeId: 'health_care',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: themDataLive(homeThemeName, homeThemeType),
            onGenerateRoute: (settings) => generateRoute(settings),
            home: snapshot.hasData
                ? AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, Widget? child) {
                      return Builder(builder: (context) {
                        switch (homeActivePage) {
                          case 'general_0':
                            return const General0Page();
                          case 'general_1':
                            return const General1Page();
                          case 'general_2':
                            return const General2Page();
                          default:
                            return const Default();
                        }
                      });
                    },
                    // child: const MyHomePage(),
                  )
                : const LoadingScreen(),
          );
        });
  }
}

class Default extends StatefulWidget {
  static const String routeName = '/';
  const Default({
    super.key,
  });

  @override
  State<Default> createState() => _DefaultState();
}

class _DefaultState extends State<Default> {
  @override
  Widget build(BuildContext context) {
    final clinics = Provider.of<ClinicsProvider>(context).clinics;
    final specialities =
        Provider.of<SpecialitiesProvider>(context).specialities;
    final doctors = Provider.of<DoctorsProvider>(context).doctors;
    print(doctors);
    var clinicsScrollView = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          ...clinics.map(
            (i) {
              final name = context.tr(i.href);
              final imagee = i.image;
              final imageSrc = '$webUrl$imagee';
              final bool isActive = i.active;
              if (isActive) {
                return Card(
                  elevation: 5.0,
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Theme.of(context).primaryColor,
                    onTap: () {
                      Navigator.pushNamed(context, i.href);
                    },
                    child: SizedBox(
                      width: 200,
                      height: 220,
                      child: Column(
                        children: [
                          Text(name),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageSrc,
                                width: 200,
                                height: 200,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );

    var specialitiesScrollView = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          ...specialities.map(
            (i) {
              final name = context.tr(i.specialities);
              final imageSrc = i.image;
              final imageIsSvg = imageSrc.endsWith('.svg');
              final numberOfDoctors = i.usersId.length;
              return Card(
                elevation: 5.0,
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Theme.of(context).primaryColor,
                  onTap: () {
                    // Navigator.pushNamed(context, i.href);
                  },
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Column(
                      children: [
                        Text(name),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageIsSvg
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20.0, bottom: 20.0),
                                    child: SvgPicture.network(
                                      imageSrc,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  )
                                : Image.network(
                                    imageSrc,
                                    width: 100,
                                    height: 100,
                                  ),
                          ),
                        ),
                        // Text('doctorsNumber').plural(10, format: NumberFormat.compact(locale: context.locale.toString()))
                        const Text('doctorsNumber').plural(numberOfDoctors,
                            format: NumberFormat.compact(
                                locale: context.locale.toString()))
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
    var doctorScrollView = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          ...doctors.map(
            (i) {
              final name = "${i.firstName} ${i.lastName}";
              final imageSrc = i.profileImage;
              print(name);
              print(imageSrc);
              // final imageIsSvg = imageSrc.endsWith('.svg');
              // final numberOfDoctors = i.usersId.length;
              return InkWell(
                splashColor: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0),
                onTap: () {
                  // Navigator.pushNamed(context, i.href);
                },
                child: Column(
                  children: [
                    // Text(name),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      child: Stack(
                        children: <Widget>[
                          Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5,
                            // margin: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 250,
                                  child: Image.network(
                                    imageSrc,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Positioned(
                            bottom: 0,
                            left: 10,
                            child: SizedBox(
                              height: 50,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [Text('Title'), Text('Subtitle')],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // FittedBox(
                    //   fit: BoxFit.contain,
                    //   child: ClipRRect(
                    //     borderRadius: BorderRadius.circular(8),
                    //     child: Image.network(
                    //       imageSrc,
                    //       width: MediaQuery.of(context).size.width,
                    //       height: 200,
                    //     ),
                    //   ),
                    // ),
                    // // Text('doctorsNumber').plural(10, format: NumberFormat.compact(locale: context.locale.toString()))
                    // const Text('doctorsNumber').plural(
                    //   numberOfDoctors,
                    //   format: NumberFormat.compact(
                    //     locale: context.locale.toString(),
                    //   ),
                    // )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        children: <Widget>[
          ListTile(
            title: Text(context.tr('clinics')),
          ),
          Expanded(
            child: SizedBox(
              // color: Colors.red,
              height: 250,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return clinicsScrollView;
                },
                itemCount: 1,
              ),
            ),
          ),
          ListTile(
            title: Text(context.tr('specialities')),
          ),
          SizedBox(
            // color: Colors.red,
            height: 160,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return specialitiesScrollView;
              },
              itemCount: 1,
            ),
          ),

          ListTile(
            title: Text(context.tr('bestDoctors')),
          ),
          SizedBox(
            // color: Colors.red,
            height: 350,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return doctorScrollView;
              },
              itemCount: 1,
            ),
          ),
          // Container(color: Colors.blue, height: 100)
        ],
      ),
      // SliverList(
      //   delegate: SliverChildListDelegate([
      //     Container(
      //       color: Colors.yellow,
      //       // height: 400,
      //       child: ListView.builder(
      //         shrinkWrap: true,
      //         physics: const BouncingScrollPhysics(),
      //         itemBuilder: (context, index) {
      //           return singleChildScrollView;
      //         },
      //         itemCount: 1,
      //       ),
      //     ),
      //     // Container(color: Colors.red, height: 800),
      //   ]),
      // ),
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   mainAxisSize: MainAxisSize.max,
      //   children: <Widget>[
      //     const ListTile(
      //       title: Text('Clinics '),
      //     ),
      //     SizedBox(
      //       height: 230,
      //       // color: Colors.blue,
      //       child: ListView.builder(
      //         shrinkWrap: true,
      //         physics: const BouncingScrollPhysics(),
      //         itemBuilder: (context, index) {
      //           return singleChildScrollView;
      //         },
      //         itemCount: 1,
      //       ),
      //     ),
      //     SizedBox(
      //       height: 230,
      //       // color: Colors.blue,
      //       child: ListView.builder(
      //         shrinkWrap: true,
      //         physics: const BouncingScrollPhysics(),
      //         itemBuilder: (context, index) {
      //           return singleChildScrollView;
      //         },
      //         itemCount: 1,
      //       ),
      //     ),
      //     const Text('We cannot let a stray gunshot give us away'),
      //     const Text(
      //         'We will fight up close, seize the moment and stay in it'),
      //     const Text(
      //         'It’s either that or meet the business end of a bayonet'),
      //     const Text('The code word is ‘Rochambeau,’ dig me?'),

      //     Expanded(
      //       child: Text(
      //         'Rochambeau!',
      //         style: DefaultTextStyle.of(context)
      //             .style
      //             .apply(fontSizeFactor: 2.0),
      //       ),
      //     ),
      //   ],
      // )
      // ListView.builder(
      //     itemBuilder: (context, index) {return singleChildScrollView; },
      //     itemCount:1,
      //   ),
    );
    // children: SingleChildScrollView(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //     children: <Widget>[
    //       if (clinics.isEmpty) ...[
    //         const LoadingScreen()
    //       ] else ...[
    //         ...clinics.map(
    //           (e) {
    //             if (e.active) {
    //               return Text(e.name, style: const TextStyle(fontSize: 15));
    //             } else {
    //               return const SizedBox();
    //             }
    //           },
    //         ),
    //         // ...getList()
    //         // CarouselSlider.builder(
    //         //   itemCount: clinics.length,
    //         //   itemBuilder:
    //         //       (BuildContext context, int index, int realIndex) {
    //         //     final i = clinics[index];
    //         //     final name = i.name;
    //         //     final image = i.image;
    //         //     final imageSrc = '$webUrl$image';
    //         //     final bool isActive = i.active;
    //         //     print(name);
    //         //     if (isActive) {
    //         //       return Image.network(
    //         //         imageSrc,
    //         //         fit: BoxFit.cover,
    //         //         height: 200,
    //         //       );
    //         //     }else{
    //         //       return  Text(name);
    //         //     }
    //         //   },
    //         //   options: CarouselOptions(
    //         //     viewportFraction: 1,
    //         //     height: 250,
    //         //     // autoPlay: true,
    //         //     autoPlayInterval: const Duration(milliseconds: 2000),
    //         //   ),
    //         // )
    //       ],
    //     ],
    //   ),
    // ),
    // );
  }
}

class General0Page extends StatefulWidget {
  static const String routeName = '/';
  const General0Page({
    super.key,
  });

  @override
  State<General0Page> createState() => _General0PageState();
}

class _General0PageState extends State<General0Page> {
  @override
  Widget build(BuildContext context) {
    return const SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('General 0 Page'),
        ],
      ),
    );
  }
}

class General1Page extends StatefulWidget {
  static const String routeName = '/';
  const General1Page({
    super.key,
  });

  @override
  State<General1Page> createState() => _General1PageState();
}

class _General1PageState extends State<General1Page> {
  @override
  Widget build(BuildContext context) {
    return const SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('General 1 Page'),
        ],
      ),
    );
  }
}

class General2Page extends StatefulWidget {
  static const String routeName = '/';
  const General2Page({
    super.key,
  });

  @override
  State<General2Page> createState() => _General2PageState();
}

class _General2PageState extends State<General2Page> {
  @override
  Widget build(BuildContext context) {
    return const SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('General 2 Page'),
        ],
      ),
    );
  }
}
