import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/doctors.dart';

class CheckAvailabilityWidget extends StatefulWidget {
  final Doctors singleDoctor;
  const CheckAvailabilityWidget({
    super.key,
    required this.singleDoctor,
  });

  @override
  State<CheckAvailabilityWidget> createState() => _CheckAvailabilityWidgetState();
}

class _CheckAvailabilityWidgetState extends State<CheckAvailabilityWidget> {
  Future<dynamic> checkAvailability(BuildContext context, Doctors singleDoctor) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      showDragHandle: true,
      barrierColor: Theme.of(context).cardColor.withAlpha((0.8 * 255).round()),
      constraints: BoxConstraints(
        maxHeight: double.infinity,
        minWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height / 5,
      ),
      scrollControlDisabledMaxHeightRatio: 1,
      builder: (context) {
        final availableSlots = singleDoctor.timeslots!.isNotEmpty ? singleDoctor.timeslots?.first.availableSlots ?? [] : [];
        String formatDate(DateTime date) {
          return DateFormat('dd MMM yyyy').format(date); // needs intl package
        }

        return Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: availableSlots.map((time) {
                final start = time.startDate;
                final end = time.finishDate;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'From: ${formatDate(start)}  to: ${formatDate(end)}',
                    style: const TextStyle(
                      fontSize: 16.0, // Constant font size
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(double.maxFinite, 30),
            elevation: 5.0,
            foregroundColor: Theme.of(context).primaryColorLight,
            backgroundColor: Theme.of(context).primaryColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(8),
                right: Radius.circular(8),
              ),
            ),
          ),
          onPressed: widget.singleDoctor.timeslots!.isEmpty
              ? null
              : () {
                  checkAvailability(context, widget.singleDoctor);
                },
          child: Text(
            context.tr('checkAvailability'),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
