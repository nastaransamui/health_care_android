import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/patient_appointment_reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/src/features/doctors/invoice/doctor_invoice_preview_screen.dart';
import 'package:health_care/src/features/patients/appointments/patient_appointment_button_sheet.dart';
import 'package:health_care/src/features/patients/dependents/patients_dependants_show_box.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:timezone/timezone.dart' as tz;

class PatientAppointmentShowBox extends StatefulWidget {
  final PatientAppointmentReservation patientAppointmentReservation;
  final bool isExpanded;
  final void Function(int index) onToggle;
  final int index;
  final VoidCallback getDataOnUpdate;
  final DoctorPatientProfileModel? doctorPatientProfile;
  const PatientAppointmentShowBox({
    super.key,
    required this.patientAppointmentReservation,
    required this.isExpanded,
    required this.onToggle,
    required this.index,
    required this.getDataOnUpdate,
    this.doctorPatientProfile,
  });

  @override
  State<PatientAppointmentShowBox> createState() => _PatientAppointmentShowBoxState();
}

class _PatientAppointmentShowBoxState extends State<PatientAppointmentShowBox> {
  late String roleName;
  bool _isProvidersInitialized = false;

  late PatientsProfile? patientUserProfile;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
      patientUserProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
      _isProvidersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final dateFormat = DateFormat('dd MMM yyyy');
    final PatientAppointmentReservation reservation = widget.patientAppointmentReservation;
    final DoctorUserProfile doctorUserProfile = reservation.doctorProfile;
    final DateTime selectedDate = reservation.selectedDate;
    final TimeType timeSlot = reservation.timeSlot;
    final String doctorId = reservation.doctorId;
    final String period = timeSlot.period;
    final String profileImage = doctorUserProfile.profileImage;
    final String doctorName = 'Dr. ${doctorUserProfile.fullName}';
    final String speciality = doctorUserProfile.specialities.first.specialities;
    final String specialityImage = doctorUserProfile.specialities.first.image;
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    final uri = Uri.parse(specialityImage);
    final imageIsSvg = uri.path.endsWith('.svg');
    final encodedId = base64.encode(utf8.encode(doctorId.toString()));
    final encodedinvoice = base64.encode(utf8.encode(reservation.id.toString()));
    Color statusColor = doctorUserProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : doctorUserProfile.online
            ? const Color(0xFF44B700)
            : Colors.pinkAccent; // offline

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        color: theme.canvasColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // DoctorProfile image
                  Stack(
                    children: [
                      InkWell(
                        splashColor: theme.primaryColorLight,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        onTap: () {
                          context.push(
                            Uri(path: '/doctors/profile/$encodedId').toString(),
                          );
                        },
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: theme.primaryColorLight),
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: profileImage.isEmpty
                                  ? const AssetImage(
                                      'assets/images/doctors_profile.jpg',
                                    ) as ImageProvider
                                  : CachedNetworkImageProvider(
                                      profileImage,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        bottom: 10,
                        child: AvatarGlow(
                          glowColor: statusColor,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.primaryColor, width: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // DoctorName
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  context.push(
                                    Uri(path: '/doctors/profile/$encodedId').toString(),
                                  );
                                },
                                child: Text(
                                  doctorName,
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(
                              columnName: 'doctorProfile.fullName',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        // appointmentId
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '#${reservation.appointmentId}',
                                style: TextStyle(color: theme.primaryColorLight),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(
                              columnName: 'id',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              MyDevider(theme: theme),
              // Created Row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.clock, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text('${context.tr('createdAt')}: '),
                          Text(
                            DateFormat('dd MMM yyyy HH:mm').format(
                              tz.TZDateTime.from(reservation.createdDate, bangkok),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'createdDate',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Selected date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.clock, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text('${context.tr('selectedDate')}: '),
                          Text('${dateFormat.format(selectedDate)} $period'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'selectedDate',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Doctor Adddress
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.mapMarkedAlt, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text(
                            '${doctorUserProfile.address1} ${doctorUserProfile.address2}',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'doctorProfile.address1',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Doctor Speciality
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          imageIsSvg
                              ? SvgPicture.network(
                                  specialityImage,
                                  width: 15,
                                  height: 15,
                                  fit: BoxFit.fitHeight,
                                )
                              : SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CachedNetworkImage(
                                    imageUrl: specialityImage,
                                    fadeInDuration: const Duration(milliseconds: 0),
                                    fadeOutDuration: const Duration(milliseconds: 0),
                                    errorWidget: (ccontext, url, error) {
                                      return Image.asset(
                                        'assets/images/default-avatar.png',
                                      );
                                    },
                                  ),
                                ),
                          const SizedBox(width: 5),
                          Text(
                            speciality,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'doctorProfile.specialities.0.specialities',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Invoice id
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.push(
                            Uri(path: '/patient/dashboard/invoice-view/$encodedinvoice').toString(),
                          );
                        },
                        child: Row(
                          children: [
                            FaIcon(FontAwesomeIcons.invision, size: 13, color: theme.primaryColorLight),
                            const SizedBox(width: 5),
                            Text(
                              reservation.invoiceId,
                              style: TextStyle(
                              color: theme.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'invoiceId',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Buttons
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 35,
                        child: GradientButton(
                          onPressed: () {
                            showModalBottomSheet(
                              useSafeArea: true,
                              showDragHandle: true,
                              isScrollControlled: true,
                              isDismissible: true,
                              enableDrag: true,
                              context: context,
                              builder: (context) {
                                return DraggableScrollableSheet(
                                  expand: false,
                                  initialChildSize: 0.9,
                                  minChildSize: 0.5,
                                  maxChildSize: 0.95,
                                  builder: (context, scrollController) {
                                    return PatientAppointmentButtonSheet(patientAppointmentReservation: reservation);
                                  },
                                );
                              },
                            );
                          },
                          colors: [
                            Theme.of(context).primaryColorLight,
                            Theme.of(context).primaryColor,
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.eye, size: 13, color: textColor),
                              const SizedBox(width: 5),
                              Text(
                                context.tr("view"),
                                style: TextStyle(fontSize: 12, color: textColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: SizedBox(
                        height: 35,
                        child: GradientButton(
                          onPressed: () {
                            PatientUserProfile currentPatientUserProfile;
                            if (roleName == 'patient') {
                              currentPatientUserProfile = patientUserProfile!.userProfile;
                            } else {
                              final doctorPatientProfile = widget.doctorPatientProfile;
                              currentPatientUserProfile = createPatientProfileFromDoctorPatientProfile(doctorPatientProfile!);
                            }
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
                                final pdf = await buildPatientInvoicePdf(context, reservation, currentPatientUserProfile);
                                final bytes = await pdf.save();

                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                await showModalBottomSheet<Map<String, dynamic>>(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  builder: (context) => FractionallySizedBox(
                                    heightFactor: 1,
                                    child: DoctorInvoicePreviewScreen(
                                      pdfBytes: bytes,
                                      title: Text(context.tr('invoicePreview')),
                                    ),
                                  ),
                                );
                                // });
                              } catch (e) {
                                debugPrint('PDF Error: $e');
                              }
                            });
                          },
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColorLight,
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.print, size: 13, color: textColor),
                              const SizedBox(width: 5),
                              Text(
                                context.tr("print"),
                                style: TextStyle(fontSize: 12, color: textColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              MyDivider(theme: theme),
              // Services dropdown
              InkWell(
                onTap: () => widget.onToggle(widget.index),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${context.tr('services')} :", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Icon(
                      widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: widget.isExpanded ? theme.primaryColorLight : theme.primaryColor,
                    ),
                  ],
                ),
              ),
            //  Services show
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: widget.isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: doctorUserProfile.specialitiesServices.map((entry) {
                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: theme.primaryColorLight),
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                child: Text(entry),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PatientUserProfile createPatientProfileFromDoctorPatientProfile(DoctorPatientProfileModel doctorPatientProfile) {
  return PatientUserProfile(
    address1: doctorPatientProfile.address1,
    address2: doctorPatientProfile.address2,
    billingsIds: doctorPatientProfile.billingsIds,
    bloodG: doctorPatientProfile.bloodG,
    city: doctorPatientProfile.city,
    country: doctorPatientProfile.country,
    createdAt: doctorPatientProfile.createdAt,
    dependentsArray: doctorPatientProfile.dependentsArray,
    dob: doctorPatientProfile.dob,
    doctorsId: doctorPatientProfile.doctorsId,
    favsId: doctorPatientProfile.favsId,
    fcmTokens: doctorPatientProfile.fcmTokens,
    firstName: doctorPatientProfile.firstName,
    fullName: doctorPatientProfile.fullName,
    gender: doctorPatientProfile.gender,
    idle: doctorPatientProfile.lastLogin.idle,
    invoiceIds: doctorPatientProfile.invoiceIds,
    isActive: doctorPatientProfile.isActive,
    isVerified: doctorPatientProfile.isVerified,
    lastLogin: doctorPatientProfile.lastLogin,
    lastName: doctorPatientProfile.lastName,
    lastUpdate: doctorPatientProfile.lastUpdate,
    medicalRecordsArray: doctorPatientProfile.medicalRecordsArray,
    mobileNumber: doctorPatientProfile.mobileNumber,
    online: doctorPatientProfile.online,
    prescriptionsId: doctorPatientProfile.prescriptionsId,
    profileImage: doctorPatientProfile.profileImage,
    rateArray: [],
    reservationsId: doctorPatientProfile.reservationsId,
    reviewsArray: [],
    roleName: doctorPatientProfile.roleName,
    services: doctorPatientProfile.services,
    state: doctorPatientProfile.state,
    userName: doctorPatientProfile.userName,
    zipCode: doctorPatientProfile.zipCode,
    id: doctorPatientProfile.id,
    patientsId: doctorPatientProfile.patientsId,
  );
}

Future<pw.Document> buildPatientInvoicePdf(
    BuildContext context, PatientAppointmentReservation reservation, PatientUserProfile currentPatientUserProfile) async {
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
  final String paName =
      "${currentPatientUserProfile.gender}${currentPatientUserProfile.gender != '' ? '.' : ''} ${currentPatientUserProfile.fullName}";
  final String paAddress =
      "${currentPatientUserProfile.address1} ${currentPatientUserProfile.address1 != '' ? ', ' : ''} ${currentPatientUserProfile.address2}";
  final String paCity = currentPatientUserProfile.city;
  final String paState = currentPatientUserProfile.state;
  final String paCountry = currentPatientUserProfile.country;

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
