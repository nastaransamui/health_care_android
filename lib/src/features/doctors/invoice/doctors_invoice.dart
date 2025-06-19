
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/invoice_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/invoices_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/invoice/invoice_data_sort.dart';
import 'package:health_care/src/features/doctors/invoice/invoice_show_box.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DoctorsInvoice extends StatefulWidget {
  static const routeName = '/doctors/dashboard/invoice';
  const DoctorsInvoice({super.key});

  @override
  State<DoctorsInvoice> createState() => _DoctorsInvoiceState();
}

class _DoctorsInvoiceState extends State<DoctorsInvoice> {
  final ScrollController invoiceScrollController = ScrollController();
  late final DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();
  final InvoicesService invoicesService = InvoicesService();
  late final AuthProvider authProvider;
  late InvoiceProvider invoiceProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  late List<String> selectedAppointmentIds;
  late ValueNotifier<List<String>> selectedIdsNotifier;

  Future<void> getDataOnUpdate() async {
    invoicesService.getDoctorInvoices(context);
    setState(() {
      selectedAppointmentIds.clear();
      selectedIdsNotifier.value = [];
    });
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);

    selectedAppointmentIds = [];
    selectedIdsNotifier = ValueNotifier([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
      _isProvidersInitialized = true;
      invoiceProvider.setLoading(true);
      getDataOnUpdate();
    }
  }

  @override
  void dispose() {
    invoiceProvider.setAppointmentReservations([], notify: false);
    invoiceProvider.setTotal(0, notify: false);
    invoiceScrollController.dispose();
    dataGridProvider.setSortModel([
      {"field": "id", "sort": 'asc'}
    ], notify: false);
    dataGridProvider.setMongoFilterModel({}, notify: false);
    dataGridProvider.setPaginationModel(0, 10, notify: false);
    selectedIdsNotifier.dispose();
    super.dispose();
  }

  Future<void> getConfirmationForUpdateAppointment(
    BuildContext context,
    List<String> selectedAppointmentIds,
  ) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColorLight,
            title: const Text("invoiceForDelete").plural(
              selectedAppointmentIds.length,
              format: NumberFormat.compact(
                locale: context.locale.toString(),
              ),
            ),
            automaticallyImplyLeading: false, // Removes the back button
            actions: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
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
                          "sendAppointmentForPayment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).primaryColor,
                          ),
                        ).plural(
                          selectedAppointmentIds.length,
                          format: NumberFormat.compact(
                            locale: context.locale.toString(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedAppointmentIds);
                    },
                    child: Text(context.tr("submit")),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    if (!context.mounted) return;

    if (result != null) {
      updateAppointmentRequestSubmit(context, result);
    }
  }

  Future<void> updateAppointmentRequestSubmit(BuildContext context, List<String> updateStatusArray) async {
    if (!context.mounted) return;
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      showDragHandle: false,
      useSafeArea: true,
      context: context,
      builder: (context) => const LoadingScreen(),
    );
    bool success = await invoicesService.updateAppointmentRequestSubmit(context, updateStatusArray);
    if (!context.mounted) return;

    Navigator.of(context).pop();
    if (success) {
      if (context.mounted) {
        showErrorSnackBar(context, "${updateStatusArray.length} invoice(s) was send for payment request.");
        getDataOnUpdate();
        setState(() {
          selectedAppointmentIds.clear();
          selectedIdsNotifier.value = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, _) {
        final theme = Theme.of(context);
        final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        bool isLoading = invoiceProvider.isLoading;
        final myInvoices = invoiceProvider.appointmentReservations;
        final dataSource = InvoiceDataSort(
          appointments: myInvoices,
          context: context,
          selectedIds: selectedAppointmentIds,
          selectedIdsNotifier: selectedIdsNotifier,
          updateAppointmentRequestSubmit: updateAppointmentRequestSubmit,
        );
        final total = invoiceProvider.total;

        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'createdDate', label: Text(context.tr('reserveDate'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'dayPeriod', label: Text(context.tr('dayTime'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'selectedDate', label: Text(context.tr('selectedDate'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'invoiceId', label: Text(context.tr('invoiceNo'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'timeSlot.price', label: Text(context.tr('price'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'timeSlot.bookingsFee', label: Text(context.tr('bookingsFee'))), dataType: 'number'),
          FilterableGridColumn(
              column: GridColumn(columnName: 'timeSlot.bookingsFeePrice', label: Text(context.tr('bookingsFeePrice'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'timeSlot.total', label: Text(context.tr('total'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'paymentType', label: Text(context.tr('paymentType'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'paymentToken', label: Text(context.tr('paymentToken'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'paymentDate', label: Text(context.tr('paymentDate'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'patientProfile.fullName', label: Text(context.tr('patientName'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'doctorPaymentStatus', label: Text(context.tr('paymentStatus'))), dataType: 'string')
        ];
        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        List<String> payableInvoiceList = myInvoices
            .where((apppointment) =>
                apppointment.doctorPaymentStatus == 'Awaiting Request' && !disablePastTime(apppointment.selectedDate, apppointment.timeSlot.period))
            .map((bill) => bill.id.toString())
            .toList();
        return ValueListenableBuilder(
          valueListenable: dataSource.selectedIdsNotifier,
          builder: (context, value, child) {
            return ScaffoldWrapper(
              title: context.tr('invoices'),
              children: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      double per = 0;
                      if (invoiceScrollController.hasClients) {
                        per = ((invoiceScrollController.offset / invoiceScrollController.position.maxScrollExtent));
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
                    child:
                        //Invoices
                        SingleChildScrollView(
                      controller: invoiceScrollController,
                      child: Column(
                        children: [
                          FadeinWidget(
                            isCenter: true,
                            child: Padding(
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
                                      "totalMyInvoice",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ).plural(
                                      total,
                                      format: NumberFormat.compact(
                                        locale: context.locale.toString(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.vertical,
                                child: child,
                              );
                            },
                            child: selectedAppointmentIds.isNotEmpty
                                ? Padding(
                                    key: const ValueKey("buttonVisible"),
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 40,
                                      child: GradientButton(
                                        onPressed: () async {
                                          getConfirmationForUpdateAppointment(context, selectedAppointmentIds);
                                        },
                                        colors: [
                                          Theme.of(context).primaryColorLight,
                                          Theme.of(context).primaryColor,
                                        ],
                                        child: Center(
                                          child: Text(
                                            "paymentRequest",
                                            style: TextStyle(fontSize: 12, color: textColor),
                                          ).plural(
                                            selectedAppointmentIds.length,
                                            format: NumberFormat.compact(
                                              locale: context.locale.toString(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(key: ValueKey("buttonHidden")),
                          ),
                          const SizedBox(height: 12),
                          FadeinWidget(
                            isCenter: true,
                            child: CustomPaginationWidget(
                              count: total,
                              getDataOnUpdate: getDataOnUpdate,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                splashRadius: 0,
                                checkColor: theme.primaryColorLight,
                                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                value: selectedAppointmentIds.isNotEmpty,
                                onChanged: (bool? value) {
                                  if (value == false) {
                                    setState(() {
                                      selectedAppointmentIds.clear();
                                    });
                                  } else {
                                    setState(() {
                                      selectedAppointmentIds = payableInvoiceList;
                                    });
                                  }
                                },
                              ),
                              Text('taggleInvoicesForPayment',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: theme.primaryColorLight,
                                  )).plural(
                                payableInvoiceList.length,
                                format: NumberFormat.compact(
                                  locale: context.locale.toString(),
                                ),
                              ),
                            ],
                          ),
                          // DataGrid
                          ListView.builder(
                            shrinkWrap: true,
                            restorationId: 'prescriptions',
                            key: const ValueKey('prescriptions'),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: myInvoices.length,
                            itemBuilder: (context, index) {
                              final appointment = myInvoices[index];
                              return InvoiceShowBox(
                                getDataOnUpdate: getDataOnUpdate,
                                appointment: appointment,
                                getConfirmationForUpdateAppointment: getConfirmationForUpdateAppointment,
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
                  ScrollButton(scrollController: invoiceScrollController, scrollPercentage: scrollPercentage),
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
      },
    );
  }
}
