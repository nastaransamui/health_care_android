import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/default_silver_app_bar.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/search_card.dart';
import 'package:health_care/src/commons/end_drawer.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/start_drawer.dart';
import 'package:health_care/src/landing/defaultWidgets/best_doctor_scroll_view.dart';
import 'package:health_care/src/landing/defaultWidgets/clinics_scroll_view.dart';
import 'package:health_care/src/landing/defaultWidgets/frequently_asked_questions.dart';
import 'package:health_care/src/landing/defaultWidgets/how_work_accordion.dart';
import 'package:health_care/src/landing/defaultWidgets/latest_articles.dart';
import 'package:health_care/src/landing/defaultWidgets/specialities_scroll_view.dart';
import 'package:health_care/src/landing/defaultWidgets/testimonial.dart';
import 'package:health_care/src/landing/general0Widgets/custom_general_wraper.dart';

double cantainerHeight = 250.0;

class General2Page extends StatefulWidget {
  const General2Page({super.key});

  @override
  State<General2Page> createState() => _General2PageState();
}

class _General2PageState extends State<General2Page> {
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> renders = [
      SearchCard(
        specialitiesValue: specialitiesValue,
        genderValue: genderValue,
        countryValue: countryValue,
        stateValue: stateValue,
        cityValue: cityValue,
        updateFilterState: updateFilterState,
        resetFilterState: resetFilterState,
      ),
      const FadeinWidget(isCenter: false, child: ClinicsScrollView()),
      SizedBox(
        width: MediaQuery.of(context).size.width / 1.2,
        height: 210,
        child: const SpecialitiesScrollView(),
      ),
      const BestDoctorsScrollView(),
      const HowWorkAccordion(),
      const LatestArticles(),
      const FrequentlyAskedQuestions(),
      SizedBox(
        height: 450,
        width: MediaQuery.of(context).size.width,
        child: const Testimonial(),
      ),
    ];
    return Scaffold(
      drawer: const StartDrawer(),
      endDrawer: const EndDrawer(),
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 68),
        child: const SafeArea(
          child: CustomAppBar(
            percent: 0,
            title: 'appTitle',
          ),
        ),
      ),
      // body: SizedBox(width: MediaQuery.of(context).size.width, child: const Text('something')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              AnimationLeft(
                firstColor: Theme.of(context).primaryColorLight,
                secondColor: Theme.of(context).primaryColor,
                leftPosition: MediaQuery.of(context).size.width / 2.3,
                topPosition: 0.0,
                title: context.tr('meetOurDoctor'),
                icon: FontAwesomeIcons.userDoctor,
                renderWidget: renders[0],
              ),
              AnimationRight(
                firstColor: Theme.of(context).primaryColor,
                secondColor: Theme.of(context).primaryColorLight,
                rightPosition: MediaQuery.of(context).size.width / 2.3,
                topPosition: 0.0,
                title: context.tr('clinics'),
                icon: FontAwesomeIcons.houseChimneyMedical,
                renderWidget: renders[1],
              ),
              AnimationLeft(
                firstColor: Theme.of(context).primaryColor,
                secondColor: Theme.of(context).primaryColorLight,
                leftPosition: MediaQuery.of(context).size.width / 2.3,
                topPosition: cantainerHeight,
                title: context.tr('specialities'),
                icon: FontAwesomeIcons.tooth,
                renderWidget: renders[2],
              ),
              AnimationRight(
                firstColor: Theme.of(context).primaryColorLight,
                secondColor: Theme.of(context).primaryColor,
                rightPosition: MediaQuery.of(context).size.width / 2.3,
                topPosition: cantainerHeight,
                title: context.tr('bestDoctors'),
                icon: FontAwesomeIcons.syringe,
                renderWidget: renders[3],
              ),
              AnimationLeft(
                firstColor: Theme.of(context).primaryColorLight,
                secondColor: Theme.of(context).primaryColor,
                leftPosition: MediaQuery.of(context).size.width / 2.3,
                topPosition: cantainerHeight * 2,
                title: context.tr('howItsWork'),
                icon: FontAwesomeIcons.usersGear,
                renderWidget: renders[4],
              ),
              AnimationRight(
                firstColor: Theme.of(context).primaryColor,
                secondColor: Theme.of(context).primaryColorLight,
                rightPosition: MediaQuery.of(context).size.width / 2.3,
                topPosition: cantainerHeight * 2,
                title: context.tr('latestArticles'),
                icon: FontAwesomeIcons.newspaper,
                renderWidget: renders[5],
              ),
              AnimationLeft(
                firstColor: Theme.of(context).primaryColor,
                secondColor: Theme.of(context).primaryColorLight,
                leftPosition: MediaQuery.of(context).size.width / 2.3,
                topPosition: cantainerHeight * 3,
                title: context.tr('getYourAnswer'),
                icon: FontAwesomeIcons.circleQuestion,
                renderWidget: renders[6],
              ),
              AnimationRight(
                firstColor: Theme.of(context).primaryColorLight,
                secondColor: Theme.of(context).primaryColor,
                rightPosition: MediaQuery.of(context).size.width / 2.3,
                topPosition: cantainerHeight * 3,
                title: context.tr('testimonial'),
                icon: FontAwesomeIcons.houseChimneyMedical,
                renderWidget: renders[7],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(showLogin: true),
    );
  }
}

class AnimationLeft extends StatefulWidget {
  final Color firstColor;
  final Color secondColor;
  final double leftPosition;
  final double topPosition;
  final String title;
  final IconData icon;
  final Widget renderWidget;

  const AnimationLeft({
    super.key,
    required this.firstColor,
    required this.secondColor,
    required this.leftPosition,
    required this.topPosition,
    required this.title,
    required this.icon,
    required this.renderWidget,
  });

  @override
  State<AnimationLeft> createState() => _AnimationLeftState();
}

class _AnimationLeftState extends State<AnimationLeft> {
  bool selected = false;
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        selected = !selected;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: cantainerHeight * 4,
      child: Stack(
        children: <Widget>[
          AnimatedPositioned(
            width: selected ? MediaQuery.of(context).size.width / 2 : 50.0,
            height: selected ? cantainerHeight : 50.0,
            top: selected ? widget.topPosition : MediaQuery.of(context).size.height / 2.6,
            left: selected ? 0 : widget.leftPosition,
            duration: const Duration(seconds: 2),
            curve: Curves.fastOutSlowIn,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RenderWidget(
                        title: widget.title,
                        children: widget.renderWidget,
                      ),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: selected ? MediaQuery.of(context).size.width / 2 : 0.0,
                  height: selected ? cantainerHeight : 50.0,
                  decoration: BoxDecoration(
                    shape: selected ? BoxShape.rectangle : BoxShape.circle,
                  ),
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        // color: Theme.of(context).primaryColorLight,
                        color: selected ? widget.firstColor : widget.secondColor,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SizedBox(
                      height: cantainerHeight,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                color: widget.secondColor,
                                widget.icon,
                                size: 84,
                              ),
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.pacifico(fontSize: 20.0),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimationRight extends StatefulWidget {
  final Color firstColor;
  final Color secondColor;
  final double rightPosition;
  final double topPosition;
  final String title;
  final IconData icon;
  final Widget renderWidget;
  const AnimationRight({
    super.key,
    required this.firstColor,
    required this.secondColor,
    required this.rightPosition,
    required this.topPosition,
    required this.title,
    required this.icon,
    required this.renderWidget,
  });

  @override
  State<AnimationRight> createState() => _AnimationRightState();
}

class _AnimationRightState extends State<AnimationRight> {
  bool selected = false;
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        selected = !selected;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: cantainerHeight * 4,
      child: Stack(
        children: <Widget>[
          AnimatedPositioned(
            width: selected ? MediaQuery.of(context).size.width / 2 : 50.0,
            height: selected ? cantainerHeight : 50.0,
            top: selected ? widget.topPosition : MediaQuery.of(context).size.height / 2.6,
            right: selected ? 0 : widget.rightPosition + 4,
            duration: const Duration(seconds: 2),
            curve: Curves.fastOutSlowIn,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RenderWidget(
                        title: widget.title,
                        children: widget.renderWidget,
                      ),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: selected ? MediaQuery.of(context).size.width / 2 : 0.0,
                  height: selected ? cantainerHeight : 50.0,
                  decoration: BoxDecoration(
                    shape: selected ? BoxShape.rectangle : BoxShape.circle,
                  ),
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        // color: Theme.of(context).primaryColorLight,
                        color: selected ? widget.firstColor : widget.secondColor,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SizedBox(
                      height: cantainerHeight,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                color: widget.secondColor,
                                widget.icon,
                                size: 84,
                              ),
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.pacifico(fontSize: 20.0),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
