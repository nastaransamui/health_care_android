import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/src/utils/is_due_date_passed.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';

Future<pw.Document> buildBillPdf(BuildContext context, Bills bill, bool isSameDoctor) async {
  final theme = Theme.of(context);

  var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;

  final robotoRegular = pw.Font.ttf(await rootBundle.load('fonts/Roboto_Condensed/static/RobotoCondensed-Regular.ttf'));
  final robotoBold = pw.Font.ttf(await rootBundle.load('fonts/Roboto_Condensed/static/RobotoCondensed-Bold.ttf'));
  final sarabunLight = pw.Font.ttf(await rootBundle.load('fonts/Sarabun/Sarabun-Light.ttf'));
  final sarabunBold = pw.Font.ttf(await rootBundle.load('fonts/Sarabun/Sarabun-Bold.ttf'));

  final pdf = pw.Document();
  final dateFormat = DateFormat('dd MMM yyyy');
  final bangkok = tz.getLocation(dotenv.env['TZ']!);

  final imageBytes = await rootBundle.load('assets/icon/icon.png');
  final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
  final PatientUserProfile? patientUserProfile = bill.patientProfile;
  final DoctorUserProfile doctorUserProfile = bill.doctorProfile;

  final String issueDay = dateFormat.format(tz.TZDateTime.from(bill.createdAt, bangkok));
  final String dueDate = dateFormat.format(tz.TZDateTime.from(bill.dueDate, bangkok));
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
  final Map<int, pw.TableColumnWidth> columnWidths = {
    for (int i = 0; i < filteredKeys.length; i++) i: const pw.FlexColumnWidth(2),
  };
  columnWidths[0] = const pw.FlexColumnWidth(4); // Make first column wider

  pw.Widget buildDoctorPaymentStamp(String status) {
    // Normalize status (e.g., remove case sensitivity or trim)
    final normalized = status.trim().toLowerCase();

    // Define color and label
    PdfColor borderColor;
    String text;

    switch (normalized) {
      case 'paid':
        borderColor = PdfColors.green600; // Similar to #5BC236
        text = 'PAID';
        break;
      case 'over due':
        borderColor = PdfColors.red600; // Similar to #f44336
        text = 'Over Due';
        break;
      case 'pending':
        borderColor = PdfColors.orange600; // Similar to #ffa500
        text = 'PENDING';
        break;
      default:
        borderColor = PdfColors.grey;
        text = status.toUpperCase();
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 28.0),
      child: pw.Container(
        width: 310,
        child: pw.Transform.rotateBox(
          angle: 0.17,
          child: pw.Align(
            alignment: pw.Alignment.center, // or center, if you want it centered
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: borderColor, width: 3),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Text(
                text,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
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

  double calculateDynamicSpacing(int itemCount, String locale) {
    if (itemCount <= 1) return locale == 'th_TH' ? 190.0 : 230.0;
    if (itemCount == 2) return locale == 'th_TH' ? 140.0 : 200.0;
    if (itemCount == 3) return locale == 'th_TH' ? 120.0 : 140.0;
    if (itemCount == 4) return locale == 'th_TH' ? 100.0 : 120.0;
    if (itemCount == 5) return locale == 'th_TH' ? 50.0 : 110.0;
    return 60.0; // for 8 or more, fixed minimum
  }

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(6.0),
      build: (pwContext) {
        final fontBold = context.locale.toString() == 'th_TH' ? sarabunBold : robotoBold;
        final fontReqular = context.locale.toString() == 'th_TH' ? sarabunLight : robotoRegular;

        return pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColor.fromInt(theme.primaryColorLight.toARGB32()), width: 2),
          ),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              //Logo row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Logo
                  pw.ClipOval(
                    child: pw.Image(image, width: 60, height: 60),
                  ),
                  // Right: Column with invoice info
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      //Invoice Number
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 16.0),
                        child: pw.Row(
                          children: [
                            pw.Text(
                              '${context.tr('invoiceId')} :',
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(
                                  theme.primaryColor.toARGB32(),
                                ),
                                font: fontBold,
                              ),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(invoiceId, style: pw.TextStyle(font: fontReqular))
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 6),
                      //Issue day
                      pw.Row(
                        children: [
                          pw.Text(
                            '${context.tr('issued')} :',
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(
                                theme.primaryColor.toARGB32(),
                              ),
                              font: fontBold,
                            ),
                          ),
                          pw.SizedBox(width: context.locale.toString() == 'th_TH' ? 58 : 28),
                          pw.Text(issueDay, style: pw.TextStyle(font: fontReqular))
                        ],
                      ),

                      pw.SizedBox(height: 6),
                      //due day
                      pw.Row(
                        children: [
                          pw.Text(
                            '${context.tr('dueDate')} :',
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(
                                theme.primaryColor.toARGB32(),
                              ),
                              font: fontBold,
                            ),
                          ),
                          pw.SizedBox(width: context.locale.toString() == 'th_TH' ? 20 : 20),
                          pw.Text(dueDate, style: pw.TextStyle(font: fontReqular))
                        ],
                      )
                    ],
                  )
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // First Colum Dr information
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text(
                          context.tr('drInformation'),
                          style: pw.TextStyle(
                            color: PdfColor.fromInt(
                              theme.primaryColor.toARGB32(),
                            ),
                            fontSize: 18,
                            font: fontBold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        //Dr name
                        pw.Text('${context.tr('name')} : $drName', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('address')} : $drAddress', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('city')} : $drCity', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('state')} : $drState', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('country')} : $drCountry', style: pw.TextStyle(font: fontReqular)),
                      ],
                    ),
                  ),
                  //Second column patient information
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          context.tr('patientInformation'),
                          style: pw.TextStyle(color: PdfColor.fromInt(theme.primaryColor.toARGB32()), fontSize: 18, font: fontBold),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text('${context.tr('name')} : $paName', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('address')} : $paAddress', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('city')} : $paCity', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('state')} : $paState', style: pw.TextStyle(font: fontReqular)),
                        pw.Text('${context.tr('country')} : $paCountry', style: pw.TextStyle(font: fontReqular)),
                      ],
                    ),
                  ),
                  //Third column payment information
                  // Payment Information
                  if (bill.status == 'Paid') ...[
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            context.tr('paymentMethod'),
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                              fontSize: 18,
                              font: fontBold,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(paymentType, style: pw.TextStyle(font: fontReqular)),
                          pw.Text(paymentToken, style: pw.TextStyle(font: fontReqular)),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Column(
                children: [
                  // Invoice Items Table
                  pw.Table(
                    border: pw.TableBorder(
                      horizontalInside: pw.BorderSide(
                        color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                        width: 0.5,
                      ),
                    ),
                    columnWidths: columnWidths,
                    children: [
                      pw.TableRow(
                        children: filteredKeys.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final String key = entry.value;

                          // Convert key to display label
                          final String label = key == 'bookingsFee'
                              ? 'Percent'
                              : key == 'bookingsFeePrice'
                                  ? 'Fee Price'
                                  : '${key[0].toUpperCase()}${key.substring(1)}';

                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                            child: pw.Text(
                              context.tr(label),
                              textAlign: index == 0 ? pw.TextAlign.left : pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                                font: fontBold,
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

                          return pw.TableRow(children: [
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
                                return pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 6.0, bottom: 6.0, left: 8.0),
                                    child: pw.Text(
                                      value,
                                      textAlign: index == 0 ? pw.TextAlign.left : pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        font: fontReqular,
                                        fontFallback: [sarabunLight],
                                        color: PdfColor.fromInt(theme.primaryColorDark.toARGB32()),
                                      ),
                                    ));
                              },
                            )
                          ]);
                        },
                      )
                    ],
                  ),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left: Stamp (if doctor)
                      buildDoctorPaymentStamp(
                        bill.status != 'Paid' && isDueDatePassed(dueDate) ? 'Over Due' : bill.status,
                      ),
                      // if (roleName == 'doctors' && isSameDoctor)
                      //   pw.Positioned(
                      //     top: 50,
                      //     child: buildDoctorPaymentStamp(bill.status != 'Paid' && isDueDatePassed(dueDate) ? 'Over Due' : bill.status),
                      //   )
                      // else
                      //   pw.Expanded(child: pw.SizedBox(height: 100)),

                      // Right: Summary Table
                      pw.Expanded(
                        child: pw.Container(
                          alignment: pw.Alignment.topRight,
                          child: pw.Table(
                            border: pw.TableBorder(
                              horizontalInside: pw.BorderSide(color: PdfColor.fromInt(theme.primaryColor.toARGB32()), width: 0.5),
                            ),
                            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                            children: [
                              if (roleName == 'doctors' && isSameDoctor) ...[
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '${context.tr('totalPrice')} :',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(theme.primaryColor.toARGB32()), font: fontBold),
                                      ),
                                    ),
                                    pw.Align(
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Padding(
                                        padding: const pw.EdgeInsets.only(right: 4.0, top: 6.0),
                                        child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(bill.price)} ${bill.currencySymbol} ',
                                            style: pw.TextStyle(font: fontReqular)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (roleName == 'doctors' && isSameDoctor) ...[
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '${context.tr('totalFeePrice')} :',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(theme.primaryColor.toARGB32()), font: fontBold),
                                      ),
                                    ),
                                    pw.Align(
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Padding(
                                        padding: const pw.EdgeInsets.only(right: 4.0, top: 6.0),
                                        child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(bill.bookingsFeePrice)} ${bill.currencySymbol} ',
                                            style: pw.TextStyle(font: fontReqular)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      '${context.tr('totalAmount')} :',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(theme.primaryColor.toARGB32()), font: fontBold),
                                    ),
                                  ),
                                  pw.Align(
                                    alignment: !isSameDoctor && roleName == 'doctors' ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
                                    child: pw.Padding(
                                      padding: pw.EdgeInsets.only(right: roleName == 'doctors' ? isSameDoctor ? 4.0:  4.0 : 55.0, top: 6.0),
                                      child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(bill.total)} ${bill.currencySymbol} ',
                                          style: pw.TextStyle(font: fontReqular)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(
                    height: calculateDynamicSpacing(bill.billDetailsArray.length, context.locale.toString()),
                  ),
                  //Footer
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        context.tr('otherInformation'),
                        style: pw.TextStyle(
                          fontSize: 16,
                          font: fontBold,
                          color: PdfColor.fromInt(
                            theme.primaryColor.toARGB32(),
                          ),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        context.tr('invoiceFooter'),
                        style: pw.TextStyle(
                          font: fontReqular,
                        ),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf;
}
