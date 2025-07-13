import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class ExportAsPdfButton extends StatelessWidget {
  const ExportAsPdfButton({
    super.key,
    required,
    required this.reservation,
    // required this.userProfile,
  });

  final Reservation reservation;
  // final PatientUserProfile userProfile;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Container(
          height: 38,
          width: MediaQuery.of(context).size.width,
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
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              Future.delayed(Duration.zero, () async {
                if (!context.mounted) return;

                try {
                  final pdf = await buildExportInvoicePdf(context, reservation);
                  final bytes = await pdf.save();
                  try {
                    // Get app-specific external directory
                    final directory = await getExternalStorageDirectory(); // path: Android/data/<package>/files/
                    if (directory == null) throw Exception("Cannot get external directory");
                    final path = directory.path;
                    final file = File('$path/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf');
                    await file.writeAsBytes(bytes);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showConsistSnackBar(context, context.tr('savedToDownload', args: [path]));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showConsistSnackBar(context, 'Failed to save PDF: $e');
                    }
                  }
                } catch (e) {
                  debugPrint('PDF Error: $e');
                }
              });
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
                  context.tr("exportAsPDF"),
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
    );
  }
}

Future<pw.Document> buildExportInvoicePdf(
  BuildContext context,
  Reservation reservation,
  
) async {
  final theme = Theme.of(context);
  final AuthProvider authProvider =Provider.of<AuthProvider>(context, listen: false);
  var roleName = authProvider.roleName;
    bool isSameDoctor = false;
    if (roleName == 'doctors') {
      final String currentDoctorId = authProvider.doctorsProfile!.userId;
      isSameDoctor = currentDoctorId == reservation.doctorId;
    }
  final robotoRegular = pw.Font.ttf(await rootBundle.load('fonts/Roboto_Condensed/static/RobotoCondensed-Regular.ttf'));
  final robotoBold = pw.Font.ttf(await rootBundle.load('fonts/Roboto_Condensed/static/RobotoCondensed-Bold.ttf'));
  final sarabunLight = pw.Font.ttf(await rootBundle.load('fonts/Sarabun/Sarabun-Light.ttf'));
  final sarabunBold = pw.Font.ttf(await rootBundle.load('fonts/Sarabun/Sarabun-Bold.ttf'));

  final pdf = pw.Document();
  final dateFormat = DateFormat('dd MMM yyyy');
  final bangkok = tz.getLocation(dotenv.env['TZ']!);

  final imageBytes = await rootBundle.load('assets/icon/icon.png');
  final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
  final PatientUserProfile patientProfile = reservation.patientProfile;
  final String paName = "${patientProfile.gender}${patientProfile.gender != '' ? '.' : ''} ${patientProfile.fullName}";
  final String paAddress = "${patientProfile.address1} ${patientProfile.address1 != '' ? ', ' : ''} ${patientProfile.address2}";
  final String paCity = patientProfile.city;
  final String paState = patientProfile.state;
  final String paCountry = patientProfile.country;

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
                          if (roleName == 'doctors' && isSameDoctor)
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
