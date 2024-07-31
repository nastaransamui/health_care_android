import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FrequentlyAskedQuestions extends StatefulWidget {
  const FrequentlyAskedQuestions({
    super.key,
  });
  static const headerStyle = TextStyle(
    fontSize: 18,
  );
  static const contentStyleHeader = TextStyle(color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.w700);
  static const contentStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  @override
  State<FrequentlyAskedQuestions> createState() => _FrequentlyAskedQuestionsState();
}

class _FrequentlyAskedQuestionsState extends State<FrequentlyAskedQuestions> with SingleTickerProviderStateMixin {
  var isSearchOpen = true;
  var isCheckDoctorProfileOpen = false;
  var isScheduleAppointmentOpen = false;
  var isSolutionOpen = false;
  @override
  Widget build(BuildContext context) {
    final loremIpsum = context.tr('lorem');

    return Accordion(
      disableScrolling: true,
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
            child: isSearchOpen
                ? FaIcon(
                    FontAwesomeIcons.minus,
                    color: Theme.of(context).primaryColor,
                  )
                : FaIcon(
                    FontAwesomeIcons.plus,
                    color: Theme.of(context).primaryColorLight,
                  ),
          ),
          header: Text(context.tr('faq1'), style: FrequentlyAskedQuestions.headerStyle),
          content: Text(loremIpsum, style: FrequentlyAskedQuestions.contentStyle),
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
            child: isCheckDoctorProfileOpen
                ? FaIcon(
                    FontAwesomeIcons.minus,
                    color: Theme.of(context).primaryColor,
                  )
                : FaIcon(
                    FontAwesomeIcons.plus,
                    color: Theme.of(context).primaryColorLight,
                  ),
          ),
          header: Text(context.tr('faq2'), style: FrequentlyAskedQuestions.headerStyle),
          content: Text(loremIpsum, style: FrequentlyAskedQuestions.contentStyle),
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
            child: isScheduleAppointmentOpen
                ? FaIcon(
                    FontAwesomeIcons.minus,
                    color: Theme.of(context).primaryColor,
                  )
                : FaIcon(
                    FontAwesomeIcons.plus,
                    color: Theme.of(context).primaryColorLight,
                  ),
          ),
          header: Text(context.tr('faq3'), style: FrequentlyAskedQuestions.headerStyle),
          content: Text(loremIpsum, style: FrequentlyAskedQuestions.contentStyle),
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
            child: isSolutionOpen
                ? FaIcon(
                    FontAwesomeIcons.minus,
                    color: Theme.of(context).primaryColor,
                  )
                : FaIcon(
                    FontAwesomeIcons.plus,
                    color: Theme.of(context).primaryColorLight,
                  ),
          ),
          header: Text(context.tr('faq4'), style: FrequentlyAskedQuestions.headerStyle),
          content: Text(loremIpsum, style: FrequentlyAskedQuestions.contentStyle),
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
