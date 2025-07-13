import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/reservation.dart';

class PaymentSuccessCard extends StatelessWidget {
  final Reservation reservation;

  const PaymentSuccessCard({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColorLight),
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: BoxBorder.all(color: theme.primaryColorLight),
                    color: theme.primaryColor,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 30,
                    color: textColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Center(
                  child: Text(
                    context.tr('appointmentBookedSuccessfuly'),
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: theme.primaryColor),
                  ),
                ),
              ),
              Center(
                child: Text(
                  // 'Appointment booked with  Dr. ${reservation.doctorProfile.fullName} \n on ${DateFormat('dd MMM yyyy').format(reservation.selectedDate)}  ${reservation.timeSlot.period} \nwith ${reservation.timeSlot.total} ${reservation.timeSlot.currencySymbol}',
                  context.tr('appointmentBreafData', args: [
                    (reservation.doctorProfile.fullName),
                    (DateFormat('dd MMM yyyy').format(reservation.selectedDate)),
                    reservation.timeSlot.period,
                    '${reservation.timeSlot.total}',
                    reservation.timeSlot.currencySymbol
                  ]),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Container(
                    height: 38,
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor,
                          theme.primaryColorLight,
                        ],
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(8),
                        right: Radius.circular(8),
                      ),
                    ),
                    padding: const EdgeInsets.all(1),
                    child: GestureDetector(
                      onTap: () {
                        final encodeddoctorId = base64.encode(utf8.encode(reservation.id.toString()));
                        context.push(Uri(path: '/doctors/invoice-view/$encodeddoctorId').toString());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColorLight,
                              theme.primaryColor,
                            ],
                          ),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(7),
                            right: Radius.circular(7),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            context.tr("viewInvoice"),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
