import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/models/incoming_call.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatDataType> _userChatData = [];
  bool _isLoading = true;
  ChatDataType? _currentRoom;
  bool _endCall = false;
  bool _isAcceptCall = false;
  IncomingCall? _incomingCall;
  final List<String> _showEmptyRoomInSearchList = [];

  List<ChatDataType> get userChatData => _userChatData;
  bool get isLoading => _isLoading;
  ChatDataType? get currentRoom => _isLoading ? null : _currentRoom;
  bool get endCall => _endCall;
  bool get isAcceptCall => _isAcceptCall;
  IncomingCall? get incomingCall => _incomingCall;
  List<String> get showEmptyRoomInSearchList => _showEmptyRoomInSearchList;

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

  void setEndCall(bool value, {bool notify = true}) {
    _endCall = value;
    if (notify) notifyListeners();
  }

  void setIsAcceptCall(bool value, {bool notify = true}) {
    _isAcceptCall = value;
    if (notify) notifyListeners();
  }

    void setIncomingCall(IncomingCall? incomingCall, {bool notify = true}) {
    _incomingCall = incomingCall;
    if (notify) notifyListeners();
  }

  void setShowEmptyRoomInSearchList(String roomId, {bool notify = true}){
    _showEmptyRoomInSearchList.add(roomId);
     if (notify) notifyListeners();
  }
    void clearUserSearchAutocompleteReturn({bool notify = true}){
    _showEmptyRoomInSearchList.clear();
     if (notify) notifyListeners();
  }
}
