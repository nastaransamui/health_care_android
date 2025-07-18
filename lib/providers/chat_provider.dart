import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/chat_data_type.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatDataType> _userChatData = [];
  bool _isLoading = true;
  late ChatDataType? _currentRoom;
  List<ChatDataType> get userChatData => _userChatData;
  bool get isLoading => _isLoading;
  ChatDataType? get currentRoom => _isLoading ? null : _currentRoom;

  void setUserChatData(List<ChatDataType> userChatData, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _userChatData = userChatData;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = false;
      if (notify) notifyListeners();

      _userChatData = userChatData;
      if (notify) notifyListeners();
    }
  }

  void setCurrentRoom(ChatDataType? currentRoom, {bool notify = true}) {
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay setting the actual value to next frame
        WidgetsBinding.instance.addPostFrameCallback((__) {
          _currentRoom = currentRoom;
          // _isLoading = false;
          if (notify) notifyListeners();
        });
        if (notify) notifyListeners();
      });
    } else {
      // We're not in a build phase, so safe to update immediately
      _isLoading = false;
      if (notify) notifyListeners();

      _currentRoom = currentRoom;
      // _isLoading = false;
      if (notify) notifyListeners();
    }
  }

  void setLoading(bool value, {bool notify = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading = value;
      if (notify) notifyListeners();
    });
  }
}
