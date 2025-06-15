import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:health_care/models/medical_records.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.medicalRecord,
    required this.formType,
    required this.theme,
    required this.textColor,
    required this.name,
    required this.isForDependentValue,
    this.controller,
  });

  final MedicalRecords medicalRecord;
  final String formType;
  final ThemeData theme;
  final Color textColor;
  final String name;
  final bool isForDependentValue;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final recordMap = medicalRecord.toMap(); // assuming toJson() exists
    final initialValue = recordMap[name];
    bool isEnable;

    if (formType == 'view') {
      isEnable = false;
    } else if (name == 'firstName' || name == 'lastName') {
      isEnable = !isForDependentValue;
    } else {
      isEnable = true;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Semantics(
        label: context.tr(name),
        child: FormBuilderTextField(
          name: name,
          initialValue: controller == null ? initialValue : null,
          controller: controller,
          enabled: isEnable,
          showCursor: name != 'date',
          keyboardType: name == 'date' ? TextInputType.none : TextInputType.name,
          enableInteractiveSelection: name != 'date',
          onTap: name != 'date'
              ? null
              : () async {
                  FocusScope.of(context).requestFocus(FocusNode());

                  // Cache context-related data
                  final formFieldKey = context.tr(name);
                  final formState = FormBuilder.of(context);
                  final currentContext = context;

                  final pickedDate = await showDatePicker(
                    context: currentContext,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1924),
                    lastDate: DateTime.now(),
                    initialDatePickerMode: DatePickerMode.year,
                  );

                  if (pickedDate == null) return;

                  final pickedTime = await showTimePicker(
                    // ignore: use_build_context_synchronously
                    context: currentContext,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime == null) return;

                  final combinedDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );

                  final formatted = DateFormat('dd MMM yyyy – hh:mm a').format(combinedDateTime);

                  formState?.fields[formFieldKey]?.didChange(formatted);
                },
          enableSuggestions: true,
          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
          autovalidateMode: formType != 'view' ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          validator: formType != 'view'
              ? (fieldValue) {
                  if (fieldValue == null || fieldValue.isEmpty) {
                    return context.tr('required');
                  }
                  return null;
                }
              : null,
          maxLines: name == 'symptoms' || name == 'description' ? 5 : 1,
          decoration: InputDecoration(
            errorStyle: TextStyle(color: Colors.redAccent.shade400),
            floatingLabelStyle: TextStyle(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight),
            labelStyle: TextStyle(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight),
            // labelText: context.tr(key),
            label: RichText(
              text: TextSpan(
                text: context.tr(name),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: formType == 'view' ? theme.disabledColor : textColor),
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            hintText: context.tr(name),
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
