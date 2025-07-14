
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/src/utils/is_due_date_passed.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class InlineBillPdfPreview extends StatelessWidget {
  const InlineBillPdfPreview({
    super.key,
    required this.bill,
    required this.isSameDoctor,
  });
  final Bills bill;
  final bool isSameDoctor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final dateFormat = DateFormat('dd MMM yyyy');
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    final String roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
    final PatientUserProfile? patientUserProfile = bill.patientProfile;
    final DoctorUserProfile doctorUserProfile = bill.doctorProfile;
    final String issueDay = dateFormat.format(tz.TZDateTime.from(bill.createdAt, bangkok));
    final String dueDate = dateFormat.format(bill.dueDate);
    final String invoiceId = bill.invoiceId;
    final String paymentType = bill.paymentType;
    final String paymentToken = bill.paymentToken;
    final String drName = "Dr.${doctorUserProfile.fullName}";
    final String drAddress = "${doctorUserProfile.address1}${doctorUserProfile.address1 != '' ? ', ' : ''} ${doctorUserProfile.address2}";
    final String drCity = doctorUserProfile.city.trim().isNotEmpty ? doctorUserProfile.city : '---';
    final String drState = doctorUserProfile.state.trim().isNotEmpty ? doctorUserProfile.state : '---';
    final String drCountry = doctorUserProfile.country.trim().isNotEmpty ? doctorUserProfile.country : '---';
    final String paName = "${patientUserProfile?.gender}${patientUserProfile?.gender != '' ? '.' : ''} ${patientUserProfile?.fullName}";
    final String paAddress = "${patientUserProfile?.address1} ${patientUserProfile?.address1 != '' ? ', ' : ''} ${patientUserProfile?.address2}";
    final String paCity = patientUserProfile!.city.trim().isNotEmpty ? patientUserProfile.city : '---';
    final String paState = patientUserProfile.state.trim().isNotEmpty ? patientUserProfile.state : '---';
    final String paCountry = patientUserProfile.country.trim().isNotEmpty ? patientUserProfile.country : '---';

// List of available keys in your BillingsDetails class
    final List<String> allKeys = [
      'title',
      'price',
      'bookingsFee',
      'bookingsFeePrice',
      'total',
    ];

// Filtered based on role
    final List<String> filteredKeys = allKeys.where((key) {
      if (roleName == 'patient' || !isSameDoctor) {
        return key == 'title' || key == 'total';
      } else {
        return key != 'amount';
      }
    }).toList();

// Column widths map dynamically based on number of columns
    final Map<int, TableColumnWidth> columnWidths = {
      for (int i = 0; i < filteredKeys.length; i++) i: const FlexColumnWidth(2),
    };
    columnWidths[0] = const FlexColumnWidth(4); // Make first column wider
    Widget buildDoctorPaymentStamp(String status) {
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
        case 'over due':
          borderColor = Colors.red[600]!; // Similar to #f44336
          text = context.tr('overDue');
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
          width: (MediaQuery.of(context).size.width / 2) + 40,
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
                // height: 842, // A4 height in points

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
                            Row(
                              children: [
                                Text(
                                  '${context.tr('issued')} :',
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                                SizedBox(width: context.locale.toString() == 'th_TH' ? 75 : 28),
                                Text(issueDay)
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '${context.tr('dueDate')} :',
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                                SizedBox(width: context.locale.toString() == 'th_TH' ? 40 : 15),
                                Text(dueDate)
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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
                              Text(
                                '${context.tr('address')} : $paAddress',
                                maxLines: 2,
                                softWrap: true,
                              ),
                              Text('${context.tr('city')} : $paCity'),
                              Text('${context.tr('state')} : $paState'),
                              Text('${context.tr('country')} : $paCountry'),
                            ],
                          ),
                        ),
                        //Third column payment information
                        // Payment Information
                        if (bill.status == 'Paid') ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('paymentInformation'),
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(paymentType),
                                Text(paymentToken),
                                Text(DateFormat('dd MMM yyyy HH:mm').format(tz.TZDateTime.from(bill.paymentDate, bangkok)))
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        // Invoice Items Table
                        Table(
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: theme.primaryColor,
                              width: 0.5,
                            ),
                          ),
                          columnWidths: columnWidths,
                          children: [
                            TableRow(
                              children: filteredKeys.asMap().entries.map((entry) {
                                final int index = entry.key;
                                final String key = entry.value;

                                // Convert key to display label
                                final String label = key == 'bookingsFee'
                                    ? 'Percent'
                                    : key == 'bookingsFeePrice'
                                        ? 'Fee Price'
                                        : '${key[0].toUpperCase()}${key.substring(1)}';

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                                  child: Text(
                                    context.tr(label),
                                    textAlign: index == 0 ? TextAlign.left : TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            ...bill.billDetailsArray.map(
                              (item) {
                                // Filter keys again (in case reused separately)
                                final filteredKeys = roleName == 'patient' || !isSameDoctor
                                    ? ['title', 'total']
                                    : ['title', 'price', 'bookingsFee', 'bookingsFeePrice', 'total'];

                                return TableRow(children: [
                                  ...filteredKeys.asMap().entries.map(
                                    (entry) {
                                      final int index = entry.key;
                                      final String key = entry.value;
                                      // Extract value based on key
                                      String value = '';
                                      switch (key) {
                                        case 'title':
                                          value = item.title;
                                          break;
                                        case 'price':
                                          value = "${NumberFormat("#,##0.00", "en_US").format(item.price)} ${bill.currencySymbol}";
                                          break;
                                        case 'bookingsFee':
                                          value = '${item.bookingsFee.toStringAsFixed(0)} %';
                                          break;
                                        case 'bookingsFeePrice':
                                          value = "${NumberFormat("#,##0.00", "en_US").format(item.bookingsFeePrice)} ${bill.currencySymbol}";
                                          break;
                                        case 'total':
                                          value = "${NumberFormat("#,##0.00", "en_US").format(item.total)} ${bill.currencySymbol}";
                                          break;
                                        default:
                                          value = '-';
                                      }
                                      return Padding(
                                          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0, left: 8.0),
                                          child: Text(
                                            value,
                                            textAlign: index == 0 ? TextAlign.left : TextAlign.center,
                                            style: TextStyle(
                                              color: textColor,
                                            ),
                                          ));
                                    },
                                  )
                                ]);
                              },
                            )
                          ],
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;

                            return Row(
                              children: [
                                SizedBox(
                                  width: width * 0.5,
                                  child: buildDoctorPaymentStamp(bill.status != 'Paid' && isDueDatePassed(dueDate) ? 'Over Due' : bill.status),
                                ),
                                Container(
                                  width: width * 0.5,
                                  alignment: Alignment.topRight,
                                  child: Table(
                                    border: TableBorder(
                                      bottom: BorderSide(color: theme.primaryColor, width: 0.5),
                                       top: BorderSide(color: theme.primaryColor, width: 0.5),
                                    ),
                                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                    children: [
                                      if (roleName == 'doctors' && isSameDoctor) ...[
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                '${context.tr('totalPrice')} :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.primaryColor,
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 4.0, top: 6.0),
                                                child: Text(
                                                  '${NumberFormat("#,##0.0", "en_US").format(bill.price)} ${bill.currencySymbol} ',
                                                  style:
                                                      TextStyle(fontSize: NumberFormat("#,##0.0", "en_US").format(bill.price).length > 15 ? 12 : 14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (roleName == 'doctors' && isSameDoctor) ...[
                                        TableRow(
                                          decoration:
                                              BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: theme.primaryColor, width: 0.5))),
                                          
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                '${context.tr('totalFeePrice')} :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.primaryColor,
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 4.0, top: 6.0),
                                                child: Text(
                                                  '${NumberFormat("#,##0.0", "en_US").format(bill.bookingsFeePrice)} ${bill.currencySymbol} ',
                                                  style: TextStyle(
                                                      fontSize: NumberFormat("#,##0.0", "en_US").format(bill.bookingsFeePrice).length > 15 ? 12 : 14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              '${context.tr('totalAmount')} :',
                                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                                            ),
                                          ),
                                          Align(
                                            alignment: !isSameDoctor && roleName == 'doctors' ? Alignment.centerLeft : Alignment.centerRight,
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 8.0, top: 6.0),
                                              child: Transform.translate(
                                                offset: Offset(roleName != 'doctors' ? -43 : !isSameDoctor && roleName == 'doctors' ? 10 : 5, 0),
                                                child: Text(
                                                  '${NumberFormat("#,##0.0", "en_US").format(bill.total)} ${bill.currencySymbol} ',
                                                  style:
                                                      TextStyle(fontSize: NumberFormat("#,##0.0", "en_US").format(bill.total).length > 15 ? 11 : 14),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // SizedBox(height: context.locale.toString() == 'th_TH' ? 100 : 150),
                        SizedBox(
                          height: _calculateDynamicSpacing(bill.billDetailsArray.length, context.locale.toString(), isSameDoctor),
                        ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateDynamicSpacing(int itemCount, String locale, bool isSameDoctor) {
    if (itemCount <= 1) {
      return isSameDoctor
          ? locale == 'th_TH'
              ? 120.0
              : 200.0
          : locale == 'th_TH'
              ? 190.0
              : 230.0;
    }
    if (itemCount == 2) {
      return isSameDoctor
          ? locale == 'th_TH'
              ? 100.0
              : 160.0
          : locale == 'th_TH'
              ? 140.0
              : 200.0;
    }
    if (itemCount == 3) {
      return isSameDoctor
          ? locale == 'th_TH'
              ? 65.0
              : 130.0
          : locale == 'th_TH'
              ? 120.0
              : 140.0;
    }
    if (itemCount == 4) {
      return isSameDoctor
          ? locale == 'th_TH'
              ? 15.0
              : 100.0
          : locale == 'th_TH'
              ? 100.0
              : 120.0;
    }
    if (itemCount == 5) {
      return isSameDoctor
          ? locale == 'th_TH'
              ? 10.0
              : 70.0
          : locale == 'th_TH'
              ? 50.0
              : 110.0;
    }
    return 60.0; // for 8 or more, fixed minimum
  }
}
