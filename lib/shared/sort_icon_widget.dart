
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/favourite_service.dart';
import 'package:provider/provider.dart';

class SortIconWidget extends StatefulWidget {
  final String columnName;
  final VoidCallback getDataOnUpdate;
  const SortIconWidget({
    super.key,
    required this.columnName,
    required this.getDataOnUpdate,
  });

  @override
  State<SortIconWidget> createState() => _SortIconWidgetState();
}

class _SortIconWidgetState extends State<SortIconWidget> {
  late final DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final FavouriteService favouriteService = FavouriteService();
  bool _isProvidersInitialized = false;
  Future<void> updateSort(List<Map<String, dynamic>> newSortModel) async {
    dataGridProvider.setSortModel(newSortModel);
    widget.getDataOnUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String direction = dataGridProvider.sortModel.first['sort'] == 'asc' ? 'desc' : 'asc';
    return GestureDetector(
      onTap: () {
        updateSort([
          {"field": widget.columnName, "sort": direction}
        ]);
      },
      child: FaIcon(direction == 'desc' ? FontAwesomeIcons.arrowAltCircleDown : FontAwesomeIcons.arrowAltCircleUp,
          size: 16, color: Theme.of(context).primaryColor),
      // Icon(
      //  Icons.unfold_more,
      //   size: 16,
      //   color: Theme.of(context).primaryColor,
      // ),
    );
  }
}
