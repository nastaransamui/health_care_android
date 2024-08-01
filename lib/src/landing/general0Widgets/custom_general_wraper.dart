import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/default_silver_app_bar.dart';
import 'package:health_care/src/commons/end_drawer.dart';
import 'package:health_care/src/commons/start_drawer.dart';
import 'package:provider/provider.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

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

class CustomGeneralWrapper extends StatefulWidget {
  const CustomGeneralWrapper({super.key});

  @override
  State<CustomGeneralWrapper> createState() => _CustomGeneralWrapperState();
}

class _CustomGeneralWrapperState extends State<CustomGeneralWrapper> {
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
      if (specialities.isNotEmpty) ...[SizedBox(width: MediaQuery.of(context).size.width / 1.2, height: 210, child: const SpecialitiesScrollView())],
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
    final List<String> titles = ['', '', '', '', '', '', '', ''];

    final List<Widget> images = [];
    for (var i = 0; i < general0Images.length; i++) {
      images.add(
        Card(
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
        child: Image.asset(
          general0Images[i],
          fit: BoxFit.contain,
        ),
      ));
    }
    
    return VerticalCardPager(
        titles: general0titles,
        images: images, // required
        textStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ), // optional
        onPageChanged: (page) {},
        onSelectedItem: (index) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RenderWidget(
                title: titles[index],
                children: renders[index],
              ),
            ),
          );
        },
        initialPage: 2, // optional
        align: ALIGN.CENTER, // optional
        physics: const ClampingScrollPhysics() // optional
        );
  }
}

class RenderWidget extends StatelessWidget {
  final String title;
  final Widget children;
  const RenderWidget({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const StartDrawer(),
      endDrawer: const EndDrawer(),
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 68),
        child: SafeArea(
          child: CustomAppBar(
            percent: 0,
            title: title,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: children,
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(double.maxFinite, 30),
                  elevation: 5.0,
                  foregroundColor: Theme.of(context).primaryColorLight,
                  animationDuration: const Duration(milliseconds: 1000),
                  backgroundColor: Theme.of(context).primaryColor,
                  shadowColor: Theme.of(context).primaryColor,
                ),
                child: Text(context.tr('goBack')),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(showLogin: true),
    );
  }
}
