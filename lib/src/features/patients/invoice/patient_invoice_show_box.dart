import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/patient_appointment_reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/src/features/doctors/invoice/doctor_invoice_preview_screen.dart';
import 'package:health_care/src/features/patients/appointments/patient_appointment_show_box.dart';
import 'package:health_care/src/features/patients/dependents/patients_dependants_show_box.dart';
import 'package:timezone/timezone.dart' as tz;

class PatientInvoiceShowBox extends StatelessWidget {
  final PatientAppointmentReservation patientInvoice;
  final VoidCallback getDataOnUpdate;
  final PatientsProfile patientUserProfile;
  const PatientInvoiceShowBox({super.key, required this.patientInvoice, required this.getDataOnUpdate, required this.patientUserProfile});

  @override
  Widget build(BuildContext context) {
    final DoctorUserProfile doctorProfile = patientInvoice.doctorProfile;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    final String speciality = doctorProfile.specialities.first.specialities;
    final String specialityImage = doctorProfile.specialities.first.image;
    final uri = Uri.parse(specialityImage);
    final imageIsSvg = uri.path.endsWith('.svg');
    final String doctorName = "Dr. ${doctorProfile.fullName}";
    final String doctorProfileImage = doctorProfile.profileImage;
    final ImageProvider<Object> finalImage = doctorProfileImage.isEmpty
        ? const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider
        : CachedNetworkImageProvider(doctorProfileImage);
    final encodedReservationId = base64.encode(utf8.encode(patientInvoice.id.toString()));
    final encodedDoctorId = base64.encode(utf8.encode(patientInvoice.doctorId.toString()));
    final Color statusColor = doctorProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : doctorProfile.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        color: theme.canvasColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //profile row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        splashColor: theme.primaryColorLight,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        onTap: () {
                          context.push(Uri(path: '/doctors/profile/$encodedDoctorId').toString());
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: theme.primaryColorLight),
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            image: DecorationImage(fit: BoxFit.contain, image: finalImage),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  context.push(Uri(path: '/doctors/profile/$encodedDoctorId').toString());
                                },
                                child: Text(
                                  doctorName,
                                  style: TextStyle(
                                    color: theme.primaryColorLight,
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
                              getDataOnUpdate: getDataOnUpdate,
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(
                              columnName: 'doctorProfile.specialities.0.specialities',
                              getDataOnUpdate: getDataOnUpdate,
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '#${patientInvoice.appointmentId}',
                                style: TextStyle(color: theme.primaryColorLight),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(columnName: 'id', getDataOnUpdate: getDataOnUpdate),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //Divider
              MyDevider(theme: theme),
              // createdAt
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.calendar, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text('${context.tr('createdAt')}: '),
                          Text(
                            DateFormat('dd MMM yyyy HH:mm').format(
                              tz.TZDateTime.from(patientInvoice.createdDate, bangkok),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'createdDate',
                      getDataOnUpdate: getDataOnUpdate,
                    )
                  ],
                ),
              ),
              //Divider
              MyDevider(theme: theme),
              // Selected date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.calendarDay, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text('${context.tr('selectedDate')}: '),
                          Text('${DateFormat('dd MMM yyyy').format(patientInvoice.selectedDate)} ${patientInvoice.timeSlot.period}'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'selectedDate',
                      getDataOnUpdate: getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Day time
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.calendarDay, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text('${context.tr('dayTime')}: '),
                          Text(context.tr(patientInvoice.dayPeriod)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'dayPeriod',
                      getDataOnUpdate: getDataOnUpdate,
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
                            Uri(path: '/patient/dashboard/invoice-view/$encodedReservationId').toString(),
                          );
                        },
                        child: Row(
                          children: [
                            FaIcon(FontAwesomeIcons.invision, size: 13, color: theme.primaryColorLight),
                            const SizedBox(width: 5),
                          Text('${context.tr('invoiceId')}: '),
                            Text(
                              patientInvoice.invoiceId,
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
                      getDataOnUpdate: getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Price
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.dollarSign, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text('${context.tr('price')}: '),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${NumberFormat("#,##0.00", "en_US").format(patientInvoice.timeSlot.price)} ',
                                ),
                                TextSpan(
                                  text: patientInvoice.timeSlot.currencySymbol,
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'timeSlot.price',
                      getDataOnUpdate: getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Booking Fee
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.dollarSign, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text('${context.tr('bookingFee')}: '),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${NumberFormat("#,##0.00", "en_US").format(patientInvoice.timeSlot.bookingsFeePrice)} ',
                                ),
                                TextSpan(
                                  text: patientInvoice.timeSlot.currencySymbol,
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'timeSlot.bookingsFeePrice',
                      getDataOnUpdate: getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // total
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.dollarSign, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text('${context.tr('total')}: '),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${NumberFormat("#,##0.00", "en_US").format(patientInvoice.timeSlot.total)} ',
                                ),
                                TextSpan(
                                  text: patientInvoice.timeSlot.currencySymbol,
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'timeSlot.total',
                      getDataOnUpdate: getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              // Print
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 35,
                        child: GradientButton(
                          onPressed: () {
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
                                final pdf = await buildPatientInvoicePdf(context, patientInvoice, patientUserProfile.userProfile);
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
            ],
          ),
        ),
      ),
    );
  }
}
