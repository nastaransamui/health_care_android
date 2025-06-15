
// ignore: depend_on_referenced_packages
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/providers/auth_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

Future<pw.Document> buildDoctorInvoicePdf(BuildContext context, AppointmentReservation row) async {
  final theme = Theme.of(context);

  var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  final robotoRegular = pw.Font.ttf(await rootBundle.load('fonts/Roboto_Condensed/static/RobotoCondensed-Regular.ttf'));
  final robotoBold = pw.Font.ttf(await rootBundle.load('fonts/Roboto_Condensed/static/RobotoCondensed-Bold.ttf'));
  final sarabunLight = pw.Font.ttf(await rootBundle.load('fonts/Sarabun/Sarabun-Light.ttf'));
  final sarabunBold = pw.Font.ttf(await rootBundle.load('fonts/Sarabun/Sarabun-Bold.ttf'));

  final pdf = pw.Document();
  final dateFormat = DateFormat('dd MMM yyyy');
  final bangkok = tz.getLocation('Asia/Bangkok');

  final imageBytes = await rootBundle.load('assets/icon/icon.png');
  final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
  String drName = "";
  String drAddress = "";
  String drCity = '';
  String drState = '';
  String drCountry = '';
  if (roleName == 'doctors') {
    drName = "Dr.${authProvider.doctorsProfile!.userProfile.fullName}";
    drAddress =
        "${authProvider.doctorsProfile!.userProfile.address1}${authProvider.doctorsProfile!.userProfile.address1 != '' ? ', ' : ''} ${authProvider.doctorsProfile!.userProfile.address2}";
    drCity = authProvider.doctorsProfile!.userProfile.city;
    drState = authProvider.doctorsProfile!.userProfile.state;
    drCountry = authProvider.doctorsProfile!.userProfile.country;
  }

  final String issueDay = dateFormat.format(tz.TZDateTime.from(row.createdDate, bangkok));
  final PatientUserProfile patientUserProfile = row.patientProfile!;
  final String paName = "${patientUserProfile.gender}${patientUserProfile.gender != '' ? '.' : ''} ${patientUserProfile.fullName}";
  final String paAddress = "${patientUserProfile.address1} ${patientUserProfile.address1 != '' ? ', ' : ''} ${patientUserProfile.address2}";
  final String paCity = patientUserProfile.city;
  final String paState = patientUserProfile.state;
  final String paCountry = patientUserProfile.country;
  final String invoiceId = row.invoiceId;
  final String doctorPaymentStatus = row.doctorPaymentStatus;
  final String selectedDate = dateFormat.format(tz.TZDateTime.from(row.selectedDate, bangkok));
  final TimeType timeSlot = row.timeSlot;
  final String paymentType = row.paymentType;
  final String paymentToken = row.paymentToken;
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
      case 'awaiting request':
        borderColor = PdfColors.red600; // Similar to #f44336
        text = 'Awaiting Request';
        break;
      case 'pending':
        borderColor = PdfColors.orange600; // Similar to #ffa500
        text = 'PENDING';
        break;
      default:
        borderColor = PdfColors.grey;
        text = status.toUpperCase();
    }

    return pw.Container(
      width: 328,
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
    );
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
              pw.Column(
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
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        //Invoice Number
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 16.0),
                          child: pw.Row(children: [
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
                          ]),
                        ),

                        pw.SizedBox(height: 6),
                        //Issue day
                        pw.Row(children: [
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
                        ])
                      ])
                    ],
                  ),
                  pw.SizedBox(height: 30),
                  // Second row information
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
                    ],
                  ),
                  pw.SizedBox(height: 30),
                  // Third row table
                  pw.Column(
                    children: [
                      // Invoice Items Table
                      pw.Table(
                        border: pw.TableBorder(
                          horizontalInside: pw.BorderSide(color: PdfColor.fromInt(theme.primaryColor.toARGB32()), width: 0.5),
                        ),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(4),
                          1: const pw.FlexColumnWidth(2),
                          2: const pw.FlexColumnWidth(2),
                          3: const pw.FlexColumnWidth(2),
                        },
                        children: [
                          // Table Header
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                                child: pw.Text(
                                  context.tr('description'),
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                                    font: fontBold,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
                                child: pw.Center(
                                  child: pw.Text(
                                    context.tr('quantity'),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                                      font: fontBold,
                                    ),
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
                                child: pw.Center(
                                  child: pw.Text(
                                    context.tr('price'),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                                      font: fontBold,
                                    ),
                                  ),
                                ),
                              ),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.only(right: 8),
                                  child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
                                    child: pw.Text(
                                      context.tr('total'),
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                                        font: fontBold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // First Item Row
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                                child: pw.Text('$selectedDate - ${timeSlot.period}', style: pw.TextStyle(font: fontReqular)),
                              ),
                              pw.Center(
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.only(top: 6),
                                  child: pw.Text('1', style: pw.TextStyle(font: fontReqular)),
                                ),
                              ),
                              pw.Center(
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.only(top: 6),
                                  child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(timeSlot.price)} ${timeSlot.currencySymbol}',
                                      style: pw.TextStyle(font: fontReqular)),
                                ),
                              ),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.only(right: 4, top: 6),
                                  child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(timeSlot.price)} ${timeSlot.currencySymbol} ',
                                      style: pw.TextStyle(font: fontReqular)),
                                ),
                              ),
                            ],
                          ),
                          // Booking Fee Row
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(vertical: 6.0),
                                child: pw.Text(context.tr('bookingsFee'), style: pw.TextStyle(font: fontReqular)),
                              ),
                              pw.Center(
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.only(top: 6.0),
                                  child: pw.Text('1', style: pw.TextStyle(font: fontReqular)),
                                ),
                              ),
                              pw.Center(
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.only(top: 6.0),
                                  child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(timeSlot.bookingsFeePrice)} ${timeSlot.currencySymbol} ',
                                      style: pw.TextStyle(font: fontReqular)),
                                ),
                              ),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.only(right: 4.0, top: 6.0),
                                  child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(timeSlot.bookingsFeePrice)} ${timeSlot.currencySymbol} ',
                                      style: pw.TextStyle(font: fontReqular)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Bottom Row: Stamp and Total Summary
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Left: Stamp (if doctor)
                          if (roleName == 'doctors')
                            pw.Positioned(
                              top: 50,
                              child: buildDoctorPaymentStamp(doctorPaymentStatus),
                            )
                          else
                            pw.Expanded(child: pw.SizedBox(height: 100)),

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
                                  pw.TableRow(children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '${context.tr('subtotal')} :',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(theme.primaryColor.toARGB32()), font: fontBold),
                                      ),
                                    ),
                                    pw.Align(
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Padding(
                                        padding: const pw.EdgeInsets.only(right: 4.0, top: 6.0),
                                        child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(timeSlot.total)} ${timeSlot.currencySymbol} ',
                                            style: pw.TextStyle(font: fontReqular)),
                                      ),
                                    ),
                                  ]),
                                  pw.TableRow(children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '${context.tr('discount')} :',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(theme.primaryColor.toARGB32()), font: fontBold),
                                      ),
                                    ),
                                    pw.Align(
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Padding(
                                        padding: const pw.EdgeInsets.only(right: 4.0, top: 6.0),
                                        child: pw.Text('---', style: pw.TextStyle(font: fontReqular)),
                                      ),
                                    ),
                                  ]),
                                  pw.TableRow(children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '${context.tr('totalAmount')} :',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(theme.primaryColor.toARGB32()), font: fontBold),
                                      ),
                                    ),
                                    pw.Align(
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Padding(
                                        padding: const pw.EdgeInsets.only(right: 4.0, top: 6.0),
                                        child: pw.Text('${NumberFormat("#,##0.0", "en_US").format(timeSlot.total)} ${timeSlot.currencySymbol} ',
                                            style: pw.TextStyle(font: fontReqular)),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 200),
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
