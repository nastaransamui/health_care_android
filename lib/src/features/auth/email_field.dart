import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/utils/validate_email.dart';

class EmailField extends StatefulWidget {
  final TextEditingController emailController;
  const EmailField({
    super.key,
    required this.emailController,
  });

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('email'),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: widget.emailController,
        enableSuggestions: true,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        validator: ((value) {
          if (value == null || value.isEmpty) {
            return context.tr('emailEnter');
          } else {
            return validateEmail(value);
          }
        }),
        decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.redAccent.shade400),
          labelText: context.tr('email'),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
          fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
          filled: true,
           prefixIcon:  Icon(Icons.email_sharp, color: Theme.of(context).primaryColorLight),
          isDense: true,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
