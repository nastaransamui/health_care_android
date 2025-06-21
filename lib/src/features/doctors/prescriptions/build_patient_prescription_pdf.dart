import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_care/models/prescriptions.dart';
import 'package:health_care/models/users.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:timezone/timezone.dart' as tz;

Future<pw.Document> buildPatientPrescriptionPdf(
  BuildContext context,
  Prescriptions prescription,
) async {
  final theme = Theme.of(context);

  final robotoRegular = pw.Font.ttf(await rootBundle.load('fonts/Roboto_Condensed/static/RobotoCondensed-Regular.ttf'));
  final robotoBold = pw.Font.ttf(await rootBundle.load('fonts/Roboto_Condensed/static/RobotoCondensed-Bold.ttf'));
  final sarabunLight = pw.Font.ttf(await rootBundle.load('fonts/Sarabun/Sarabun-Light.ttf'));
  final sarabunBold = pw.Font.ttf(await rootBundle.load('fonts/Sarabun/Sarabun-Bold.ttf'));

  final pdf = pw.Document();
  final dateFormat = DateFormat('dd MMM yyyy');
  final bangkok = tz.getLocation('Asia/Bangkok');

  final imageBytes = await rootBundle.load('assets/icon/icon.png');
  final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
  final String paName =
      "${prescription.patientProfile.gender}${prescription.patientProfile.gender != '' ? '.' : ''} ${prescription.patientProfile.fullName}";
  final String paAddress =
      "${prescription.patientProfile.address1} ${prescription.patientProfile.address1 != '' ? ', ' : ''} ${prescription.patientProfile.address2}";
  final String paCity = prescription.patientProfile.city;
  final String paState = prescription.patientProfile.state;
  final String paCountry = prescription.patientProfile.country;

  final String issueDay = dateFormat.format(tz.TZDateTime.from(prescription.createdAt, bangkok));
  final DoctorUserProfile doctorUserProfile = prescription.doctorProfile;
  final String drName = "Dr.${doctorUserProfile.fullName}";
  final String drAddress = "${doctorUserProfile.address1}${doctorUserProfile.address1 != '' ? ', ' : ''} ${doctorUserProfile.address2}";
  final String drCity = doctorUserProfile.city;
  final String drState = doctorUserProfile.state;
  final String drCountry = doctorUserProfile.country;
  final String invoiceId = prescription.id;
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
                              '${context.tr('order')} :',
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
                          pw.SizedBox(width: context.locale.toString() == 'th_TH' ? 8 : 8),
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
                                  context.tr('medicine'),
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
                                    context.tr('medicine_id'),
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
                                    context.tr('quantity'),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromInt(theme.primaryColor.toARGB32()),
                                      font: fontBold,
                                    ),
                                  ),
                                ),
                              ),
                              pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.only(right: 8),
                                  child: pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
                                    child: pw.Text(
                                      context.tr('description'),
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
                          ...prescription.prescriptionsArray.map(
                            (item) {
                              return pw.TableRow(
                                children: [
                                  // Medicine
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 6.0, bottom: 6.0, left: 8.0),
                                    child: pw.Text(
                                      item.medicine,
                                      style: pw.TextStyle(
                                        font: fontReqular,
                                        fontFallback: [sarabunLight],
                                        color: PdfColor.fromInt(theme.primaryColorDark.toARGB32()),
                                      ),
                                    ),
                                  ),

                                  // Medicine ID
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(vertical: 6.0),
                                    child: pw.Text(
                                      item.medicineId.isEmpty ? "##" : item.medicineId,
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        font: fontReqular,
                                        fontFallback: [sarabunLight],
                                        color: PdfColor.fromInt(theme.primaryColorDark.toARGB32()),
                                      ),
                                    ),
                                  ),

                                  // Quantity
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(vertical: 6.0),
                                    child: pw.Text(
                                      'x${item.quantity}',
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        font: fontReqular,
                                        fontFallback: [sarabunLight],
                                        color: PdfColor.fromInt(theme.primaryColorDark.toARGB32()),
                                      ),
                                    ),
                                  ),

                                  // Description
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(right: 8.0, top: 6.0, bottom: 6.0),
                                    child: pw.Text(
                                      item.description,
                                      textAlign: pw.TextAlign.left,
                                      style: pw.TextStyle(
                                        font: fontReqular,
                                        fontFallback: [sarabunLight],
                                        color: PdfColor.fromInt(theme.primaryColorDark.toARGB32()),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
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
