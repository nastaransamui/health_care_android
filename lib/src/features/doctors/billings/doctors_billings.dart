
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/billing_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/bills_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/bills_show_box.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DoctorsBillings extends StatefulWidget {
  static const String routeName = "/doctors/dashboard/billings";
  const DoctorsBillings({super.key});

  @override
  State<DoctorsBillings> createState() => _DoctorsBillingsState();
}

class _DoctorsBillingsState extends State<DoctorsBillings> {
  final ScrollController doctorsBillingsScrollController = ScrollController();
  late final DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final BillsService billsService = BillsService();
  late final BillingProvider billingProvider;
  late List<String> deleteBillsId;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate() async {
    await billsService.getBillingRecord(context);
    setState(() {
      deleteBillsId.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    deleteBillsId = [];
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
      billingProvider = Provider.of<BillingProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    billingProvider.setDoctorsBills([], notify: false);
    billingProvider.setTotal(0, notify: false);
    doctorsBillingsScrollController.dispose();
     // Remove socket listeners to avoid triggering after dispose
  socket.off('getBillingRecordReturn');
  socket.off('updateGetBillingRecord');
    super.dispose();
  }

  void tougleBillIdTodeleteBillsId(String billId) {
    if (deleteBillsId.contains(billId)) {
      setState(() {
        deleteBillsId.remove(billId);
      });
    } else {
      setState(() {
        deleteBillsId.add(billId);
      });
    }
  }

  Future<void> deleteBillRequestSubmit(BuildContext context, List<String> deleteArray) async {
    bool success = await billsService.deleteBillingRecord(context, deleteArray);

    if (success) {
      if (context.mounted) {
        showErrorSnackBar(context, "${deleteArray.length} Bill(s) was deleted.");
      }
      setState(() {
        deleteBillsId.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(
      builder: (context, value, _) {
        final doctorsBills = billingProvider.bills;
        bool isLoading = billingProvider.isLoading;
        final int totalBills = billingProvider.total;
        final theme = Theme.of(context);
        final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
        List<String> unpaidIds = doctorsBills.where((bill) => bill.status != 'Paid').map((bill) => bill.id.toString()).toList();
        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'invoiceId', label: Text(context.tr('invoiceId'))), dataType: 'string'),
          FilterableGridColumn(
              column: GridColumn(
                  columnName: roleName == 'patient' ? 'doctorProfile.fullName' : 'patientProfile.fullName',
                  label: Text(context.tr(roleName == 'patient' ? 'patientName' : "doctorName"))),
              dataType: 'string'),
          if (roleName == 'doctors')
            FilterableGridColumn(
              column: GridColumn(columnName: 'price', label: Text(context.tr('price'))),
              dataType: 'number',
            ),
            if (roleName == 'doctors')
            FilterableGridColumn(
              column: GridColumn(columnName: 'bookingsFee', label: Text(context.tr('bookingsFee'))),
              dataType: 'number',
            ),
             if (roleName == 'doctors')
            FilterableGridColumn(
              column: GridColumn(columnName: 'bookingsFeePrice', label: Text(context.tr('bookingsFeePrice'))),
              dataType: 'number',
            ),
          FilterableGridColumn(column: GridColumn(columnName: 'total', label: Text(context.tr('total'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'dueDate', label: Text(context.tr('dueDate'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'status', label: Text(context.tr('status'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'createdAt', label: Text(context.tr('createdAt'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'updateAt', label: Text(context.tr('updateAt'))), dataType: 'date'),
        ];
        return ScaffoldWrapper(
          title: context.tr('billings'),
          children: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  double per = 0;
                  if (doctorsBillingsScrollController.hasClients) {
                    per = ((doctorsBillingsScrollController.offset / doctorsBillingsScrollController.position.maxScrollExtent));
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
                child: Column(
                  children: [
                    FadeinWidget(
                      isCenter: true,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: theme.primaryColorLight),
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'totalBillings',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ).plural(
                                totalBills,
                                format: NumberFormat.compact(
                                  locale: context.locale.toString(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // confirmed delete
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.vertical,
                          child: child,
                        );
                      },
                      child: deleteBillsId.isNotEmpty
                          ? Padding(
                              key: const ValueKey("buttonVisible"),
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                child: GradientButton(
                                  onPressed: () async {
                                    final result = await showModalBottomSheet<List<String>>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => FractionallySizedBox(
                                        heightFactor: 0.4,
                                        child: Scaffold(
                                          appBar: AppBar(
                                            backgroundColor: theme.primaryColorLight,
                                            title: const Text("billForDelete").plural(
                                              deleteBillsId.length,
                                              format: NumberFormat.compact(
                                                locale: context.locale.toString(),
                                              ),
                                            ),
                                            automaticallyImplyLeading: false, // Removes the back button
                                            actions: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.close,
                                                  color: theme.primaryColor,
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                          body: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
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
                                                            "billDeleteConfirm",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.normal,
                                                              color: Theme.of(context).primaryColor,
                                                            ),
                                                          ).plural(
                                                            deleteBillsId.length,
                                                            format: NumberFormat.compact(
                                                              locale: context.locale.toString(),
                                                            ),
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
                                                      Navigator.pop(context, deleteBillsId);
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
                                      deleteBillRequestSubmit(context, result);
                                    }
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
                                      deleteBillsId.length,
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

                    //Sized box
                    const SizedBox(height: 10),
                    CustomPaginationWidget(
                      count: totalBills,
                      getDataOnUpdate: getDataOnUpdate,
                    ),
                    // const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          splashRadius: 0,
                          checkColor: theme.primaryColorLight,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                          value: deleteBillsId.isNotEmpty,
                          onChanged: (bool? value) {
                            if (value == false) {
                              setState(() {
                                deleteBillsId.clear();
                              });
                            } else {
                              setState(() {
                                deleteBillsId = unpaidIds;
                              });
                            }
                          },
                        ),
                        Text('tuggleBillForDelete',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.primaryColorLight,
                            )).plural(
                          unpaidIds.length,
                          format: NumberFormat.compact(
                            locale: context.locale.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                            controller: doctorsBillingsScrollController,
                            shrinkWrap: true,
                            restorationId: 'doctorsBills',
                            key: const ValueKey('doctorsBills'),
                            physics: const BouncingScrollPhysics(),
                            itemCount: doctorsBills.length,
                            itemBuilder: (context, index) {
                              final bill = doctorsBills[index];
                              return BillsShowBox(
                                  singleBill: bill,
                                  getDataOnUpdate: getDataOnUpdate,
                                  userType: 'doctors',
                                  deleteBillsId: deleteBillsId,
                                  tougleBillIdTodeleteBillsId: tougleBillIdTodeleteBillsId);
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
                          ScrollButton(scrollController: doctorsBillingsScrollController, scrollPercentage: scrollPercentage),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                          )
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

