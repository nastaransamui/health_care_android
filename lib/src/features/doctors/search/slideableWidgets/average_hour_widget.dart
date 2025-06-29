
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/doctors.dart';

class AverageHourWidget extends StatelessWidget {
  const AverageHourWidget({
    super.key,
    required this.singleDoctor,
  });

  final Doctors singleDoctor;

  @override
  Widget build(BuildContext context) {
    final timeslots = singleDoctor.timeslots;
    final averageHourlyPrice = (timeslots != null && timeslots.isNotEmpty) ? timeslots.first.averageHourlyPrice : null;

    final String averageHour = (averageHourlyPrice != null) ? NumberFormat("#,##0", "en_US").format(averageHourlyPrice) : '--';
    final String currency = (singleDoctor.currency.isNotEmpty) ? singleDoctor.currency[0].currency : '';
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
              FaIcon(FontAwesomeIcons.moneyBill, size: 12, color: Theme.of(context).primaryColor),
              Text(context.tr('averagePrice')),
              Text('$averageHour $currency'),
            ],
          ),
        ),
      ),
    );
  }
}
