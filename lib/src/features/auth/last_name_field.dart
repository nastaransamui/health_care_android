import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LastNameField extends StatefulWidget {
  final TextEditingController lastNameController;
  const LastNameField({
    super.key,
    required this.lastNameController,
  });

  @override
  State<LastNameField> createState() => _LastNameFieldState();
}

class _LastNameFieldState extends State<LastNameField> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('lastName'),
      child: TextFormField(
        keyboardType: TextInputType.name,
        controller: widget.lastNameController,
        enableSuggestions: true,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        validator: ((value) {
          if (value == null || value.isEmpty) {
            return context.tr('lastNameEnter');
          } else {
            if(value.length <2){
              return context.tr('minLastName');
            }
          }
          return null;
        }),
        decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.redAccent.shade400),
          labelText: context.tr('lastName'),
          hintText: context.tr('lastName'),
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
