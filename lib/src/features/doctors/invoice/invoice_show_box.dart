import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/src/features/doctors/invoice/build_doctor_invoice_pdf.dart';
import 'package:health_care/src/features/doctors/invoice/doctor_invoice_preview_screen.dart';
import 'package:health_care/src/features/doctors/invoice/invoice_data_sort.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:timezone/timezone.dart' as tz;

class InvoiceShowBox extends StatefulWidget {
  final VoidCallback getDataOnUpdate;
  final AppointmentReservation appointment;
  final Future<void> Function(BuildContext, List<String>) getConfirmationForUpdateAppointment;
  const InvoiceShowBox({
    super.key,
    required this.getDataOnUpdate,
    required this.appointment,
    required this.getConfirmationForUpdateAppointment,
  });

  @override
  State<InvoiceShowBox> createState() => _InvoiceShowBoxState();
}

class _InvoiceShowBoxState extends State<InvoiceShowBox> {
  @override
  Widget build(BuildContext context) {
    final AppointmentReservation appointment = widget.appointment;
    final PatientUserProfile? patientProfile = appointment.patientProfile;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final String patientName = "${patientProfile!.gender.isEmpty ? '' : '${patientProfile.gender}.'}${patientProfile.fullName}";
    final bangkok = tz.getLocation('Asia/Bangkok');
    final encodedId = base64.encode(utf8.encode(appointment.patientId.toString()));
    final ImageProvider<Object> finalImage = patientProfile.profileImage.isEmpty
        ? const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider
        : CachedNetworkImageProvider(patientProfile.profileImage);

    final Color statusColor = patientProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : patientProfile.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);
    bool isSelectable =
        appointment.doctorPaymentStatus == 'Awaiting Request' && !disablePastTime(appointment.selectedDate, appointment.timeSlot.period);
    return Card(
      elevation: 12,
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
                        context.push(
                          Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                        );
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
                      top: 5,
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
                                context.push(
                                  Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                                );
                              },
                              child: Text(
                                patientName,
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
                            columnName: 'patientProfile.fullName',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              appointment.invoiceId,
                              style: TextStyle(color: theme.primaryColor),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SortIconWidget(columnName: 'invoiceId', getDataOnUpdate: widget.getDataOnUpdate),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            //Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 1,
                color: theme.primaryColorLight,
              ),
            ),
            // reserveDate and selectedDate
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // reserveDate
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr("reserveDate")}: ',
                                style: TextStyle(color: textColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy').format(tz.TZDateTime.from(appointment.createdDate, bangkok)),
                                    style: TextStyle(color: textColor, fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('HH:mm').format(tz.TZDateTime.from(appointment.createdDate, bangkok)),
                                    style: TextStyle(color: theme.primaryColorLight, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'createdDate',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // selectedDate
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr("selectedDate")}: ',
                                style: TextStyle(color: textColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy').format(tz.TZDateTime.from(appointment.selectedDate, bangkok)),
                                    style: TextStyle(color: textColor, fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    appointment.timeSlot.period,
                                    style: TextStyle(color: theme.primaryColorLight, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'selectedDate',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 1,
                color: theme.primaryColorLight,
              ),
            ),
            // id and day period
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // id
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr("id")}: ',
                                style: TextStyle(color: textColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '#${appointment.appointmentId}',
                                style: TextStyle(color: textColor, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'id',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // dayTime
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr("dayTime")}: ',
                                style: TextStyle(color: textColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    appointment.dayPeriod[0].toUpperCase() + appointment.dayPeriod.substring(1).toLowerCase(),
                                    style: TextStyle(color: textColor, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'dayPeriod',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 1,
                color: theme.primaryColorLight,
              ),
            ),
            // price and bookingsFee
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // price
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr("price")}: ',
                                style: TextStyle(color: textColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                NumberFormat("#,##0.00", "en_US").format(appointment.timeSlot.price),
                                style: TextStyle(color: textColor, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'timeSlot.price',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // bookingsFee
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr("bookingsFeePrice")}: ',
                                style: TextStyle(color: textColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${appointment.timeSlot.bookingsFee.toInt()} %',
                                    style: TextStyle(color: textColor, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'timeSlot.bookingsFeePrice',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 1,
                color: theme.primaryColorLight,
              ),
            ),
            // feePrice and total
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // bookingsFeePrice
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr("bookingsFeePrice")}: ',
                                style: TextStyle(color: textColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                NumberFormat("#,##0.00", "en_US").format(appointment.timeSlot.bookingsFeePrice),
                                style: TextStyle(color: textColor, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'timeSlot.bookingsFeePrice',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // total
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr("total")}: ',
                                style: TextStyle(color: textColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    NumberFormat("#,##0.00", "en_US").format(appointment.timeSlot.total),
                                    style: TextStyle(color: textColor, fontSize: 12),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'timeSlot.total',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 1,
                color: theme.primaryColorLight,
              ),
            ),
            // paymentType and paymentToken
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // paymentToken
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr("paymentToken")}: ',
                                style: TextStyle(color: textColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                appointment.paymentToken,
                                style: TextStyle(color: textColor, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'paymentToken',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 1,
                color: theme.primaryColorLight,
              ),
            ),

            // paymentType
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr("paymentType")}: ',
                                style: TextStyle(color: textColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    appointment.paymentType,
                                    style: TextStyle(color: textColor, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'paymentType',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 1,
                color: theme.primaryColorLight,
              ),
            ),

            // doctorPaymentStatus
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // total
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: isSelectable ? 60 : 40,
                            child: GestureDetector(
                              onTap: !isSelectable
                                  ? null
                                  : () {
                                      widget.getConfirmationForUpdateAppointment(context, [appointment.id]);
                                    },
                              child: Chip(
                                label: Center(
                                  // Center the text within the Chip
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (isSelectable) ...[
                                        Text(
                                          context.tr('sendPaymentRequest'),
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                      Text(
                                        appointment.doctorPaymentStatus,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                backgroundColor: appointment.doctorPaymentStatus == "Paid"
                                    ? Colors.green
                                    : appointment.doctorPaymentStatus == "Awaiting Request"
                                        ? hexToColor('#f44336')
                                        : hexToColor('#ffa500'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide.none,
                                ),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                          child: SortIconWidget(
                            columnName: 'doctorPaymentStatus',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            //Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 1,
                color: theme.primaryColorLight,
              ),
            ),
            SizedBox(
              height: 35,
              child: GradientButton(
                onPressed: () {
                  // Show loading dialog
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
                      // final appointment = convertRowToAppointment(row);
                      final pdf = await buildDoctorInvoicePdf(context, appointment);
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
                  Theme.of(context).primaryColorLight,
                  Theme.of(context).primaryColor,
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
          ],
        ),
      ),
    );
  }
}
