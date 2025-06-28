import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/doctors.dart';

class BookingWidget extends StatefulWidget {
  final Doctors singleDoctor;
  const BookingWidget({
    super.key,
    required this.singleDoctor,
  });

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
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
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColorLight,
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
                  final encodeddoctorId = base64.encode(utf8.encode(widget.singleDoctor.id.toString()));
                  context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
                },
          child: Text(
            context.tr('bookAppointment'),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
