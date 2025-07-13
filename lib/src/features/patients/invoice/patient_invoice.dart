import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/patient_appointment_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/patient_appointment_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/patients/invoice/patient_invoice_show_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientInvoice extends StatefulWidget {
   static const String routeName = "/patient/dashboard/invoice";
  const PatientInvoice({super.key});

  @override
  State<PatientInvoice> createState() => _PatientInvoiceState();
}

class _PatientInvoiceState extends State<PatientInvoice> {
  final ScrollController scrollController = ScrollController();
  late final DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();
  final PatientAppointmentService patientAppointmentService = PatientAppointmentService();
  late final PatientAppointmentProvider patientAppointmentProvider;
  late final AuthProvider authProvider;
  late PatientsProfile? patientUserProfile;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate() async {
    await patientAppointmentService.getPatientInvoices(context);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      patientAppointmentProvider = Provider.of<PatientAppointmentProvider>(context, listen: false);
      patientUserProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
      _isProvidersInitialized = true;
    }
    getDataOnUpdate();
  }

  @override
  void dispose() {
    patientAppointmentProvider.setPatientAppointmentReservations([], notify: false);
    patientAppointmentProvider.setTotal(0, notify: false);
    scrollController.dispose();
    dataGridProvider.setSortModel([
      {"field": "id", "sort": "asc"}
    ], notify: false);
    dataGridProvider.setMongoFilterModel({}, notify: false);
    dataGridProvider.setPaginationModel(0, 10, notify: false);
    socket.off('getPatientInvoicesReturn');
    socket.off('updateGetPatientInvoices');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientAppointmentProvider>(
      builder: (context, patientAppointmentProvider, child) {
        final theme = Theme.of(context);
        // final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        bool isLoading = patientAppointmentProvider.isLoading;
        final patientInvoices = patientAppointmentProvider.patientAppointmentReservations;
        final int totalInvoices = patientAppointmentProvider.total;
        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(
            column: GridColumn(columnName: 'doctorProfile.fullName', label: Text(context.tr('doctorName'))),
            dataType: 'string',
          ),
          FilterableGridColumn(
              column: GridColumn(
                columnName: 'doctorProfile.specialities.0.specialities',
                label: Text(context.tr('speciality')),
              ),
              dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'createdDate', label: Text(context.tr('createdAt'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'selectedDate', label: Text(context.tr('selectedDate'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'dayPeriod', label: Text(context.tr('dayTime'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'invoiceId', label: Text(context.tr('invoiceId'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'invoiceId', label: Text(context.tr('invoiceNo'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'timeSlot.price', label: Text(context.tr('price'))), dataType: 'number'),
          FilterableGridColumn(
            column: GridColumn(columnName: 'timeSlot.bookingsFeePrice', label: Text(context.tr('bookingFee'))),
            dataType: 'number',
          ),
          FilterableGridColumn(column: GridColumn(columnName: 'timeSlot.total', label: Text(context.tr('total'))), dataType: 'number'),
        ];

        return ScaffoldWrapper(
          title: context.tr('patientInvoice'),
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).primaryColorLight),
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                "totalPatientInvoice",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ).plural(
                                isFilterActive ? patientInvoices.length : totalInvoices,
                                format: NumberFormat.compact(
                                  locale: context.locale.toString(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomPaginationWidget(
                        count: isFilterActive ? patientInvoices.length : totalInvoices,
                        getDataOnUpdate: getDataOnUpdate,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        restorationId: 'patientInvoices',
                        key: const ValueKey('patientInvoices'),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: patientInvoices.length,
                        itemBuilder: (context, index) {
                          final patientInvoice = patientInvoices[index];
                          return PatientInvoiceShowBox(
                            patientInvoice: patientInvoice,
                            getDataOnUpdate: getDataOnUpdate,
                            patientUserProfile: patientUserProfile!,
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
                      ],
                    ],
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
      },
    );
  }
}
