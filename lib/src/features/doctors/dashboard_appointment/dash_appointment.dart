import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:health_care/services/appointment_service.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class DashboardAppointments extends StatefulWidget {
  final bool isToday;

  const DashboardAppointments({super.key, required this.isToday});
  String get routeName => isToday ? "/doctors/dashboard/appointments/today" : "/doctors/dashboard/appointments/this_week";

  @override
  State<DashboardAppointments> createState() => _DashboardAppointmentsState();
}

class _DashboardAppointmentsState extends State<DashboardAppointments> {
  final AuthService authService = AuthService();
  final ScrollController scheduleScrollController = ScrollController();
  final AppointmentService appointmentService = AppointmentService();
  late final DataGridProvider _dataGridProvider;
  bool _isDataGridProviderInitialized = false;
  // late bool isLoading;
  double scrollPercentage = 0;
  int total = 0;
  late AppointmentProvider appointmentProvider;
  Future<void> getDataOnUpdate() async {
    await appointmentService.getDocDashAppointments(context, widget.isToday);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    getDataOnUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataGridProviderInitialized) {
      _dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      _isDataGridProviderInitialized = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _dataGridProvider.setSortModel([
      {"field": "id", "sort": 'asc'}
    ], notify: false);
    _dataGridProvider.setMongoFilterModel({}, notify: false);
    appointmentProvider.setTotal(0, notify: false);
    appointmentProvider.setLoading(false, notify: false);
    appointmentProvider.setAppointmentReservations([], notify: false);
    scheduleScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, _) {
        final reservations = appointmentProvider.appointmentReservations;
        final total = appointmentProvider.total;
        bool isFilterActive = _dataGridProvider.mongoFilterModel.isNotEmpty;
        final theme = Theme.of(context);
        final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

        final List<GridColumn> gridColumns = [
          buildColumn(context.tr('id'), 'id', textColor, width: 100),
          GridColumn(
            columnName: 'patientProfile.fullName',
            allowSorting: true,
            allowFiltering: true,
            filterPopupMenuOptions: const FilterPopupMenuOptions(filterMode: FilterMode.advancedFilter),
            width: 250,
            label: Container(
              alignment: Alignment.center,
              child: Text(
                context.tr('patientName'),
                style: TextStyle(color: textColor),
              ),
            ),
          ),
          buildColumn(context.tr('dayTime'), 'dayPeriod', textColor, width: 150),
          buildColumn(context.tr('selectedDate'), 'selectedDate', textColor, width: 180),
          buildColumn(context.tr('total'), 'timeSlot.total', textColor, width: context.locale.toString() == 'th_TH' ? 150 : 120),
          buildColumn(context.tr('reserveDate'), 'createdDate', textColor, width: 180),
          buildColumn(context.tr('paymentStatus'), 'doctorPaymentStatus', textColor, width: 180),
        ];
        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: gridColumns[0], dataType: 'number'),
          FilterableGridColumn(column: gridColumns[1], dataType: 'string'),
          FilterableGridColumn(column: gridColumns[2], dataType: 'string'),
          FilterableGridColumn(column: gridColumns[3], dataType: 'date'),
          FilterableGridColumn(column: gridColumns[4], dataType: 'number'),
          FilterableGridColumn(column: gridColumns[5], dataType: 'date'),
          FilterableGridColumn(column: gridColumns[6], dataType: 'string'),
        ];

        return ScaffoldWrapper(
            title: widget.isToday ? context.tr('todayPatients') : context.tr('thisWeekPatients'),
            children: NotificationListener(
              onNotification: (notification) {
                double per = 0;
                if (scheduleScrollController.hasClients) {
                  per = ((scheduleScrollController.offset / scheduleScrollController.position.maxScrollExtent));
                }
                if (per >= 0) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        scrollPercentage = 307 * per;
                      });
                    }
                  });
                }
                return false;
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    // child: Text('Total: $total\nFirst reservation: $reservations'),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Total reservations card
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                                    context.tr("totalReservations", args: ["${reservations.length}"]),
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
                            count: total,
                            getDataOnUpdate: getDataOnUpdate,
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            restorationId: 'prescriptions',
                            key: const ValueKey('prescriptions'),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reservations.length,
                            itemBuilder: (context, index) {
                              final appointment = reservations[index];
                              return DashboardAppointmentShowBox(
                                getDataOnUpdate: getDataOnUpdate,
                                appointment: appointment,
                              );
                            },
                          ),
                          // Pagination widget
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  ScrollButton(scrollController: scheduleScrollController, scrollPercentage: scrollPercentage),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: FloatingActionButton(
                        tooltip: context.tr('filter'),
                        mini: true,
                        onPressed: () async {
                          final result = await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => FractionallySizedBox(
                              heightFactor: 0.9,
                              child: SfDataGridFilterWidget(columns: filterableColumns, columnName: 'id'),
                            ),
                          );

                          if (result != null) {
                            _dataGridProvider.setPaginationModel(0, 10);
                            _dataGridProvider.setMongoFilterModel({...result});
                            await getDataOnUpdate();
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.filter_alt_outlined,
                              size: 25,
                              color: theme.primaryColor,
                            ),
                            if (isFilterActive)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}

class DashboardAppointmentShowBox extends StatefulWidget {
  final VoidCallback getDataOnUpdate;
  final AppointmentReservation appointment;
  const DashboardAppointmentShowBox({
    super.key,
    required this.getDataOnUpdate,
    required this.appointment,
  });

  @override
  State<DashboardAppointmentShowBox> createState() => _DashboardAppointmentShowBoxState();
}

class _DashboardAppointmentShowBoxState extends State<DashboardAppointmentShowBox> {
  @override
  Widget build(BuildContext context) {
    final AppointmentReservation appointment = widget.appointment;
    final PatientUserProfile? patientProfile = appointment.patientProfile;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final String patientName = "${patientProfile!.gender.isEmpty ? '' : '${patientProfile.gender}.'}${patientProfile.fullName}";
    final bangkok = tz.getLocation('Asia/Bangkok');
    final encodedId = base64.encode(utf8.encode(appointment.patientId.toString()));
    final formattedTotal = NumberFormat("#,##0.00", "en_US").format(appointment.timeSlot.total);
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
                          RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$formattedTotal ',
                                      style: TextStyle(color: textColor),
                                    ),
                                    TextSpan(
                                      text: appointment.timeSlot.currencySymbol,
                                      style: TextStyle(color: theme.primaryColorLight),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          const SizedBox(width: 6),
                          SortIconWidget(columnName: 'timeSlot.total', getDataOnUpdate: widget.getDataOnUpdate),
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
            // createdAt and updateAt
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // createdAt
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

                  // Update
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
            // InvoiceId and day period
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // createdAt
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

                  // Update
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
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: 40,
                  width: constraints.maxWidth, // This makes the SizedBox take the full width
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
