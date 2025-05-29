import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FirstNameField extends StatefulWidget {
  final TextEditingController firstNameController;
  const FirstNameField({
    super.key,
    required this.firstNameController,
  });

  @override
  State<FirstNameField> createState() => _FirstNameFieldState();
}

class _FirstNameFieldState extends State<FirstNameField> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('firstName'),
      child: TextFormField(
        keyboardType: TextInputType.name,
        controller: widget.firstNameController,
        enableSuggestions: true,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        validator: ((value) {
          if (value == null || value.isEmpty) {
            return context.tr('firstNameEnter');
          } else {
            if(value.length <2){
              return context.tr('minFirstName');
            }
          }
          return null;
        }),
        decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.redAccent.shade400),
          labelText: context.tr('firstName'),
          hintText: context.tr('firstName'),
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
         fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
          filled: true,
          prefixIcon:  Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
          isDense: true,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
