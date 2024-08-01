

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/providers/clinics_provider.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/search_card.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/landing/defaultWidgets/best_doctor_scroll_view.dart';
import 'package:health_care/src/landing/defaultWidgets/clinics_scroll_view.dart';
import 'package:health_care/src/landing/defaultWidgets/frequently_asked_questions.dart';
import 'package:health_care/src/landing/defaultWidgets/how_work_accordion.dart';
import 'package:health_care/src/landing/defaultWidgets/latest_articles.dart';
import 'package:health_care/src/landing/defaultWidgets/specialities_scroll_view.dart';
import 'package:health_care/src/landing/defaultWidgets/testimonial.dart';
import 'package:health_care/src/landing/general0Widgets/custom_general_wraper.dart';
import 'package:onboarding_animation/onboarding_animation.dart';
import 'package:provider/provider.dart';
class CustomGeneral1Wrapper extends StatefulWidget {
  const CustomGeneral1Wrapper({super.key});

  @override
  State<CustomGeneral1Wrapper> createState() => _CustomGeneral1WrapperState();
}

class _CustomGeneral1WrapperState extends State<CustomGeneral1Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white.withOpacity(.9),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: OnBoardingAnimation(
          controller: PageController(initialPage: 1),
          pages: [
            _GetCardsContent(
              image: 'assets/images/general0/meetOurDoctors.jpg',
              cardContent: context.tr('meetOurDoctor'),
              index: 0,
            ),
            _GetCardsContent(
              image: 'assets/images/general0/clinic.jpg',
              cardContent: context.tr('clinics'),
              index: 1,
            ),
            _GetCardsContent(
              image: 'assets/images/general0/specialitiesAnime.jpg',
              cardContent: context.tr('specialities'),
              index: 2,
            ),
            _GetCardsContent(
              image: 'assets/images/general0/bestDoctors.jpg',
              cardContent: context.tr('bestDoctors'),
              index: 3,
            ),
            _GetCardsContent(
              image: 'assets/images/general0/howItsWorkAnime.jpg',
              cardContent: context.tr('howItsWork'),
              index: 4,
            ),
            _GetCardsContent(
              image: 'assets/images/general0/latestArticles.jpg',
              cardContent: context.tr('latestArticles'),
              index: 5,
            ),
            _GetCardsContent(
              image: 'assets/images/general0/faqAnime.jpg',
              cardContent: context.tr('getYourAnswer'),
              index: 6,
            ),
            _GetCardsContent(
              image: 'assets/images/general0/testimonialAnime.jpg',
              cardContent: context.tr('testimonial'),
              index: 7,
            ),
          ],
          indicatorDotHeight: 7.0,
          indicatorDotWidth: 7.0,
          indicatorType: IndicatorType.expandingDots,
          indicatorPosition: IndicatorPosition.bottomCenter,
          indicatorSwapType: SwapType.normal,
        ),
      ),
    );
  }
}

class _GetCardsContent extends StatefulWidget {
  final String image, cardContent;
  final int index;
  const _GetCardsContent({
    this.image = '',
    this.cardContent = '',
    this.index = 0,
  });

  @override
  State<_GetCardsContent> createState() => _GetCardsContentState();
}

class _GetCardsContentState extends State<_GetCardsContent> {
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
    final clinics = Provider.of<ClinicsProvider>(context).clinics;
    final specialities = Provider.of<SpecialitiesProvider>(context).specialities;
    final doctors = Provider.of<DoctorsProvider>(context).doctors;

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
      if (clinics.isNotEmpty) ...[
        const FadeinWidget(isCenter: false, child: ClinicsScrollView()),
      ],
      if (specialities.isNotEmpty) ...[
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.2,
          height: 210,
          child: const SpecialitiesScrollView(),
        ),
      ],
      if (doctors.isNotEmpty) ...[const BestDoctorsScrollView()],
      const HowWorkAccordion(),
      const LatestArticles(),
      const FrequentlyAskedQuestions(),
      SizedBox(
        height: 450,
        width: MediaQuery.of(context).size.width,
        child: const Testimonial(),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/icon/icon.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
            InkWell(
              splashColor: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RenderWidget(
                      title: widget.cardContent,
                      children: renders[widget.index],
                    ),
                  ),
                );
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).primaryColorLight,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Image.asset(widget.image, fit: BoxFit.fill,),
                ),
              ),
            ),
            Text(
              widget.cardContent,
              style: GoogleFonts.pacifico(fontSize: 30.0),
            ),
          ],
        ),
      ),
    );
  }
}
