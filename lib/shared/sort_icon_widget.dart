
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:provider/provider.dart';


class SortIconWidget extends StatelessWidget {
  final String columnName;
  final VoidCallback getDataOnUpdate;

  const SortIconWidget({
    super.key,
    required this.columnName,
    required this.getDataOnUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<DataGridProvider, String?>(
      selector: (_, provider) => provider.sortModel.first["field"] as String?,
      builder: (context, activeField, child) {
        final bool isActive = columnName == activeField;
        final String direction = context.read<DataGridProvider>().sortModel.first['sort'] == 'asc'
            ? 'desc'
            : 'asc';

        return GestureDetector(
          onTap: () {
            context.read<DataGridProvider>().setSortModel([
              {"field": columnName, "sort": direction}
            ]);
            getDataOnUpdate();
          },
          child: Padding(
            padding: EdgeInsets.only(right: isActive ? 0 : 3),
            child: FaIcon(
              !isActive
                  ? FontAwesomeIcons.sort
                  : direction == 'desc'
                      ? FontAwesomeIcons.arrowAltCircleDown
                      : FontAwesomeIcons.arrowAltCircleUp,
              size: 16,
              color: isActive
                  ? Theme.of(context).primaryColorLight
                  : Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }
}