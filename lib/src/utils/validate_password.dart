import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String? validatePassword(BuildContext context, String value, String name) {
  const pattern =
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&])[A-Za-z\d$@$!%*#?&]{8,}$';
  final regex = RegExp(pattern);

  return value.isNotEmpty && !regex.hasMatch(value)
      // ? '$name should be at least 8 characters long and should contain one number,one character and one special characters.'
      ? context.tr('passwordEnter', args: [context.tr(name)])
      : null;
}
