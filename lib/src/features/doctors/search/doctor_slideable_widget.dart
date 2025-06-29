
import 'package:flutter/material.dart';
import 'package:flutter_slidable_panel/controllers/slide_controller.dart';
import 'package:flutter_slidable_panel/delegates/action_layout_delegate.dart';
import 'package:flutter_slidable_panel/models.dart';
import 'package:flutter_slidable_panel/widgets/slidable_panel.dart';

import 'package:health_care/models/doctors.dart';
import 'package:health_care/src/features/doctors/search/doctor_card.dart';
import 'package:health_care/src/features/doctors/search/slideableWidgets/average_hour_widget.dart';

import 'package:health_care/src/features/doctors/search/slideableWidgets/booking_widget.dart';
import 'package:health_care/src/features/doctors/search/slideableWidgets/check_availability_widget.dart';
import 'package:health_care/src/features/doctors/search/slideableWidgets/doctor_search_fav_icon_widget.dart';
import 'package:health_care/src/features/doctors/search/slideableWidgets/doctor_search_share_icon_widget.dart';
import 'package:health_care/src/features/doctors/search/slideableWidgets/vote_widget.dart';

class DoctorSlideableWidget extends StatefulWidget {
  final Doctors doctor;
  final Future<void> Function() getDataOnUpdate;
  final bool isExpanded;
  final void Function(int index) onToggle;
  final int index;
  const DoctorSlideableWidget({
    super.key,
    required this.doctor,
    required this.getDataOnUpdate,
    required this.isExpanded,
    required this.onToggle,
    required this.index,
  });

  @override
  State<DoctorSlideableWidget> createState() => _DoctorSlideableWidgetState();
}

class _DoctorSlideableWidgetState extends State<DoctorSlideableWidget> {
  final SlideController slideController = SlideController(
    usePreActionController: true,
    usePostActionController: true,
  );
  @override
  void dispose() {
    slideController.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Doctors singleDoctor = widget.doctor;
    return SlidablePanel(
      controller: slideController,
      maxSlideThreshold: 0.5,
      axis: Axis.horizontal,
      preActionLayout: ActionLayout.spaceEvenly(ActionMotion.drawer),
      preActions: [
        DoctorSearchFavIconWidget(
          singleDoctor: singleDoctor,
          slideController: slideController,
        ),
        DoctorSearchShareIconWidget(
          slideController: slideController,
          singleDoctor: singleDoctor,
        ),
      ],
      postActions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: VoteWidget(singleDoctor: singleDoctor)),
              Expanded(child: AverageHourWidget(singleDoctor: singleDoctor)),
              BookingWidget(singleDoctor: singleDoctor),
              CheckAvailabilityWidget(singleDoctor: singleDoctor)
            ],
          ),
        )
      ],
      child: GestureDetector(
        onTap: () {
          slideController.dismiss();
        },
        child: DoctorCard(
          singleDoctor: singleDoctor,
          getDataOnUpdate: widget.getDataOnUpdate,
          isExpanded: widget.isExpanded,
          index: widget.index,
          onToggle: widget.onToggle,
        ),
      ),
    );
  }
}
