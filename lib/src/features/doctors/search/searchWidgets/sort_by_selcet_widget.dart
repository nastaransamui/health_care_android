import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SortBySelcetWidget extends StatelessWidget {
  const SortBySelcetWidget({
    super.key,
    required this.textColor,
    required this.sortByModel,
    required this.sortByValues,
    required this.localQueryParams,
    required this.onSortByChange,
  });
  final Color textColor;
  final String sortByModel;
  final List<Map<String, dynamic>> sortByValues;
  final Map<String, String> localQueryParams;
  final void Function(String?, Map<String, String>) onSortByChange;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      // flex: 3,
      child: InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
          enabledBorder: OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
          ),
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            iconEnabledColor: Theme.of(context).primaryColorLight,
            style: const TextStyle(
              fontSize: 12.0,
            ),
            isExpanded: true,
            value: sortByModel,
            items: sortByValues.map<DropdownMenuItem<String>>((Map<String, dynamic> values) {
              return DropdownMenuItem<String>(
                value: values['value'],
                child: Text(
                  values['value']!,
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              onSortByChange(newValue, localQueryParams);
            },
            hint: Text(
              context.tr('availability'),
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
