import 'package:easy_localization/easy_localization.dart';

bool isDueDatePassed(String dueDateStr) {
  try {
    final date = DateFormat('dd MMM yyyy').parse(dueDateStr);
    return date.isBefore(DateTime.now());
  } catch (e) {
    return false;
  }
}
