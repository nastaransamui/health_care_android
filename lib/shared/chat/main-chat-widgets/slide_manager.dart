import 'package:flutter/material.dart';
import 'package:flutter_slidable_panel/controllers/slide_controller.dart';

class SlideManager {
  static final ValueNotifier<SlideController?> active = ValueNotifier(null);

  static void activate(SlideController controller) {
    if (active.value != controller) {
      active.value?.dismiss(); // Close previously open panel
      active.value = controller;
    }
  }

  static void clear(SlideController controller) {
    if (active.value == controller) active.value = null;
  }
}
