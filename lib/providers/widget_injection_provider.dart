import 'package:flutter/material.dart';

class WidgetInjectionProvider extends ChangeNotifier {
  Widget? injectedWidget;

  void inject(Widget widget) {
    injectedWidget = widget;
    notifyListeners();
  }

  void clear() {
    injectedWidget = null;
    notifyListeners();
  }
}
