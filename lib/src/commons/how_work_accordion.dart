


import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_svg/svg.dart';

class HowWorkAccordion extends StatefulWidget {
  const HowWorkAccordion({super.key,});
  static const headerStyle = TextStyle(
    fontSize: 18,
  );
  static const contentStyleHeader = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.w700);
  static const contentStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  @override
  State<HowWorkAccordion> createState() => _HowWorkAccordionState();
}

class _HowWorkAccordionState extends State<HowWorkAccordion> {
  var isSearchOpen = false;
  var isCheckDoctorProfileOpen = false;
  var isScheduleAppointmentOpen = false;
  var isSolutionOpen = false;
  @override
  Widget build(BuildContext context) {
    final loremIpsum = context.tr('lorem');

    return Accordion(
      disableScrolling:false,
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
              style: HowWorkAccordion.headerStyle),
          content: Text(loremIpsum, style: HowWorkAccordion.contentStyle),
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
              style: HowWorkAccordion.headerStyle),
          content: Text(loremIpsum, style: HowWorkAccordion.contentStyle),
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
              style: HowWorkAccordion.headerStyle),
          content: Text(loremIpsum, style: HowWorkAccordion.contentStyle),
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
              style: HowWorkAccordion.headerStyle),
          content: Text(loremIpsum, style: HowWorkAccordion.contentStyle),
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
