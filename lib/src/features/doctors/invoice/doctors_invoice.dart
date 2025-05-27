
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/invoice_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/invoices_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/invoice/invoice_data_sort.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
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
    invoiceProvider.setAppointmentReservations([]);
    invoiceProvider.setTotal(0);
    invoiceScrollController.dispose();
    dataGridProvider.setSortModel([
      {"field": "id", "sort": 'asc'}
    ], notify: false);
    dataGridProvider.setMongoFilterModel({}, notify: false);
    dataGridProvider.setPaginationModel(0, 10, notify: false);
    selectedIdsNotifier.dispose();
    super.dispose();
  }

  Future<void> updateAppointmentRequestSubmit(BuildContext context, List<String> updateStatusArray) async {
    try {
      getDataOnUpdate();
    // ignore: empty_catches
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, _) {
        final theme = Theme.of(context);
        final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

        final myInvoices = invoiceProvider.appointmentReservations;
        final dataSource = InvoiceDataSort(
          appointments: myInvoices,
          context: context,
          selectedIds: selectedAppointmentIds,
          selectedIdsNotifier: selectedIdsNotifier,
          updateAppointmentRequestSubmit: updateAppointmentRequestSubmit,
        );
        final total = invoiceProvider.total;
        final int rowsPerPage = dataGridProvider.paginationModel['pageSize']!;
        final List<GridColumn> gridColumns = [
          GridColumn(
            columnName: 'select',
            width: 50,
            allowFiltering: false,
            allowSorting: false,
            label: ValueListenableBuilder(
                valueListenable: dataSource.selectedIdsNotifier,
                builder: (context, _, __) {
                  final selectableRowIds = dataSource.rows.where((row) {
                    final String doctorPaymentStatus = row.getCells().firstWhere((cell) => cell.columnName == 'doctorPaymentStatus').value;

                    final selectedDateMap = row.getCells().firstWhere((cell) => cell.columnName == 'selectedDate').value;

                    final DateTime selectedDate = selectedDateMap["date"];
                    final String period = selectedDateMap["period"];

                    // Use the same logic as in the row checkboxes
                    return doctorPaymentStatus == 'Awaiting Request' && !disablePastTime(selectedDate, period);
                  }).map((row) {
                    return row.getCells().firstWhere((cell) => cell.columnName == 'select').value;
                  }).toList();

                  final allSelectableSelected = selectableRowIds.isNotEmpty && selectableRowIds.every((id) => dataSource.selectedIds.contains(id));

                  return Center(
                    child: Checkbox(
                      value: allSelectableSelected,
                      onChanged: (bool? value) {
                        if (value == true) {
                          dataSource.selectedIds.clear();

                          for (var row in dataSource.rows) {
                            final String id = row.getCells().firstWhere((cell) => cell.columnName == 'select').value;
                            final String doctorPaymentStatus = row.getCells().firstWhere((cell) => cell.columnName == 'doctorPaymentStatus').value;

                            final selectedDateMap = row.getCells().firstWhere((cell) => cell.columnName == 'selectedDate').value;

                            final DateTime selectedDate = selectedDateMap["date"];
                            final String period = selectedDateMap["period"];

                            final bool isSelectable = doctorPaymentStatus == 'Awaiting Request' && !disablePastTime(selectedDate, period);

                            if (isSelectable) {
                              dataSource.selectedIds.add(id);
                            }
                          }
                        } else {
                          dataSource.selectedIds.clear();
                        }

                        dataSource.selectedIdsNotifier.value = List.from(dataSource.selectedIds);
                        dataSource.notifyListeners();
                      },
                    ),
                  );
                }),
          ),
          buildColumn(context.tr('id'), 'id', textColor, width: 100),
          buildColumn(context.tr('reserveDate'), 'createdDate', textColor, width: 180),
          buildColumn(context.tr('dayTime'), 'dayPeriod', textColor, width: 150),
          buildColumn(context.tr('selectedDate'), 'selectedDate', textColor, width: 180),
          buildColumn(context.tr('invoiceNo'), 'invoiceId', textColor, width: context.locale.toString() == 'th_TH' ? 200 : 150),
          buildColumn(context.tr('price'), 'timeSlot.price', textColor, width: 120),
          buildColumn(context.tr('bookingsFee'), 'timeSlot.bookingsFee', textColor, width: context.locale.toString() == 'th_TH' ? 200 : 160),
          buildColumn(context.tr('bookingsFeePrice'), 'timeSlot.bookingsFeePrice', textColor,
              width: context.locale.toString() == 'th_TH' ? 220 : 200),
          buildColumn(context.tr('total'), 'timeSlot.total', textColor, width: context.locale.toString() == 'th_TH' ? 150 : 120),
          buildColumn(context.tr('paymentType'), 'paymentType', textColor),
          buildColumn(context.tr('paymentToken'), 'paymentToken', textColor),
          buildColumn(context.tr('paymentDate'), 'paymentDate', textColor, width: 180),
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
          buildColumn(context.tr('paymentStatus'), 'doctorPaymentStatus', textColor, width: 180),
          GridColumn(
            columnName: 'actions',
            label: Center(
              child: Text(
                context.tr('actions'),
                style: TextStyle(color: textColor),
              ),
            ),
            width: 150,
          )
        ];
        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: gridColumns[0], dataType: 'number'),
          FilterableGridColumn(column: gridColumns[1], dataType: 'date'),
          FilterableGridColumn(column: gridColumns[2], dataType: 'string'),
          FilterableGridColumn(column: gridColumns[3], dataType: 'date'),
          FilterableGridColumn(column: gridColumns[4], dataType: 'string'),
          FilterableGridColumn(column: gridColumns[5], dataType: 'number'),
          FilterableGridColumn(column: gridColumns[6], dataType: 'number'),
          FilterableGridColumn(column: gridColumns[7], dataType: 'number'),
          FilterableGridColumn(column: gridColumns[8], dataType: 'number'),
          FilterableGridColumn(column: gridColumns[9], dataType: 'string'),
          FilterableGridColumn(column: gridColumns[10], dataType: 'string'),
          FilterableGridColumn(column: gridColumns[11], dataType: 'date'),
          FilterableGridColumn(column: gridColumns[12], dataType: 'string'),
          FilterableGridColumn(column: gridColumns[13], dataType: 'string')
        ];

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
                                color: Theme.of(context).canvasColor,
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
                                          final result = await showModalBottomSheet<List<String>>(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) => FractionallySizedBox(
                                              heightFactor: 0.4,
                                              child: Scaffold(
                                                appBar: AppBar(
                                                  backgroundColor: theme.primaryColorLight,
                                                  title: Text(context.tr("selectColumn")),
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
                          // DataGrid
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SfDataGridTheme(
                              data: SfDataGridThemeData(
                                filterIcon: Builder(builder: (context) {
                                  // Step 1: Find GridHeaderCell (which has the column info)
                                  String columnName = '';
                                  context.visitAncestorElements((element) {
                                    if (element.runtimeType.toString().contains('GridHeaderCellElement')) {
                                      try {
                                        final column = (element as dynamic).column;
                                        if (column != null && column is GridColumn) {
                                          columnName = column.columnName;
                                          return false;
                                        }
                                      } catch (_) {}
                                    }
                                    return true;
                                  });
                                  final isActive = isColumnFiltered(columnName, dataGridProvider.mongoFilterModel);

                                  return GestureDetector(
                                    onTap: () async {
                                      final result = await showModalBottomSheet<Map<String, dynamic>>(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => FractionallySizedBox(
                                          heightFactor: 0.5,
                                          child: SfDataGridFilterWidget(columns: filterableColumns, columnName: columnName),
                                        ),
                                      );

                                      if (result != null) {
                                        dataGridProvider.setMongoFilterModel({...result});
                                        await getDataOnUpdate();
                                      }
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Icon(
                                          Icons.filter_alt_outlined,
                                          size: 20,
                                          color: isActive ? theme.primaryColor : theme.primaryColorLight,
                                        ),
                                        if (isActive)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: theme.primaryColorLight,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                                gridLineColor: theme.primaryColorLight,
                                gridLineStrokeWidth: 1.0,

                                // headerColor: theme.primaryColor,
                                sortIconColor: theme.primaryColorLight,
                                filterIconColor: theme.primaryColorLight,
                              ),
                              child: SizedBox(
                                height: (rowsPerPage + 1) * 70,
                                child: SfDataGrid(
                                  source: dataSource,
                                  gridLinesVisibility: GridLinesVisibility.both,
                                  headerGridLinesVisibility: GridLinesVisibility.both,
                                  allowSorting: true,
                                  allowMultiColumnSorting: true,
                                  showSortNumbers: true,
                                  allowFiltering: true,
                                  rowHeight: 70,
                                  onColumnSortChanged: (newSortedColumn, oldSortedColumn) async {
                                    final String columnName = newSortedColumn!.name;
                                    final String direction = dataGridProvider.sortModel.first['sort'] == 'asc' ? 'desc' : 'asc';

                                    dataGridProvider.setSortModel(
                                      [
                                        {"field": columnName, "sort": direction}
                                      ],
                                    );
                                    // Fetch the sorted data from the server
                                    await getDataOnUpdate();
                                  },
                                  columns: gridColumns,
                                ),
                              ),
                            ),
                          ),

                          // Pagination widget
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  ScrollButton(scrollController: invoiceScrollController, scrollPercentage: scrollPercentage)
                ],
              ),
            );
          },
        );
      },
    );
  }
}
