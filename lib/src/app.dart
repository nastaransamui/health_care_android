// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math' as math;
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/controllers/theme_controller.dart';
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
import 'package:flutter/gestures.dart';

class MyApp extends StatefulWidget {
  final StreamSocket streamSocket;
  final ThemeController controller;
  const MyApp({
    super.key,
    required this.streamSocket,
    required this.controller,
  });

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
            theme: themDataLive(
                homeThemeName.isEmpty
                    ? widget.controller.homeThemeName
                    : homeThemeName,
                homeThemeType.isEmpty
                    ? widget.controller.homeThemeType
                    : homeThemeType),
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

    final isCollapsed = ValueNotifier<bool>(true);
    CarouselSlider clinicsScrollView = CarouselSlider(
      options: CarouselOptions(
        height: 300.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: skipNulls(clinics).map((i) {
        return Builder(
          builder: (BuildContext context) {
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
                      Navigator.pushNamed(context, i.href);
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: 25,
                          child: ListTile(
                            title: Text(context.tr(i.href)),
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
    CarouselSlider specialitiesScrollView = CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 2.0,
        enlargeCenterPage: true,
        scrollDirection: Axis.vertical,
        autoPlay: true,
      ),
      items: specialities.map((i) {
        final name = context.tr(i.specialities);
        final imageSrc = i.image;
        final imageIsSvg = imageSrc.endsWith('.svg');
        final numberOfDoctors = i.usersId.length;
        var brightness = Theme.of(context).brightness;
        return Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Theme.of(context).primaryColorLight, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 5.0,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            splashColor: Theme.of(context).primaryColor,
            onTap: () {
              // Navigator.pushNamed(context, i.href);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
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
                ),
                Expanded(
                  child: ListTile(
                    textColor: brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text('doctorsNumber').plural(
                      numberOfDoctors,
                      format: NumberFormat.compact(
                        locale: context.locale.toString(),
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_right)
              ],
            ),
          ),
        );
      }).toList(),
    );

    ValueListenableBuilder bestDoctorsScrollView = ValueListenableBuilder(
        valueListenable: isCollapsed,
        builder: (context, value, child) {
          return CarouselSlider(
            items: doctors.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  var subheading = context.tr(i.specialities[0].specialities);
                  final name = "${i.firstName} ${i.lastName}";
                  var cardImage = NetworkImage(i.profileImage.isEmpty
                      ? 'http://admin-mjcode.ddns.net/assets/img/doctors/doctors_profile.jpg'
                      : '${i.profileImage}?random=${DateTime.now().millisecondsSinceEpoch}');
                  var supportingText = i.aboutMe;
                  print(supportingText.length);
                  return SizedBox(
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).primaryColorLight,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
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
                              padding: const EdgeInsets.only(
                                left: 16.0,
                              ),
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: supportingText.length <= 240
                                          ? supportingText
                                          : supportingText.substring(0, 240),
                                    ),
                                    if (supportingText.length >= 240) ...[
                                      TextSpan(
                                          text: value
                                              ? ' ...Read more'
                                              : 'Read less',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              isCollapsed.value =
                                                  !isCollapsed.value;
                                              showModalBottomSheet(
                                                context: context,
                                                useSafeArea: true,
                                                isDismissible: false,
                                                showDragHandle: true,
                                                constraints:
                                                    const BoxConstraints(
                                                  maxHeight: double.infinity,
                                                ),
                                                scrollControlDisabledMaxHeightRatio:
                                                    1,
                                                builder: (context) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      supportingText,
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style: const TextStyle(
                                                        fontSize: 18.0,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).whenComplete(() {
                                                isCollapsed.value =
                                                    !isCollapsed.value;
                                              });
                                            })
                                    ],
                                  ],
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
            options: CarouselOptions(
              autoPlay: false,
              enlargeCenterPage: true,
              viewportFraction: 1,
              aspectRatio: 2.0,
              initialPage: 1,
              height: 450,
            ),
          );
        });

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
              width: MediaQuery.of(context).size.width / 1.2,
              height: 210,
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
          ListTile(
            title: Text(context.tr('howItsWork')),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/work-img.png'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
              ),
              child: SizedBox(
                height: 400,
                width: MediaQuery.of(context).size.width,
                child: const CustomAccordion(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomAccordion extends StatefulWidget {
  const CustomAccordion({super.key});
  static const headerStyle = TextStyle(
    fontSize: 18,
  );
  static const contentStyleHeader = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.w700);
  static const contentStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  @override
  State<CustomAccordion> createState() => _CustomAccordionState();
}

class _CustomAccordionState extends State<CustomAccordion> {
  var isSearchOpen = false;
  var isCheckDoctorProfileOpen = false;
  var isScheduleAppointmentOpen = false;
  var isSolutionOpen = false;
  @override
  Widget build(BuildContext context) {
    final loremIpsum = context.tr('lorem');

    return Accordion(
      headerBorderColor: Theme.of(context).primaryColor,
      headerBorderColorOpened: Theme.of(context).primaryColor,
      headerBackgroundColorOpened: Theme.of(context).primaryColorLight,
      contentBackgroundColor: Theme.of(context).cardColor,
      contentBorderColor: Theme.of(context).primaryColorLight,
      contentBorderWidth: 3,
      contentHorizontalPadding: 20,
      scaleWhenAnimating: true,
      openAndCloseAnimation: true,
      headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
      sectionClosingHapticFeedback: SectionHapticFeedback.heavy,
      flipRightIconIfOpen: true,
      paddingBetweenClosedSections: 25,
      children: [
        AccordionSection(
          isOpen: isSearchOpen,
          contentVerticalPadding: 20,
          rightIcon: Transform.rotate(
            angle: 180 * math.pi / 180,
            child: IconButton(
              icon: isSearchOpen
                  ? Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    )
                  : Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColorLight,
                      size: 20,
                    ),
              onPressed: null,
            ),
          ),
          leftIcon: Padding(
            padding: const EdgeInsets.only(
              top: 0.0,
              bottom: 0.0,
            ),
            child: SvgPicture.asset(
              'assets/icon/search_doctor.svg',
              width: 30,
              height: 30,
              fit: BoxFit.fitHeight,
              colorFilter: isSearchOpen
                  ? ColorFilter.mode(
                      Theme.of(context).primaryColor, BlendMode.srcIn)
                  : ColorFilter.mode(
                      Theme.of(context).primaryColorLight, BlendMode.srcIn),
            ),
          ),
          header: Text(context.tr('searchDoctor'),
              style: CustomAccordion.headerStyle),
          content: Text(loremIpsum, style: CustomAccordion.contentStyle),
          onOpenSection: () {
            setState(() {
              isSearchOpen = true;
              isCheckDoctorProfileOpen = false;
              isScheduleAppointmentOpen = false;
              isSolutionOpen = false;
            });
          },
          onCloseSection: () {
            setState(() {
              isSearchOpen = false;
              isCheckDoctorProfileOpen = false;
              isScheduleAppointmentOpen = false;
              isSolutionOpen = false;
            });
          },
        ),
        AccordionSection(
          isOpen: isCheckDoctorProfileOpen,
          contentVerticalPadding: 20,
          rightIcon: Transform.rotate(
            angle: 180 * math.pi / 180,
            child: IconButton(
              icon: isCheckDoctorProfileOpen
                  ? Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    )
                  : Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColorLight,
                      size: 20,
                    ),
              onPressed: null,
            ),
          ),
          leftIcon: Padding(
            padding: const EdgeInsets.only(
              top: 0.0,
              bottom: 0.0,
            ),
            child: SvgPicture.asset(
              'assets/icon/profile_doctor.svg',
              width: 30,
              height: 30,
              fit: BoxFit.fitHeight,
              colorFilter: isCheckDoctorProfileOpen
                  ? ColorFilter.mode(
                      Theme.of(context).primaryColor, BlendMode.srcIn)
                  : ColorFilter.mode(
                      Theme.of(context).primaryColorLight, BlendMode.srcIn),
            ),
          ),
          header: Text(context.tr('checkDoctorProfile'),
              style: CustomAccordion.headerStyle),
          content: Text(loremIpsum, style: CustomAccordion.contentStyle),
          onOpenSection: () {
            setState(() {
              isCheckDoctorProfileOpen = true;
              isSearchOpen = false;
              isScheduleAppointmentOpen = false;
              isSolutionOpen = false;
            });
          },
          onCloseSection: () {
            setState(() {
              isCheckDoctorProfileOpen = false;
              isSearchOpen = false;
              isScheduleAppointmentOpen = false;
              isSolutionOpen = false;
            });
          },
        ),
        AccordionSection(
          isOpen: isScheduleAppointmentOpen,
          contentVerticalPadding: 20,
          rightIcon: Transform.rotate(
            angle: 180 * math.pi / 180,
            child: IconButton(
              icon: isScheduleAppointmentOpen
                  ? Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    )
                  : Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColorLight,
                      size: 20,
                    ),
              onPressed: null,
            ),
          ),
          leftIcon: Padding(
            padding: const EdgeInsets.only(
              top: 0.0,
              bottom: 0.0,
            ),
            child: SvgPicture.asset(
              'assets/icon/schedule_doctor.svg',
              width: 30,
              height: 30,
              fit: BoxFit.fitHeight,
              colorFilter: isScheduleAppointmentOpen
                  ? ColorFilter.mode(
                      Theme.of(context).primaryColor, BlendMode.srcIn)
                  : ColorFilter.mode(
                      Theme.of(context).primaryColorLight, BlendMode.srcIn),
            ),
          ),
          header: Text(context.tr('scheduleAppointment'),
              style: CustomAccordion.headerStyle),
          content: Text(loremIpsum, style: CustomAccordion.contentStyle),
          onOpenSection: () {
            setState(() {
              isCheckDoctorProfileOpen = false;
              isSearchOpen = false;
              isScheduleAppointmentOpen = true;
              isSolutionOpen = false;
            });
          },
          onCloseSection: () {
            setState(() {
              isCheckDoctorProfileOpen = false;
              isSearchOpen = false;
              isScheduleAppointmentOpen = false;
              isSolutionOpen = false;
            });
          },
        ),
        AccordionSection(
          isOpen: isSolutionOpen,
          contentVerticalPadding: 20,
          rightIcon: Transform.rotate(
            angle: 180 * math.pi / 180,
            child: IconButton(
              icon: isSolutionOpen
                  ? Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    )
                  : Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColorLight,
                      size: 20,
                    ),
              onPressed: null,
            ),
          ),
          leftIcon: Padding(
            padding: const EdgeInsets.only(
              top: 0.0,
              bottom: 0.0,
            ),
            child: SvgPicture.asset(
              'assets/icon/solution_doctor.svg',
              width: 30,
              height: 30,
              fit: BoxFit.fitHeight,
              colorFilter: isSolutionOpen
                  ? ColorFilter.mode(
                      Theme.of(context).primaryColor, BlendMode.srcIn)
                  : ColorFilter.mode(
                      Theme.of(context).primaryColorLight, BlendMode.srcIn),
            ),
          ),
          header: Text(context.tr('getSolution'),
              style: CustomAccordion.headerStyle),
          content: Text(loremIpsum, style: CustomAccordion.contentStyle),
          onOpenSection: () {
            setState(() {
              isCheckDoctorProfileOpen = false;
              isSearchOpen = false;
              isScheduleAppointmentOpen = false;
              isSolutionOpen = true;
            });
          },
          onCloseSection: () {
            setState(() {
              isCheckDoctorProfileOpen = false;
              isSearchOpen = false;
              isScheduleAppointmentOpen = false;
              isSolutionOpen = false;
            });
          },
        ),
      ],
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
