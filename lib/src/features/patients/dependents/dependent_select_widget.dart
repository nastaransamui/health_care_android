import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class DependentSelectWidget extends StatelessWidget {
  const DependentSelectWidget({
    super.key,
    required this.controller,
    required this.name,
    required this.theme,
    required this.textColor,
    required this.valueArray,
  });

  final TextEditingController controller;
  final ThemeData theme;
  final Color textColor;
  final List<Map<String, dynamic>> valueArray;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormBuilderDropdown<String>(
        name: name,
        initialValue: controller.text,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: textColor),
          labelText: context.tr(name),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.primaryColorLight, width: 1),
          ),
        ),
        items: valueArray.map((value) {
          return DropdownMenuItem<String>(
            value: value['title'],
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(value['icon']!),
                ),
                const SizedBox(width: 10),
                Text(
                  value['title']!,
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return valueArray.map((gender) {
            return Text(gender['title']);
          }).toList();
        },
        onChanged: (gender) {
          controller.text = gender!;
        },
      ),
    );
  }
}
