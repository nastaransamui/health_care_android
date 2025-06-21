import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:health_care/models/dependents.dart';

class DependentTextInput extends StatelessWidget {
  const DependentTextInput({
    super.key,
    required this.dependent,
    required this.theme,
    required this.textColor,
    required this.name,
    this.controller,
  });

  final Dependents dependent;
  final ThemeData theme;
  final Color textColor;
  final String name;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final recordMap = dependent.toMap(); // assuming toJson() exists
    final initialValue = recordMap[name];
    bool isEnable;

    if (name == 'createdAt' || name == 'updateAt') {
      isEnable = false;
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
          showCursor: name != 'dob',
          keyboardType: name == 'dob' ? TextInputType.none : TextInputType.name,
          enableInteractiveSelection: name != 'dob',
          onTap: name != 'dob'
              ? null
              : () async {
                  FocusScope.of(context).requestFocus(FocusNode());

                  // Cache context-related data
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

                  String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);

                  formState?.fields[name]?.didChange(formattedDate);
                },
          enableSuggestions: true,
          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: name == 'firstName' || name == 'lastName' || name == 'relationShip'
              ? (fieldValue) {
                  if (fieldValue == null || fieldValue.isEmpty) {
                    return context.tr('required');
                  }
                  return null;
                }
              : null,
          decoration: dependentInputDecoration(context),
        ),
      ),
    );
  }

  InputDecoration dependentInputDecoration(BuildContext context) {
    return InputDecoration(
          errorStyle: TextStyle(color: Colors.redAccent.shade400),
          floatingLabelStyle: TextStyle(color: theme.primaryColorLight),
          labelStyle: TextStyle(color: theme.primaryColorLight),
          // labelText: context.tr(key),
          label: RichText(
            text: TextSpan(
              text: context.tr(name),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
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
            borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
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
        );
  }
}
