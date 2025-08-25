import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class IsForDependentRadioGroup extends StatelessWidget {
  const IsForDependentRadioGroup({
    super.key,
    required this.value,
    required this.isView,
    required this.theme,
    required this.onChanged,
    required this.showLabel,
    required this.name,
  });

  final bool? value;
  final bool isView;
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
              context.tr('isForDependent'),
              style: TextStyle(
                color: isView
                    ? theme.disabledColor
                    : theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
              ),
            ),
          ),
        Wrap(
          spacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Tooltip(
                message: isView ? '' : context.tr('addMedicalForMyDependents'),
                child: RadioGroup(
                  // onChanged: isView ? null : onChanged,
                  onChanged: onChanged,
                  groupValue: value,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: true,
                        visualDensity: VisualDensity.compact,
                        activeColor: theme.primaryColorLight,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (states) => isView ? theme.disabledColor : theme.primaryColorLight,
                        ),
                      ),
                      Text(
                        // 'For my dependents'
                        context.tr('forMyDependents'),
                        style: TextStyle(
                          color: isView
                              ? theme.disabledColor
                              : !value!
                                  ? theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black
                                  : theme.primaryColorLight,
                        ),
                      ),
                    ],
                  ),
                )),
            Tooltip(
                message: isView ? '' : context.tr('addMedicalRecorForMyself'),
                child: RadioGroup(
                  onChanged: onChanged,
                  // onChanged: isView ? null : onChanged,
                  groupValue: value,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: false,
                        visualDensity: VisualDensity.compact,
                        activeColor: theme.primaryColorLight,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (states) => isView ? theme.disabledColor : theme.primaryColorLight,
                        ),
                      ),
                      Text(
                        context.tr('forMyself'),
                        style: TextStyle(
                          color: isView
                              ? theme.disabledColor
                              : value!
                                  ? theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black
                                  : theme.primaryColorLight,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ],
    );
  }
}
