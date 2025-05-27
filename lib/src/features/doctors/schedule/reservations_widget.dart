import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/src/features/doctors/schedule/appointment_data_source.dart';

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
      {"field": "id", "sort": 'asc'}
    ], notify: false);
    _dataGridProvider.setMongoFilterModel({}, notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final dataSource = AppointmentDataSource(appointments: widget.doctorTimeSlot?.reservations ?? [], context: context);
    final provider = Provider.of<DataGridProvider>(context);
    final int rowsPerPage = provider.paginationModel['pageSize']!;
    final List<GridColumn> gridColumns = [
      buildColumn(context.tr('id'), 'id', textColor, width: 100),
      buildColumn(context.tr('reserveDate'), 'createdDate', textColor, width: 180),
      buildColumn(context.tr('dayTime'), 'dayPeriod', textColor, width: 150),
      buildColumn(context.tr('invoiceNo'), 'invoiceId', textColor, width: 150),
      buildColumn(context.tr('selectedDate'), 'selectedDate', textColor, width: 180),
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
    ];
    final List<FilterableGridColumn> filterableColumns = [
      FilterableGridColumn(column: gridColumns[0], dataType: 'number'),
      FilterableGridColumn(column: gridColumns[1], dataType: 'date'),
      FilterableGridColumn(column: gridColumns[2], dataType: 'string'),
      FilterableGridColumn(column: gridColumns[3], dataType: 'string'),
      FilterableGridColumn(column: gridColumns[4], dataType: 'date'),
      FilterableGridColumn(column: gridColumns[5], dataType: 'string'),
      FilterableGridColumn(column: gridColumns[6], dataType: 'string'),
    ];

    return SingleChildScrollView(
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
    );
  }
}
