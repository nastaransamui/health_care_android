import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/utils/validate_password.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController passwordController;
  const PasswordField({
    super.key,
    required this.passwordController,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscureText = true;
  showPassword() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('password'),
      textField: true,
      child: TextFormField(
        controller: widget.passwordController,
        enableSuggestions: true,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        validator: ((value) {
          if (value == null || value.isEmpty) {
            return context.tr('passwordEnter');
          } else {
            return validatePassword(value);
          }
        }),
        decoration: InputDecoration(
          errorMaxLines: 3,
          errorStyle: TextStyle(
            color: Colors.redAccent.shade400,
          ),
          labelText: context.tr('password'),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
          fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
          filled: true,
          prefixIcon: const Icon(Icons.password),
          suffixIcon: IconButton(
            onPressed: showPassword,
            icon: Icon(
              _isObscureText ? Icons.visibility_off : Icons.visibility,
            ),
          ),
          isDense: true,
          alignLabelWithHint: true,
        ),
        obscureText: _isObscureText,
      ),
    );
  }
}
