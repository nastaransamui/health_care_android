import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/booking_information.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';

class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    super.key,
    required this.theme,
    required this.occupyTime,
  });

  final ThemeData theme;
  final OccupyTime occupyTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  context.tr('bookingSummary'),
                  style: TextStyle(fontSize: 20, color: theme.primaryColorLight),
                ),
              ),
              MyDivider(theme: theme),
              // date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('date'),
                      style: TextStyle(fontSize: 18, color: theme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM yyyy').format(occupyTime.selectedDate),
                  ),
                ],
              ),
              //Time
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('time'),
                        style: TextStyle(fontSize: 18, color: theme.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(occupyTime.timeSlot.period)
                  ],
                ),
              ),
              MyDivider(theme: theme),
              //consult fee
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('consultingFee'),
                      style: TextStyle(fontSize: 18, color: theme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text("${occupyTime.timeSlot.currencySymbol} ${NumberFormat("#,##0.00", "en_US").format(occupyTime.timeSlot.price)}"),
                ],
              ),
              // booking fee
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('bookingFee'),
                        style: TextStyle(fontSize: 18, color: theme.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text("${occupyTime.timeSlot.currencySymbol} ${NumberFormat("#,##0.00", "en_US").format(occupyTime.timeSlot.bookingsFeePrice)}"),
                  ],
                ),
              ),
              MyDivider(theme: theme),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('total'),
                      style: TextStyle(fontSize: 20, color: theme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text("${occupyTime.timeSlot.currencySymbol} ${NumberFormat("#,##0.00", "en_US").format(occupyTime.timeSlot.total)}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
