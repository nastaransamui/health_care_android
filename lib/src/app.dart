// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/clinics.dart';
import 'package:health_care/providers/clinics_provider.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/router.dart';
import 'package:health_care/services/clinics_service.dart';
import 'package:health_care/services/doctors_service.dart';
import 'package:health_care/services/specialities_service.dart';
import 'package:health_care/services/theme_service.dart';
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
  final ThemeService themeService = ThemeService();
  final ClinicsService clinicsService = ClinicsService();
  final SpecialitiesService specialitiesService = SpecialitiesService();
  final DoctorsService doctorsService = DoctorsService();
  late final AnimationController _controller = AnimationController(vsync: this);
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // String homeThemeName = '';
  // String homeThemeType = '';
  // String homeActivePage = '';

  @override
  void initState() {
    super.initState();
    themeService.getThemeFromAdmin(context);
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
          var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;
          var homeThemeType = Provider.of<ThemeProvider>(context).homeThemeType;
          var homeActivePage =
              Provider.of<ThemeProvider>(context).homeActivePage;
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
    skipNulls<T>(List<Clinics> items) {
      return items..removeWhere((item) => !item.active);
    }

    CarouselSlider clinicsScrollView = CarouselSlider(
      options: CarouselOptions(
        height: 300.0,
        autoPlay: false,
        enlargeCenterPage: true,
      ),
      items: skipNulls(clinics).map((i) {
        return Builder(
          builder: (BuildContext context) {
            final name = context.tr(i.name);
            final imagee = i.image;
            final hasThemeImage = i.hasThemeImage;
            var homeThemeName =
                Provider.of<ThemeProvider>(context).homeThemeName;
            final primaryColorCode = primaryColorCodeReturn(homeThemeName);
            final imageSrc = hasThemeImage
                ? '$webUrl${imagee.replaceAll('primaryMain', primaryColorCode)}'
                : '$webUrl$imagee';
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                  elevation: 5.0,
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.all(0),
                  child: InkWell(
                     splashColor: Theme.of(context).primaryColor,
                    onTap: () {
                      Navigator.pushNamed(context, i.href);
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: 25,
                          child: ListTile(
                            title: Text(name),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // color: Colors.amber,
                            margin: const EdgeInsets.only(
                              top: 20,
                              bottom: 10,
                            ),
                            height: 200,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageSrc,
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            );
          },
        );
      }).toList(),
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

    CarouselSlider bestDoctorsScrollView = CarouselSlider(
      items: doctors.map((i) {
        return Builder(
          builder: (BuildContext context) {
            var subheading = context.tr(i.specialities[0].specialities);
            final name = "${i.firstName} ${i.lastName}";
            var cardImage = NetworkImage(i.profileImage.isEmpty
                ? 'http://admin-mjcode.ddns.net/assets/img/doctors/doctors_profile.jpg'
                : '${i.profileImage}?random=${DateTime.now().millisecondsSinceEpoch}');
            var supportingText = i.aboutMe;
            // print(cardImage);
            return SizedBox(
              height: 420,
              child: Card(
                elevation: 4.0,
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 70,
                      child: ListTile(
                        title: Text("Dr. $name"),
                        subtitle: Text(subheading),
                        trailing: const Icon(Icons.favorite_outline),
                      ),
                    ),
                    InkWell(
                      splashColor: Theme.of(context).hintColor,
                      onTap: () {
                        Navigator.pushNamed(context, 'i.href');
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        child: Ink.image(
                          image: cardImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        // height: 50,
                        padding: const EdgeInsets.only(left: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(supportingText),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
      options: CarouselOptions(
        autoPlay: false,
        enlargeCenterPage: true,
        viewportFraction: 1,
        aspectRatio: 2.0,
        initialPage: 1,
        height: 435,
      ),
    );
    
    return SilverScaffoldWrapper(
      title: 'findDoctor',
      children: Column(
        children: <Widget>[
          if (clinics.isNotEmpty) ...[
            ListTile(
              title: Text(context.tr('clinics')),
            ),
            clinicsScrollView
          ],
          if (specialities.isNotEmpty) ...[
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
            )
          ],
          if (doctors.isNotEmpty) ...[
            ListTile(
              title: Text(context.tr('bestDoctors')),
            ),
            bestDoctorsScrollView
          ],
        ],
      ),
    );
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
