
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/error_handling.dart';
import 'package:health_care/models/user_from_token.dart';
import 'package:health_care/providers/user_from_token_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class UserFromTokenService {
  Future<void> fetchUserFromToken(BuildContext context, String token) async {
    final userFromTokenProvider =
        Provider.of<UserFromTokenProvider>(context, listen: false);
    String url = '${dotenv.env['adminUrl']!}/methods/findUserByResetToken';

    try {
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({'token': token}),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          });
      if (context.mounted) {
        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            Map<String, dynamic> response = jsonDecode(res.body);
            if (response['reason'] == null) {
              var profile = response['profile'];
              var roleName = profile['roleName'];
              var userId = response['_id'];
              var firstName = profile['firstName'];
              var lastName = profile['lastName'];
              var userName = profile['userName'];

              userFromTokenProvider.setUserFromToken(
                UserFromToken.fromJson(
                  jsonEncode(
                    {
                      "roleName": roleName,
                      "userId": userId,
                      "firstName": firstName,
                      "lastName": lastName,
                      "userName": userName,
                    },
                  ),
                ),
              );
            } else {
              var snackBar = SnackBar(content: Text(response['reason']));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              SchedulerBinding.instance.addPostFrameCallback((_) {
                context.go('/forgot');
              });
            }
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

  Future<void> fetchUserFromVerifyToken(
      BuildContext context, String token) async {
    final userFromTokenProvider =
        Provider.of<UserFromTokenProvider>(context, listen: false);
    String url = '${dotenv.env['adminUrl']!}/methods/findUserByToken';

    try {
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({'token': token}),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          });
      if (context.mounted) {
        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            Map<String, dynamic> response = jsonDecode(res.body);
            if (response['reason'] == null) {
              var profile = response['profile'];
              var roleName = profile['roleName'];
              var userId = response['_id'];
              var firstName = profile['firstName'];
              var lastName = profile['lastName'];
              var userName = profile['userName'];

              userFromTokenProvider.setUserFromToken(
                UserFromToken.fromJson(
                  jsonEncode(
                    {
                      "roleName": roleName,
                      "userId": userId,
                      "firstName": firstName,
                      "lastName": lastName,
                      "userName": userName
                    },
                  ),
                ),
              );
            } else {
                userFromTokenProvider.setUserFromToken(UserFromToken.fromJson(
                  jsonEncode(
                    {
                      "roleName": null,
                      "userId": null,
                      "firstName": null,
                      "lastName": null,
                      "reason": response['reason'],
                    },
                  ),
                ));
              // });
            }
          },
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      log(errorMessage);
      if (context.mounted) {
        var snackBar = SnackBar(content: Text(errorMessage));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
