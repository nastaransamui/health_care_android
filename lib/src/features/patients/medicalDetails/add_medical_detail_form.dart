import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/shared/gradient_button.dart';

class AddMedicalDetailForm extends StatefulWidget {
  final String title;
  const AddMedicalDetailForm({
    super.key,
    required this.title,
  });

  @override
  State<AddMedicalDetailForm> createState() => _AddMedicalDetailFormState();
}

class _AddMedicalDetailFormState extends State<AddMedicalDetailForm> {
  final medicalDetailFormKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final matchedVital = vitalBoxList.firstWhere(
      (element) => element['title'] == widget.title,
      orElse: () => {},
    );
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return FormBuilder(
      key: medicalDetailFormKey,
      child: Column(
        children: [
          Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.primaryColorLight),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: context.tr('value'),
                    child: FormBuilderTextField(
                      name: 'value',
                      enableSuggestions: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.tr('required');
                        }
                        final intVal = double.tryParse(value.trim());
                        if (intVal == null || intVal <= 0) {
                          return context.tr('mustBePositiveInt');
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        errorStyle: TextStyle(color: Colors.redAccent.shade400),
                        floatingLabelStyle: TextStyle(color: theme.primaryColorLight),
                        labelStyle: TextStyle(color: theme.primaryColorLight),
                        // labelText: context.tr(key),
                        label: RichText(
                          text: TextSpan(
                            text: context.tr('value'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        hintText: context.tr('value'),
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
                        // suffix: Text(context.tr('${matchedVital["unit"]}')),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Text(
                            context.tr('${matchedVital["unit"]}'),
                            style: TextStyle(color: theme.primaryColorLight),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        filled: true,
                        isDense: true,
                        alignLabelWithHint: true,
                      ),
                      onChanged: (val) {
                        // Update the detail object directly
                        final formState = FormBuilder.of(context);
                        formState?.fields['value']?.validate();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Semantics(
                      label: context.tr('date'),
                      child: FormBuilderTextField(
                        name: 'date',
                        enabled: false,
                        initialValue: DateFormat('dd MMM yyyy HH:mm').format(DateTime.now()),
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.redAccent.shade400),
                          floatingLabelStyle: TextStyle(color: theme.primaryColorLight),
                          labelStyle: TextStyle(color: theme.primaryColorLight),
                          // labelText: context.tr(key),
                          label: Text(
                            context.tr('date'),
                            style: TextStyle(color: theme.disabledColor),
                          ),
                          hintText: context.tr('date'),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).disabledColor, width: 1),
                          ),
                          filled: true,
                          // prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
                          isDense: true,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: GradientButton(
                      onPressed: () {
                        if (medicalDetailFormKey.currentState?.saveAndValidate() ?? false) {
                          final formValues = medicalDetailFormKey.currentState!.value;
                          Navigator.pop(context, formValues);
                        }
                      },
                      colors: [
                        Theme.of(context).primaryColorLight,
                        Theme.of(context).primaryColor,
                      ],
                      child: Text(
                        context.tr("submit"),
                        style: TextStyle(fontSize: 12, color: textColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
