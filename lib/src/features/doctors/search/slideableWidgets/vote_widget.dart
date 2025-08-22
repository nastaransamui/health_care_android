import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/doctors.dart';
import 'package:health_care/src/features/doctors/search/slideableWidgets/get_recommendation_percentage.dart';

class VoteWidget extends StatelessWidget {
  const VoteWidget({
    super.key,
    required this.singleDoctor,
  });

  final Doctors singleDoctor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: SizedBox.expand(
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8), right: Radius.circular(8)),
            border: Border.all(color: Theme.of(context).primaryColorLight),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                FaIcon(FontAwesomeIcons.thumbsUp, size: 12,color: Theme.of(context).primaryColor),
              Text(getRecommendationPercentageFromSingleDoctors(singleDoctor)),
              Text(
                "(${singleDoctor.recommendArray.length} ${context.tr('votes')})",
              )
            ],
          ),
        ),
      ),
    );
  }
}
