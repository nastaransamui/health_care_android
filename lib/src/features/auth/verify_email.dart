import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/providers/device_provider.dart';
import 'package:health_care/providers/user_data_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/device_service.dart';
import 'package:health_care/services/user_data_service.dart';
import 'package:health_care/src/features/auth/auth_container.dart';
import 'package:health_care/src/features/auth/password_field.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/stream_socket.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'package:health_care/providers/user_from_token_provider.dart';
import 'package:health_care/services/user_from_token_service.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/features/auth/auth_header.dart';
import 'package:toastify/toastify.dart';

class VerifyEmail extends StatefulWidget {
  final Map<String, String> pathParameters;
  const VerifyEmail({
    super.key,
    required this.pathParameters,
  });

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  final _verifyEmailFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final UserFromTokenService userFromTokenService = UserFromTokenService();
  final UserDataService userDataService = UserDataService();
  final DeviceService deviceService = DeviceService();
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    userDataService.fetchUserData(context);
    userFromTokenService.fetchUserFromVerifyToken(context, widget.pathParameters['token']!);
  }

  double lifeTime = 10000;
  double duration = 200;
  bool showPassword = false;
  bool applyPassword = false;
  var height = 220.0;
  double topPadding = 8;

  void verificationClicked(Map<String, dynamic> map) async {
    socket.emit(
      'verificationEmail',
      {
        map['user'],
        map['token'],
        map['ipAddr'],
        map['userAgent'],
        map['password'],
        map['fcmToken'],
      },
    );
    socket.once('verificationEmailReturn', (data) {
      if (data['status'] != 200) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).maybePop();
          showToast(
            context,
            Toast(
              id: '_toastFailed',
              title: 'Failed',
              description: data['reason'],
              duration: Duration(milliseconds: duration.toInt()),
              lifeTime: Duration(
                milliseconds: lifeTime.toInt(),
              ),
            ),
          );
        });
      } else {
        if (data['reason'] != null) {
          showToast(
            context,
            Toast(
              id: '_toastFailed',
              title: 'Failed',
              description: data['reason'],
              duration: Duration(milliseconds: duration.toInt()),
              lifeTime: Duration(
                milliseconds: lifeTime.toInt(),
              ),
            ),
          );
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).maybePop();
            context.go('/login');
          });
        }

        if (data['accessToken'] != null) {
          var token = data['accessToken'];
          authService.loginService(context, token);
        }
      }
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userFromToken = Provider.of<UserFromTokenProvider>(context).userFromToken;
    final userData = Provider.of<UserDataProvider>(context).userData;
    final deviceData = Provider.of<DeviceProvider>(context).deviceData;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(context.tr('verifyEmail')),
        ),
        bottomNavigationBar: const BottomBar(
          showLogin: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Center(child: AuthHeader()),
              if (userFromToken == null)
                SizedBox(
                  width: 50,
                  height: 10,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballPulse,
                    colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
                    strokeWidth: 1,
                    backgroundColor: Theme.of(context).canvasColor,
                    pathBackgroundColor: Theme.of(context).canvasColor,
                  ),
                )
              else if (userFromToken.userId.isEmpty) ...[
                AuthContainer(formKey: _verifyEmailFormKey, children: [
                  ListTile(
                    title: Text(
                      userFromToken.reason!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => context.go('/'),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(double.maxFinite, 30),
                        backgroundColor: Theme.of(context).primaryColorLight,
                        elevation: 5.0,
                      ),
                      child: Text(
                        context.tr('home'),
                      ),
                    ),
                  )
                ])
              ] else ...[
                AnimatedContainer(
                  height: height,
                  curve: Curves.easeInOut,
                  duration: const Duration(seconds: 1),
                  child: SizedBox(
                    child: AuthContainer(formKey: _verifyEmailFormKey, children: [
                      Center(
                        child: Text('${userFromToken.roleName == "doctors" ? "Dr." : ""}${userFromToken.firstName} ${userFromToken.lastName}'),
                      ),
                      Text(userFromToken.userName),
                      Text(context.tr('verifyText')),
                      ListTileTheme(
                        horizontalTitleGap: 0.0,
                        child: CheckboxListTile(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          contentPadding: const EdgeInsets.only(left: 30),
                          title: Text(context.tr('directLoginLabel')),
                          checkboxSemanticLabel: context.tr('directLoginLabel'),
                          controlAffinity: ListTileControlAffinity.leading,
                          tristate: true,
                          activeColor: Theme.of(context).primaryColor,
                          value: applyPassword,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                applyPassword = value;
                                height = 310;
                                topPadding = 10.0;
                              });
                            } else {
                              setState(() {
                                applyPassword = false;
                                height = 220;
                                topPadding = 8.0;
                              });
                            }
                          },
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: SizedBox(
                          height: 80,
                          child: InputFields(
                            passwordController: passwordController,
                          ),
                        ),
                        secondChild: const SizedBox(
                          height: 0,
                        ),
                        crossFadeState: height == 310 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        duration: Duration(seconds: height == 220 ? 1 : 2),
                      ),
                      AnimatedPadding(
                        duration: Duration(seconds: height == 220 ? 1 : 2),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.only(left: 8.0, top: topPadding, right: 8.0, bottom: 8),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (applyPassword) {
                              if (_verifyEmailFormKey.currentState!.validate()) {
                                showModalBottomSheet(
                                  isDismissible: false,
                                  enableDrag: false,
                                  showDragHandle: false,
                                  useSafeArea: true,
                                  context: context,
                                  builder: (context) => const LoadingScreen(),
                                );
                                final fcmToken = await FirebaseMessaging.instance.getToken();
                                verificationClicked({
                                  "user": {
                                    "_id": userFromToken.userId,
                                    "emails": [
                                      {"address": userFromToken.userName}
                                    ]
                                  },
                                  "token": widget.pathParameters['token']!,
                                  "ipAddr": userData?.query,
                                  "userAgent": deviceData,
                                  "password": passwordController.text,
                                  "fcmToken": fcmToken,
                                });
                              }
                            } else {
                              showModalBottomSheet(
                                isDismissible: false,
                                enableDrag: false,
                                showDragHandle: false,
                                useSafeArea: true,
                                context: context,
                                builder: (context) => const LoadingScreen(),
                              );
                              verificationClicked({
                                "user": {
                                  "_id": userFromToken.userId,
                                  "emails": [
                                    {"address": userFromToken.userName}
                                  ]
                                },
                                "token": widget.pathParameters['token']!,
                                "ipAddr": userData?.query,
                                "userAgent": deviceData,
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(double.maxFinite, 30),
                            backgroundColor: Theme.of(context).primaryColorLight,
                            elevation: 5.0,
                          ),
                          child: Text(
                            context.tr('verification'),
                          ),
                        ),
                      )
                    ]),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class SubmitNotification extends Notification {
  final String passwordValue;

  SubmitNotification(this.passwordValue);
}

class InputFields extends StatefulWidget {
  final TextEditingController passwordController;
  const InputFields({
    super.key,
    required this.passwordController,
  });

  @override
  State<InputFields> createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: PasswordField(
        passwordController: widget.passwordController,
        fieldName: 'password',
      ),
    );
  }
}
