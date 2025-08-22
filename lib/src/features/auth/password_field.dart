import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:health_care/src/utils/validate_password.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController passwordController;
  final String fieldName;
  const PasswordField({
    super.key,
    required this.passwordController,
    required this.fieldName,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscureText = true;
  void showPassword() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
   
    return Semantics(
      label: context.tr(widget.fieldName),
      textField: true,
      key: ValueKey(context.tr(widget.fieldName)),
      child: TextFormField(
        controller: widget.passwordController,
        enableSuggestions: true,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        validator: ((value) {
          if (value == null || value.isEmpty) {
            return context
                .tr('passwordEnter', args: [context.tr(widget.fieldName)]);
          } else {
            return validatePassword(
                context, value, context.tr(widget.fieldName));
          }
        }),
        decoration: InputDecoration(
          errorMaxLines: 3,
          errorStyle: TextStyle(
            color: Colors.redAccent.shade400,
          ),
          labelText: context.tr(widget.fieldName),
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
          prefixIcon: Icon(Icons.password, color: Theme.of(context).primaryColorLight),
          suffixIcon: IconButton(
            onPressed: showPassword,
            icon: Icon(
              _isObscureText ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).primaryColor,
            ),
          ),
          isDense: true,
          alignLabelWithHint: false,
        ),
        obscureText: _isObscureText,
      ),
    );
  }
}
