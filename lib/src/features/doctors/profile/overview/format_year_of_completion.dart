import 'package:easy_localization/easy_localization.dart';

String formatYearOfCompletion(String value) {
  try {
    // If it's only a 4-digit year, add "-01-01" to make it a valid date
    final normalized = RegExp(r'^\d{4}$').hasMatch(value)
        ? '$value-01-01'
        : value;
    final date = DateTime.parse(normalized);
    return DateFormat('dd MMM yyyy').format(date);
  } catch (e) {
    return value; // Fallback to raw value if parsing fails
  }
}