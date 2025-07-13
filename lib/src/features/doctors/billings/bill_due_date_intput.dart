import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:timezone/timezone.dart' as tz;

class BillDueDateIntput extends StatelessWidget {
  const BillDueDateIntput({
    super.key,
    required this.formType,
    required this.theme,
    required this.textColor,
    this.dueDate,
  });
  final String formType;
  final ThemeData theme;
  final Color textColor;
  final DateTime? dueDate;

  @override
  Widget build(BuildContext context) {
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Semantics(
        label: context.tr('dueDate'),
        child: FormBuilderTextField(
          enabled: formType != 'view',
          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
          keyboardType: TextInputType.none,
          autovalidateMode: formType != 'view' ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          enableInteractiveSelection: false,
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());

            // Cache context-related data
            const formFieldKey = 'dueDate';
            final formState = FormBuilder.of(context);
            final currentContext = context;

            final pickedDate = await showDatePicker(
              context: currentContext,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2050),
              initialDatePickerMode: DatePickerMode.year,
            );

            if (pickedDate == null) return;

            final combinedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
            );

            final formatted = DateFormat('dd MMM yyyy ').format(combinedDateTime);

            formState?.fields[formFieldKey]?.didChange(formatted);
          },
          validator: formType != 'view'
              ? (fieldValue) {
                  if (fieldValue == null || fieldValue.isEmpty) {
                    return context.tr('required');
                  }
                  return null;
                }
              : null,
          name: 'dueDate',
          initialValue: dueDate == null
              ? ''
              : DateFormat('dd MMM yyyy').format(
                  tz.TZDateTime.from(dueDate!, bangkok),
                ),
          decoration: InputDecoration(
            errorStyle: TextStyle(color: Colors.redAccent.shade400),
            floatingLabelStyle: TextStyle(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight),
            labelStyle: TextStyle(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight),
            // labelText: context.tr(key),
            label: RichText(
              text: TextSpan(
                text: context.tr('dueDate'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: formType == 'view' ? theme.disabledColor : textColor),
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            hintText: context.tr('dueDate'),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).disabledColor, width: 1),
            ),
            fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
            filled: true,
            // prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
            isDense: true,
            alignLabelWithHint: true,
          ),
        ),
      ),
    );
  }
}
