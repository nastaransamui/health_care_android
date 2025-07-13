import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutTextField extends StatelessWidget {
  const CheckoutTextField(
      {super.key,
      required this.controller,
      required this.theme,
      required this.textColor,
      required this.name,
      required this.onChanged,
      this.inputFormatters});

  final TextEditingController controller;
  final ThemeData theme;
  final Color textColor;
  final String name;
  final ValueChanged<String?> onChanged;
  final TextInputFormatter? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enableSuggestions: true,
      inputFormatters: inputFormatters == null ? [] : [inputFormatters!],
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      controller: controller,
      onChanged: (val) => onChanged(val),
      decoration: InputDecoration(
        errorStyle: TextStyle(color: Colors.redAccent.shade400),
        floatingLabelStyle: TextStyle(color: theme.primaryColorLight),
        labelStyle: TextStyle(color: theme.primaryColorLight),
        // labelText: context.tr(key),
        label: RichText(
          text: TextSpan(
            text: context.tr(name),
            style: TextStyle(color: textColor),
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
    );
  }
}
