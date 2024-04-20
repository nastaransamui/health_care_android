String? validatePassword(String? value) {
  const pattern =
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&])[A-Za-z\d$@$!%*#?&]{8,}$';
  final regex = RegExp(pattern);

  return value!.isNotEmpty && !regex.hasMatch(value)
      ? 'Password should be at least 8 characters long and should contain one number,one character and one special characters.'
      : null;
}
