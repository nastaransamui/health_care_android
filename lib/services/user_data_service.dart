import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/user_data.dart';
import 'package:health_care/providers/user_data_provider.dart';
import 'package:health_care/constants/error_handling.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class UserDataService {
  Future<void> fetchUserData(BuildContext context) async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    try {
      http.Response res = await http.get(
        Uri.parse(ipApiUrl),
      );
      
      if (context.mounted) {
        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
             userDataProvider.setUserData(UserData.fromJson(jsonEncode(jsonDecode(res.body))));
          },
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (context.mounted) {
        var snackBar = SnackBar(content: Text(errorMessage));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
