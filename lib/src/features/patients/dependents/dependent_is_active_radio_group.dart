import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DependentIsActiveRadioGroup extends StatelessWidget {
  const DependentIsActiveRadioGroup({
    super.key,
    required this.value,
    required this.theme,
    required this.onChanged,
    required this.showLabel,
    required this.name,
  });

  final bool? value;
  final ThemeData theme;
  final Function(bool?) onChanged;
  final bool showLabel;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              context.tr('isActive'),
              style: TextStyle(
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
          ),
        Wrap(
          spacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Tooltip(
              message: context.tr('isActive'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: value,
                    onChanged: onChanged,
                    visualDensity: VisualDensity.compact,
                    activeColor: theme.primaryColorLight,
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => theme.primaryColorLight,
                    ),
                  ),
                  Text(
                    // 'For my dependents'
                    context.tr('isActive'),
                    style: TextStyle(
                      color: !value!
                          ? theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black
                          : theme.primaryColorLight,
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: context.tr('notActive'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: value,
                    onChanged: onChanged,
                    visualDensity: VisualDensity.compact,
                    activeColor: theme.primaryColorLight,
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => theme.primaryColorLight,
                    ),
                  ),
                  Text(
                    context.tr('notActive'),
                    style: TextStyle(
                      color: value!
                          ? theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black
                          : theme.primaryColorLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
