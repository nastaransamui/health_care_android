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
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
          fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
          filled: true,
          prefixIcon: const Icon(Icons.abc),
          isDense: true,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
