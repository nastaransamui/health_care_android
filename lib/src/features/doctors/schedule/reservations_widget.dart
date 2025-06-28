import 'dart:async';
import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:timezone/timezone.dart' as tz;

class ReservationsWidget extends StatefulWidget {
  final DoctorsTimeSlot? doctorTimeSlot;
  const ReservationsWidget({
    super.key,
    required this.doctorTimeSlot,
  });

  @override
  State<ReservationsWidget> createState() => _ReservationsWidgetState();
}

class _ReservationsWidgetState extends State<ReservationsWidget> {
  Future<void> getDataOnUpdate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctorProfile = authProvider.doctorsProfile;
    await TimeScheduleService().getDoctorTimeSlots(context, doctorProfile!);
  }

  late final DataGridProvider _dataGridProvider;
  bool _isDataGridProviderInitialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataGridProviderInitialized) {
      _dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      _isDataGridProviderInitialized = true;
    }
  }

  @override
  void dispose() {
    _dataGridProvider.setSortModel([
      {"field": "selectedDate", "sort": 'desc'}
    ], notify: false);
    _dataGridProvider.setMongoFilterModel({}, notify: false);
    socket.off('getDoctorTimeSlotsReturn');
    socket.off('updateGetDoctorTimeSlots');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<AppointmentReservation> appointments = widget.doctorTimeSlot?.reservations ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Total reservations card
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColorLight),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    context.tr("totalReservations", args: ["${widget.doctorTimeSlot?.totalReservation}"]),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          CustomPaginationWidget(
            count: widget.doctorTimeSlot?.totalReservation ?? 0,
            getDataOnUpdate: getDataOnUpdate,
          ),
          const SizedBox(height: 12),
          // DataGrid
          ListView.builder(
            shrinkWrap: true,
            restorationId: 'prescriptions',
            key: const ValueKey('prescriptions'),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return ScheduleAppointmentShowBox(
                getDataOnUpdate: getDataOnUpdate,
                appointment: appointment,
              );
            },
          ),
          // Pagination widget
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class ScheduleAppointmentShowBox extends StatefulWidget {
  final VoidCallback getDataOnUpdate;
  final AppointmentReservation appointment;
  const ScheduleAppointmentShowBox({
    super.key,
    required this.getDataOnUpdate,
    required this.appointment,
  });

  @override
  State<ScheduleAppointmentShowBox> createState() => _ScheduleAppointmentShowBoxState();
}

class _ScheduleAppointmentShowBoxState extends State<ScheduleAppointmentShowBox> {
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
                            height: 40,
                            child: Chip(
                              label: Center(
                                // Center the text within the Chip
                                child: Text(
                                  appointment.doctorPaymentStatus,
                                  style: const TextStyle(color: Colors.black),
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
          ],
        ),
      ),
    );
  }
}
