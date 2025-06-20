import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
// import 'package:health_care/services/time_schedule_service.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';

class CustomPaginationWidget extends StatefulWidget {
  final int count;
  final Future<void> Function() getDataOnUpdate;

  const CustomPaginationWidget({super.key, required this.count, required this.getDataOnUpdate});

  @override
  State<CustomPaginationWidget> createState() => _CustomPaginationWidgetState();
}

class _CustomPaginationWidgetState extends State<CustomPaginationWidget> {
  late final DataPagerController _pagerController;
  late final DataGridProvider _dataGridProvider;
  bool _isDataGridProviderInitialized = false;

  @override
  void initState() {
    super.initState();
    _pagerController = DataPagerController();
    // _pagerController.selectedPageIndex = 0;
  }

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
    _dataGridProvider.setPaginationModel(0, 10, notify: false);
    _pagerController.selectedPageIndex = 0;
    _pagerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = Provider.of<DataGridProvider>(context, listen: false).mongoFilterModel;

    final int rowsPerPage = _dataGridProvider.paginationModel['pageSize']!;
    final int totalPages = (widget.count / rowsPerPage).ceil();
    //  change current page if totalFavourites is less that current page
    int currentPage = _dataGridProvider.paginationModel.values.first;
    int currentPerPage = _dataGridProvider.paginationModel.values.last;
    if (currentPage != 0) {
      if ((currentPage + currentPerPage) > widget.count) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _dataGridProvider.setPaginationModel(currentPage - 1, currentPerPage);
          _pagerController.selectedPageIndex = currentPage - 1;
        });
      }
    }
    final delegate = CustomDataPagerDelegate(
      itemCount: widget.count,
      rowsPerPage: rowsPerPage,
      onPageChanged: (pageIndex) async {
        _dataGridProvider.setPaginationModel(pageIndex, rowsPerPage);
        widget.getDataOnUpdate();

        return true;
      },
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Prevents vertical overflow
        children: [
          // Page Controls

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8), // Optional: add side padding
            child: SfDataPagerTheme(
              data: SfDataPagerThemeData(
                backgroundColor: Colors.transparent,
                itemColor: theme.primaryColorLight,
                selectedItemColor: theme.primaryColor,
                itemTextStyle: const TextStyle(color: Colors.black),
                selectedItemTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                itemBorderColor: theme.primaryColorLight,
                itemBorderWidth: 1.0,
              ),
              child: widget.count == 0
                  ? const SizedBox.shrink()
                  : SizedBox(
                    child: Center(
                      child: SfDataPager(
                          controller: _pagerController,
                          pageCount: totalPages > 0 ? totalPages.toDouble() : 1,
                          delegate: delegate,
                          visibleItemsCount: 3,
                          direction: Axis.horizontal,
                          availableRowsPerPage: const [5, 10],
                        ),
                    ),
                  ),
            ),
          ),
          // Rows per page
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('rowsPerPage')),
              DropdownButton<int>(
                value: rowsPerPage,
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5')),
                  DropdownMenuItem(value: 10, child: Text('10')),
                ],
                onChanged: (value) async {
                  if (value != null) {
                    final int totalPagesAfterChange = (widget.count / value).ceil();
                    final int currentPage = _pagerController.selectedPageIndex;

                    // If current page is now out of range, reset to last valid page (or 0)
                    if (currentPage >= totalPagesAfterChange) {
                      final int newPage = totalPagesAfterChange > 0 ? totalPagesAfterChange - 1 : 0;
                      _pagerController.selectedPageIndex = newPage;
                      _dataGridProvider.setPaginationModel(newPage, value);
                    } else {
                      _pagerController.selectedPageIndex = 0; // ✅ Add this
                      _dataGridProvider.setPaginationModel(0, value); // ✅ reset to page 0
                    }
                    await widget.getDataOnUpdate();
                  }
                },
              ),
            ],
          ),
          if (filter.isNotEmpty) ...[
            ElevatedButton(
              onPressed: () async {
                _dataGridProvider.setMongoFilterModel({});
                await widget.getDataOnUpdate();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width, 40),
                elevation: 5.0,
                foregroundColor: Colors.black,
                animationDuration: const Duration(milliseconds: 1000),
                backgroundColor: Theme.of(context).primaryColor,
                shadowColor: Theme.of(context).primaryColor,
              ),
              // style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(
                context.tr("clearFilters"),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class CustomDataPagerDelegate extends DataPagerDelegate {
  final int itemCount;
  final int rowsPerPage;
  final Future<bool> Function(int pageIndex) onPageChanged;

  CustomDataPagerDelegate({
    required this.itemCount,
    required this.rowsPerPage,
    required this.onPageChanged,
  });

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    return await onPageChanged(newPageIndex);
  }
}
