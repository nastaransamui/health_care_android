import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/providers/clinics_provider.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/services/user_data_service.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/silver_scaffold_wrapper.dart';
import 'package:health_care/src/landing/defaultWidgets/best_doctor_scroll_view.dart';
import 'package:health_care/src/landing/defaultWidgets/clinics_scroll_view.dart';
import 'package:health_care/src/landing/defaultWidgets/frequently_asked_questions.dart';
import 'package:health_care/src/landing/defaultWidgets/how_work_accordion.dart';
import 'package:health_care/src/landing/defaultWidgets/latest_articles.dart';
import 'package:health_care/src/landing/defaultWidgets/specialities_scroll_view.dart';
import 'package:health_care/src/landing/defaultWidgets/testimonial.dart';
import 'package:provider/provider.dart';

class Default extends StatefulWidget {
  static const String routeName = '/';
  const Default({
    super.key,
  });

  @override
  State<Default> createState() => _DefaultState();
}

class _DefaultState extends State<Default> {
  final UserDataService userDataService = UserDataService();

  @override
  void initState() {
    super.initState();
    userDataService.fetchUserData(context);
  }

  @override
  void dispose() {
    super.dispose(); // Always call super.dispose() at the end.
  }

  @override
  Widget build(BuildContext context) {
    final clinics = Provider.of<ClinicsProvider>(context).clinics;
    final specialities = Provider.of<SpecialitiesProvider>(context).specialities;
    final doctors = Provider.of<DoctorsProvider>(context).doctors;
    return SilverScaffoldWrapper(
      title: 'findDoctor',
      children: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (clinics.isNotEmpty) ...[
            ListTile(
              title: Text(context.tr('clinics')),
            ),
            const FadeinWidget(isCenter: false, child: ClinicsScrollView()),
          ],
          if (specialities.isNotEmpty) ...[
            ListTile(
              title: Text(context.tr('specialities')),
            ),
            SizedBox(width: MediaQuery.of(context).size.width / 1.2, height: 210, child: const SpecialitiesScrollView())
          ],
          if (doctors.isNotEmpty) ...[
            ListTile(
              title: Text(context.tr('bestDoctors')),
            ),
            const BestDoctorsScrollView()
          ],
          if (clinics.isNotEmpty) ...[
            ListTile(
              title: Text(context.tr('howItsWork')),
            ),
            Container(
              height: 500,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/work-img.png'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
              ),
              child: const HowWorkAccordion(),
            ),
          ],
          if (clinics.isNotEmpty) ...[
            ListTile(
              title: Text(context.tr('latestArticles')),
            ),
            SizedBox(
              height: 480,
              width: MediaQuery.of(context).size.width,
              child: const LatestArticles(),
            ),
          ],
          if (clinics.isNotEmpty) ...[
            ListTile(
              title: Text(context.tr('getYourAnswer')),
            ),
            Container(
              height: 500,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/faq-img.png'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
              ),
              child: const FrequentlyAskedQuestions(),
            ),
          ],
          if (clinics.isNotEmpty) ...[
            ListTile(
              title: Text(context.tr('testimonial')),
            ),
            SizedBox(
              height: 450,
              width: MediaQuery.of(context).size.width,
              child: const Testimonial(),
            ),
          ],
        ],
      ),
    );
  }
}
