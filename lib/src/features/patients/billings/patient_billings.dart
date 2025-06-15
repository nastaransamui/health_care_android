
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/billing_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/widget_injection_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/bills_service.dart';
import 'package:health_care/shared/bills_show_box.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientBillings extends StatefulWidget {
  static const String routeName = "/patient/dashboard/billings";
  final String patientId;
  const PatientBillings({super.key,required this.patientId});

  @override
  State<PatientBillings> createState() => _PatientBillingsState();
}

class _PatientBillingsState extends State<PatientBillings> {
  final ScrollController scrollController = ScrollController();
  late final DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final BillsService billsService = BillsService();
  late final BillingProvider billingProvider;
  late String roleName;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate() async {
    billsService.getPatientBillingRecord(context, widget.patientId);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
      billingProvider = Provider.of<BillingProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    billingProvider.setDoctorsBills([], notify: false);
    billingProvider.setTotal(0, notify: false);
    scrollController.dispose();
    // Remove socket listeners to avoid triggering after dispose
    socket.off('getBillingRecordReturn');
    socket.off('updateGetBillingRecord');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(builder: (context, billingProvider, _) {
      final patiensBills = billingProvider.bills;
      bool isLoading = billingProvider.isLoading;
      final int totalBills = billingProvider.total;
      final theme = Theme.of(context);
      // final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
      bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
      final injected = context.watch<WidgetInjectionProvider>().injectedWidget;
      final List<FilterableGridColumn> filterableColumns = [
        FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
        // FilterableGridColumn(column: GridColumn(columnName: 'doctorProfile.fullName', label: Text(context.tr('doctorName'))), dataType: 'string'),
        // FilterableGridColumn(column: GridColumn(columnName: 'selectedDate', label: Text(context.tr('selectedDate'))), dataType: 'date'),
        // FilterableGridColumn(column: GridColumn(columnName: 'doctorProfile.address1', label: Text(context.tr('address'))), dataType: 'string'),
        // FilterableGridColumn(column: GridColumn(columnName: 'invoiceId', label: Text(context.tr('invoiceNo'))), dataType: 'string'),
        // FilterableGridColumn(
        //     column: GridColumn(columnName: 'doctorProfile.specialities.0.specialities', label: Text(context.tr('speciality'))), dataType: 'string'),
      ];
      return ScaffoldWrapper(
        title: context.tr('billings'),
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
                    if (context.mounted) {
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
                    if (injected != null) ...[
                      injected,
                    ],
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
                                "totalBillings",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ).plural(
                                isFilterActive ? patiensBills.length : totalBills,
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
                      count: isFilterActive ? patiensBills.length : totalBills,
                      getDataOnUpdate: getDataOnUpdate,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      restorationId: 'pateintAppointment',
                      key: const ValueKey('pateintAppointment'),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: patiensBills.length,
                      itemBuilder: (context, index) {
                        final bill = patiensBills[index];
                        return BillsShowBox(
                          singleBill: bill,
                          getDataOnUpdate: getDataOnUpdate,
                          userType: 'patient',
                          deleteBillsId: const [],
                          tougleBillIdTodeleteBillsId: (String s) {},
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
