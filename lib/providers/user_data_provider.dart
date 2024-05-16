

import 'package:flutter/material.dart';
import 'package:health_care/models/user_data.dart';

class UserDataProvider extends ChangeNotifier{
   UserData? _userData ;

   UserData? get userData => _userData;

   void setUserData(UserData userData){
  
  _userData = userData;

    notifyListeners();
   }
}