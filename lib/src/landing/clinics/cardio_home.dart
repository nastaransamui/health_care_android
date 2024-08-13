import 'package:flutter/material.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/src/commons/page_scaffold_wrapper.dart';
import 'package:health_care/src/landing/clinics/cardioWidgets/cardio_home_appointment.dart';
import 'package:health_care/src/landing/clinics/cardioWidgets/cardio_home_banner.dart';
import 'package:health_care/src/landing/clinics/cardioWidgets/cardio_home_condition.dart';
import 'package:health_care/src/landing/clinics/cardioWidgets/cardio_home_faq.dart';
import 'package:health_care/src/landing/clinics/cardioWidgets/cardio_home_our_services.dart';
import 'package:health_care/src/landing/clinics/cardioWidgets/cardio_home_pricing.dart';
import 'package:health_care/src/landing/clinics/cardioWidgets/cardio_home_specialist.dart';
import 'package:health_care/src/landing/clinics/cardioWidgets/cardio_home_steps.dart';
import 'package:health_care/src/landing/clinics/cardioWidgets/cardio_home_testimonial.dart';
import 'package:health_care/src/landing/clinics/cardioWidgets/cardio_home_why_us.dart';
import 'package:health_care/theme_config.dart';
import 'package:provider/provider.dart';

class CardioHome extends StatefulWidget {
  static const String routeName = '/cardiohome';
  const CardioHome({super.key});

  @override
  State<CardioHome> createState() => _CardioHomeState();
}

class _CardioHomeState extends State<CardioHome> {
  bool homeBannervisible = false;
  final double cardioHomeBannerHeight = 350.0;
  final double cardioHomeWhyUsHeight = 300;
  final double cardioHomeOurServicesHeight = 530;
  late double cardioHomeConditionHeight;
  final double cardioHomeSpecialistHeight = 430;
  final double cardioHomeStepsHeight = 430;
  final double cardioHomeTestimonialHeight = 400;
  final double cardioHomeApointmentHeight = 300;
  final double cardioHomePricingHeight = 700;
  final double cardioHomeFAQHeight = 600;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      homeBannervisible = true;
      setState(() {});
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    cardioHomeConditionHeight = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  double componentsHeight() {
    return cardioHomeBannerHeight +
        cardioHomeWhyUsHeight +
        cardioHomeOurServicesHeight +
        cardioHomeConditionHeight +
        cardioHomeSpecialistHeight +
        cardioHomeStepsHeight +
        cardioHomeTestimonialHeight +
        cardioHomeApointmentHeight +
        cardioHomePricingHeight +
        cardioHomeFAQHeight +
        (MediaQuery.of(context).size.height < 700 ? 600 : 450);
  }

  @override
  Widget build(BuildContext context) {
    var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;
    String primaryColor = primaryColorCodeReturn(homeThemeName);
    print(MediaQuery.of(context).size.height);
    return PageScaffoldWrapper(
      title: 'apptitle',
      children: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: componentsHeight(),
          child: Stack(
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    alignment: Alignment.bottomLeft,
                    image: NetworkImage("http://web-mjcode.ddns.net/assets/images/bg/home-10-banner_$primaryColor.png", scale: 1),
                    fit: BoxFit.fitHeight,
                  )),
                ),
              ),
              CardioHomeBanner(homeBannervisible: homeBannervisible, cardioHomeBannerHeight: cardioHomeBannerHeight),
              CardioHomeWhyUs(homeBannervisible: homeBannervisible, homeThemeName: homeThemeName, cardioHomeWhyUsHeight: cardioHomeWhyUsHeight),
              CardioHomeOurServices(
                homeBannervisible: homeBannervisible,
                homeThemeName: homeThemeName,
                cardioHomeOurServicesHeight: cardioHomeOurServicesHeight,
              ),
              CardioHomeCondition(cardioHomeConditionHeight: cardioHomeConditionHeight),
              Positioned(
                bottom: cardioHomeSpecialistHeight / 2,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    height: cardioHomeSpecialistHeight,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        alignment: Alignment.centerLeft,
                        image: NetworkImage("http://web-mjcode.ddns.net/assets/images/bg/hexagen-group-1.png", scale: 1),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              ),
              CardioHomeSpecialist(cardioHomeSpecialistHeight: cardioHomeSpecialistHeight),
              CardioHomeSteps(
                cardioHomeStepsHeight: cardioHomeStepsHeight,
                componentsHeight: componentsHeight(),
              ),
              CardioHomeTestimonial(
                cardioHomeTestimonialHeight: cardioHomeTestimonialHeight,
                componentsHeight: componentsHeight(),
              ),
              CardioHomeApointment(cardioHomeApointmentHeight: cardioHomeApointmentHeight),
              CardioHomePricing(
                cardioHomePricingHeight: cardioHomePricingHeight,
                homeThemeName: homeThemeName,
              ),
              CardioHomeFaq(cardioHomeFAQHeight: cardioHomeFAQHeight),
            ],
          ),
        ),
      ),
    );
  }
}
