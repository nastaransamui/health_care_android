import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatDataType> _userChatData = [];
  bool _isLoading = true;
  ChatDataType? _currentRoom; 

  List<ChatDataType> get userChatData => _userChatData;
  bool get isLoading => _isLoading;
  ChatDataType? get currentRoom => _isLoading ? null : _currentRoom;

  void setUserChatData(List<ChatDataType> userChatData, {bool notify = true}) {
    _userChatData = userChatData;
    _isLoading = false;
    if (notify) notifyListeners();
  }

  void setCurrentRoom(ChatDataType? currentRoom, {bool notify = true}) {
    _currentRoom = currentRoom;
    _isLoading = false;
    if (notify) notifyListeners();
  }

  void setLoading(bool value, {bool notify = true}) {
    _isLoading = value;
    if (notify) notifyListeners();
  }
}