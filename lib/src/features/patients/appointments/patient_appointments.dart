import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/patient_appointment_provider.dart';
import 'package:health_care/providers/widget_injection_provider.dart';
import 'package:health_care/services/patient_appointment_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/patients/appointments/patient_appointment_show_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientAppointments extends StatefulWidget {
  static const String routeName = "/patient/dashboard/appointments";
  final String patientId;
  final DoctorPatientProfileModel? doctorPatientProfile;
  const PatientAppointments({
    super.key,
    required this.patientId,
    this.doctorPatientProfile,
  });

  @override
  State<PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments> {
  final ScrollController scrollController = ScrollController();
  final PatientAppointmentService patientAppointmentService = PatientAppointmentService();
  late PatientAppointmentProvider patientAppointmentProvider;
  late DataGridProvider dataGridProvider;
  int? expandedIndex;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate() async {
    await patientAppointmentService.getPatAppointmentRecord(context, widget.patientId);
    setState(() {
      expandedIndex = null;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      patientAppointmentProvider = Provider.of<PatientAppointmentProvider>(context, listen: false);
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('getAppointmentRecordReturn');
    socket.off('updateGetAppointmentRecord');
    patientAppointmentProvider.setTotal(0, notify: false);
    patientAppointmentProvider.setLoading(false, notify: false);
    dataGridProvider.setMongoFilterModel({}, notify: false);
    patientAppointmentProvider.setPatientAppointmentReservations([], notify: false);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientAppointmentProvider>(builder: (context, appointmentProvider, _) {
      final patientAppointmentReservations = appointmentProvider.patientAppointmentReservations;
      bool isLoading = appointmentProvider.isLoading;
      final int totalAppointment = appointmentProvider.total;
      final theme = Theme.of(context);

      bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
      final injected = context.watch<WidgetInjectionProvider>().injectedWidget;

      final List<FilterableGridColumn> filterableColumns = [
        FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
        FilterableGridColumn(column: GridColumn(columnName: 'doctorProfile.fullName', label: Text(context.tr('doctorName'))), dataType: 'string'),
        FilterableGridColumn(column: GridColumn(columnName: 'selectedDate', label: Text(context.tr('selectedDate'))), dataType: 'date'),
        FilterableGridColumn(column: GridColumn(columnName: 'doctorProfile.address1', label: Text(context.tr('address'))), dataType: 'string'),
        FilterableGridColumn(column: GridColumn(columnName: 'invoiceId', label: Text(context.tr('invoiceNo'))), dataType: 'string'),
        FilterableGridColumn(
            column: GridColumn(columnName: 'doctorProfile.specialities.0.specialities', label: Text(context.tr('speciality'))), dataType: 'string'),
      ];
      return ScaffoldWrapper(
        title: context.tr('appointments'),
        children: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                double per = 0;
                if (scrollController.hasClients) {
                  per = ((scrollController.offset / scrollController.position.maxScrollExtent));
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
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.0),
                        topRight: Radius.circular(0.0),
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                    child: Column(
                      children: [
                        if (injected != null) ...[
                          injected,
                        ],
                        FadeinWidget(
                          isCenter: true,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Card(
                              elevation: 6,
                              color: Theme.of(context).canvasColor,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Theme.of(context).primaryColorLight),
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    "totalReservations",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ).plural(
                                    isFilterActive ? patientAppointmentReservations.length : totalAppointment,
                                    format: NumberFormat.compact(
                                      locale: context.locale.toString(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomPaginationWidget(
                          count: isFilterActive ? patientAppointmentReservations.length : totalAppointment,
                          getDataOnUpdate: getDataOnUpdate,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          restorationId: 'pateintAppointment',
                          key: const ValueKey('pateintAppointment'),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: patientAppointmentReservations.length,
                          itemBuilder: (context, index) {
                            final patientAppointment = patientAppointmentReservations[index];
                            return PatientAppointmentShowBox(
                              patientAppointmentReservation: patientAppointment,
                              isExpanded: expandedIndex == index,
                              index: index,
                              onToggle: (tappedIndex) {
                                setState(() {
                                  expandedIndex = (expandedIndex == tappedIndex) ? null : tappedIndex;
                                });
                              },
                              getDataOnUpdate: getDataOnUpdate,
                              doctorPatientProfile: widget.doctorPatientProfile,
                            );
                          },
                        ),
                        if (isLoading) ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
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
                      dataGridProvider.setPaginationModel(0, 10);
                      dataGridProvider.setMongoFilterModel({...result});
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
      );
    });
  }
}
