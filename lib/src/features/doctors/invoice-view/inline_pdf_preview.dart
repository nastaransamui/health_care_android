import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class InlinePdfPreview extends StatelessWidget {
  const InlinePdfPreview({
    super.key,
    required this.reservation,
    // required this.userProfile,
  });
  final Reservation reservation;
  // final PatientUserProfile userProfile;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    final PatientUserProfile userProfile = reservation.patientProfile;
    final String paName = "${userProfile.gender}${userProfile.gender != '' ? '.' : ''} ${userProfile.fullName}";
    final String paAddress = "${userProfile.address1} ${userProfile.address1 != '' ? ', ' : ''} ${userProfile.address2}";
    final String paCity = userProfile.city;
    final String paState = userProfile.state;
    final String paCountry = userProfile.country;
    final String roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
    final String issueDay = dateFormat.format(tz.TZDateTime.from(reservation.createdDate, bangkok));
    final DoctorUserProfile doctorUserProfile = reservation.doctorProfile;
    final String drName = "Dr.${doctorUserProfile.fullName}";
    final String drAddress = "${doctorUserProfile.address1}${doctorUserProfile.address1 != '' ? ', ' : ''} ${doctorUserProfile.address2}";
    final String drCity = doctorUserProfile.city;
    final String drState = doctorUserProfile.state;
    final String drCountry = doctorUserProfile.country;
    final String invoiceId = reservation.invoiceId;
    final String doctorPaymentStatus = reservation.doctorPaymentStatus;
    final String selectedDate = dateFormat.format(tz.TZDateTime.from(reservation.selectedDate, bangkok));
    final TimeType timeSlot = reservation.timeSlot;
    final String paymentType = reservation.paymentType;
    final String paymentToken = reservation.paymentToken;
    return AspectRatio(
      aspectRatio: 1 / 1.41, // A4
      child: Container(
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              child: Container(
                width: 595, // A4 width in points (PDF standard)
                height: 842, // A4 height in points
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.primaryColorLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/icon/icon.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(children: [
                                Text(
                                  '${context.tr('invoiceId')} :',
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                                const SizedBox(width: 5),
                                Text(invoiceId),
                              ]),
                            ),
                            const SizedBox(height: 6),
                            Row(children: [
                              Text(
                                '${context.tr('issued')} :',
                                style: TextStyle(color: theme.primaryColor),
                              ),
                              SizedBox(width: context.locale.toString() == 'th_TH' ? 75 : 28),
                              Text(issueDay)
                            ]),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Second row information
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First Colum Dr information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('drInformation'),
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              //Dr name
                              Text('${context.tr('name')} : $drName'),
                              Text('${context.tr('address')} : $drAddress'),
                              Text('${context.tr('city')} : $drCity'),
                              Text('${context.tr('state')} : $drState'),
                              Text('${context.tr('country')} : $drCountry'),
                            ],
                          ),
                        ),
                        //Second column patient information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('patientInformation'),
                                style: TextStyle(color: theme.primaryColor, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text('${context.tr('name')} : $paName'),
                              Text('${context.tr('address')} : $paAddress'),
                              Text('${context.tr('city')} : $paCity'),
                              Text('${context.tr('state')} : $paState'),
                              Text('${context.tr('country')} : $paCountry'),
                            ],
                          ),
                        ),
                        //Third column payment information
                        // Payment Information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('paymentMethod'),
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(paymentType),
                              Text(paymentToken),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Third row table
                    Column(
                      children: [
                        // Invoice Items Table
                        Table(
                          border: TableBorder(
                            horizontalInside: BorderSide(color: theme.primaryColor, width: 0.5),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(4),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                          },
                          children: [
                            // Table Header
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                                  child: Text(
                                    context.tr('description'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                    child: Text(
                                      context.tr('quantity'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                    child: Text(
                                      context.tr('price'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        context.tr('total'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // First Item Row
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Text('$selectedDate - ${timeSlot.period}'),
                                ),
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text('1'),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      '${NumberFormat("#,##0.0", "en_US").format(timeSlot.price)} ${timeSlot.currencySymbol}',
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4, top: 6),
                                    child: Text(
                                      '${NumberFormat("#,##0.0", "en_US").format(timeSlot.price)} ${timeSlot.currencySymbol} ',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Booking Fee Row
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Text(context.tr('bookingsFee')),
                                ),
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 6.0),
                                    child: Text('1'),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      '${NumberFormat("#,##0.0", "en_US").format(timeSlot.bookingsFeePrice)} ${timeSlot.currencySymbol} ',
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4.0, top: 6.0),
                                    child: Text(
                                      '${NumberFormat("#,##0.0", "en_US").format(timeSlot.bookingsFeePrice)} ${timeSlot.currencySymbol} ',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Bottom Row: Stamp and Total Summary
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Stamp (if doctor)
                            if (roleName == 'doctors')
                              buildDoctorPaymentStamp(doctorPaymentStatus, context)
                            else
                              const Expanded(child: SizedBox(height: 100)),

                            // Right: Summary Table
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              alignment: Alignment.topRight,
                              child: Table(
                                border: TableBorder(
                                  horizontalInside: BorderSide(color: theme.primaryColor, width: 0.5),
                                ),
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        '${context.tr('subtotal')} :',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 4.0, top: 6.0),
                                        child: Text(
                                          '${NumberFormat("#,##0.0", "en_US").format(timeSlot.total)} ${timeSlot.currencySymbol} ',
                                        ),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        '${context.tr('discount')} :',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                                      ),
                                    ),
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 4.0, top: 6.0),
                                        child: Text('---'),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        '${context.tr('totalAmount')} :',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 4.0, top: 6.0),
                                        child: Text(
                                          '${NumberFormat("#,##0.0", "en_US").format(timeSlot.total)} ${timeSlot.currencySymbol} ',
                                        ),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                     SizedBox(height: context.locale.toString() == 'th_TH' ? 140.0 : 200.0),
                    //Footer
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('otherInformation'),
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('invoiceFooter'),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDoctorPaymentStamp(String status, BuildContext context) {
    // Normalize status (e.g., remove case sensitivity or trim)
    final normalized = status.trim().toLowerCase();

    // Define color and label
    Color borderColor;
    String text;

    switch (normalized) {
      case 'paid':
        borderColor = Colors.green[600]!; // Similar to #5BC236
          text = context.tr('paid');
        break;
      case 'awaiting request':
        borderColor = Colors.red[600]!; // Similar to #f44336
        text = context.tr('awaiting request');
        break;
      case 'pending':
        borderColor = Colors.orange[600]!; // Similar to #ffa500
          text = context.tr('pending');
        break;
      default:
        borderColor = Colors.grey;
        text = status.toUpperCase();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: SizedBox(
        width: 328,
        child: Transform.rotate(
          angle: 0.17,
          child: Align(
            alignment: Alignment.center, // or center, if you want it centered
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: borderColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
