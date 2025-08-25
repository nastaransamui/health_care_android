import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_slidable_panel/controllers/slide_controller.dart';
import 'package:health_care/models/doctors.dart';
import 'package:share_plus/share_plus.dart';

class DoctorSearchShareIconWidget extends StatelessWidget {
  const DoctorSearchShareIconWidget({
    super.key,
    required this.slideController,
    required this.singleDoctor,
  });
  final SlideController slideController;
  final Doctors singleDoctor;

  @override
  Widget build(BuildContext context) {
    final encodedId = base64.encode(utf8.encode(singleDoctor.id.toString()));
    return TextButton(
      onPressed: () async {
        slideController.toggleAction(1);
        final result = await SharePlus.instance.share(
          ShareParams(text: 'check out Dr. ${singleDoctor.fullName} ${dotenv.env['webUrl']}/doctors/profile/$encodedId'),
        );
        if (result.status == ShareResultStatus.dismissed) {
          slideController.toggleAction(1);
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).primaryColorLight,
        shape: const RoundedRectangleBorder(),
        splashFactory: NoSplash.splashFactory,
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.share), Text('')],
      ),
    );
  }
}
