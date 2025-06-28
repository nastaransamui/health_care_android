import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AvailableSelectWidget extends StatelessWidget {
  const AvailableSelectWidget({
    super.key,
    required this.textColor,
    required this.chosenModel,
    required this.availabilityValues,
    required this.localQueryParams,
    required this.onAvaliablityChange,
  });
  final Color textColor;
  final String chosenModel;
  final List<Map<String, dynamic>> availabilityValues;
  final Map<String, String> localQueryParams;
  final void Function(String?, Map<String, String>) onAvaliablityChange;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
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
            value: chosenModel,
            items: availabilityValues.map<DropdownMenuItem<String>>((Map<String, dynamic> values) {
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
              onAvaliablityChange(newValue, localQueryParams);
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
