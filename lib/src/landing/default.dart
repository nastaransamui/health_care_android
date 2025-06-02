
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
  const Default({super.key});

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
  Widget build(BuildContext context) {
    return SilverScaffoldWrapper(
      title: 'findDoctor',
      children: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Consumer<ClinicsProvider>(
            builder: (_, provider, __) {
              final clinics = provider.clinics;
              final hasActiveClinic = clinics.any((clinic) => clinic.active == true);
              return clinics.isNotEmpty && hasActiveClinic ? _buildClinicsSection(context) : const SizedBox.shrink();
            },
          ),
          Consumer<SpecialitiesProvider>(
            builder: (_, provider, __) => provider.specialities.isNotEmpty ? _buildSpecialitiesSection(context) : const SizedBox.shrink(),
          ),
          Consumer<DoctorsProvider>(
            builder: (_, provider, __) => provider.doctors.isNotEmpty ? _buildDoctorsSection(context) : const SizedBox.shrink(),
          ),
          // Consumer<ClinicsProvider>(
          //   builder: (_, provider, __) =>
          //       provider.clinics.isNotEmpty ? _buildHowItWorksSection(context) : const SizedBox.shrink(),
          // ),
          _buildHowItWorksSection(context),
          // Consumer<ClinicsProvider>(
          //   builder: (_, provider, __) =>
          //       provider.clinics.isNotEmpty ? _buildLatestArticlesSection(context) : const SizedBox.shrink(),
          // ),
          _buildLatestArticlesSection(context),
          // Consumer<ClinicsProvider>(
          //   builder: (_, provider, __) =>
          //       provider.clinics.isNotEmpty ? _buildFAQSection(context) : const SizedBox.shrink(),
          // ),
          _buildFAQSection(context),
          // Consumer<ClinicsProvider>(
          //   builder: (_, provider, __) =>
          //       provider.clinics.isNotEmpty ? _buildTestimonialSection(context) : const SizedBox.shrink(),
          // ),
          _buildTestimonialSection(context)
        ],
      ),
    );
  }

  Widget _buildClinicsSection(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text(context.tr('clinics'))),
        const FadeinWidget(isCenter: false, child: ClinicsScrollView()),
      ],
    );
  }

  Widget _buildSpecialitiesSection(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text(context.tr('specialities'))),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.2,
          height: 210,
          child: const SpecialitiesScrollView(),
        ),
      ],
    );
  }

  Widget _buildDoctorsSection(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text(context.tr('bestDoctors'))),
        const BestDoctorsScrollView(),
      ],
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text(context.tr('howItsWork'))),
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
    );
  }

  Widget _buildLatestArticlesSection(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text(context.tr('latestArticles'))),
        SizedBox(
          height: 480,
          width: MediaQuery.of(context).size.width,
          child: const LatestArticles(),
        ),
      ],
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text(context.tr('getYourAnswer'))),
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
    );
  }

  Widget _buildTestimonialSection(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text(context.tr('testimonial'))),
        SizedBox(
          height: 450,
          width: MediaQuery.of(context).size.width,
          child: const Testimonial(),
        ),
      ],
    );
  }
}
