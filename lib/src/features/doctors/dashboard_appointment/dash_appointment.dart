

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/src/features/doctors/dashboard_appointment/dash_appointment_source.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:health_care/services/appointment_service.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:provider/provider.dart';

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
     appointmentProvider.setTotal(0);
     appointmentProvider.setLoading(false);
     appointmentProvider.setAppointmentReservations([]);
    scheduleScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, _) {
        final reservations = appointmentProvider.appointmentReservations;
        final total = appointmentProvider.total;

        final theme = Theme.of(context);
        final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        final dataSource = DashAppointmentSource(appointments: reservations, context: context);
        final provider = Provider.of<DataGridProvider>(context);
        final int rowsPerPage = provider.paginationModel['pageSize']!;
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
          buildColumn(context.tr('total'), 'timeSlot.total', textColor, width: context.locale.toString() == 'th_TH' ? 150:120),
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
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 26),
                      // child: Text('Total: $total\nFirst reservation: $reservations'),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Total reservations card
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Card(
                                elevation: 12,
                                color: Theme.of(context).canvasColor,
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
                            // DataGrid
                            SfDataGridTheme(
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
                                  final isActive = isColumnFiltered(columnName, _dataGridProvider.mongoFilterModel);

                                  return GestureDetector(
                                    onTap: () async {
                                      final result = await showModalBottomSheet<Map<String, dynamic>>(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => FractionallySizedBox(
                                          heightFactor: 0.9,
                                          child: SfDataGridFilterWidget(columns: filterableColumns, columnName: columnName),
                                        ),
                                      );

                                      if (result != null) {
                                        _dataGridProvider.setMongoFilterModel({...result});
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
                                    final String direction = _dataGridProvider.sortModel.first['sort'] == 'asc' ? 'desc' : 'asc';

                                    _dataGridProvider.setSortModel([
                                      {"field": columnName, "sort": direction}
                                    ]);
                                    // Fetch the sorted data from the server
                                    await getDataOnUpdate();
                                  },
                                  columns: gridColumns,
                                ),
                              ),
                            ),

                            // Pagination widget
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  // ],
                  ScrollButton(scrollController: scheduleScrollController, scrollPercentage: scrollPercentage)
                ],
              ),
            ));
      },
    );
  }
}
