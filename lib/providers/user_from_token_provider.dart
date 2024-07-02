import 'package:flutter/material.dart';
import 'package:health_care/models/user_from_token.dart';


class UserFromTokenProvider extends ChangeNotifier {
  UserFromToken? _userFromToken;

  UserFromToken? get userFromToken => _userFromToken;

  void setUserFromToken(UserFromToken userFromToken) {
    _userFromToken = userFromToken;

    notifyListeners();
  }
}
