import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/providers/user_from_token_provider.dart';
import 'package:health_care/services/user_from_token_service.dart';

import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/features/auth/auth_container.dart';
import 'package:health_care/src/features/auth/auth_header.dart';
import 'package:health_care/src/features/auth/password_field.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/stream_socket.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toastify/toastify.dart';

class ResetPassword extends StatefulWidget {
  final Map<String, String> pathParameters;
  const ResetPassword({
    super.key,
    required this.pathParameters,
  });

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _resetPasswordFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final UserFromTokenService userFromTokenService = UserFromTokenService();
  bool passwordNotSame = false;

  void passwordListener() {
    if (passwordController.text != repeatPasswordController.text) {
      setState(() {
        passwordNotSame = true;
      });
    } else {
      setState(() {
        passwordNotSame = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    passwordController.addListener(passwordListener);
    repeatPasswordController.addListener(passwordListener);
    userFromTokenService.fetchUserFromToken(
        context, widget.pathParameters['token']!);
  }

  double lifeTime = 10000;
  double duration = 200;
  void resetPasswordClicked(Map<String, String> map) {
    socket.emit('resetPasswordUpdate', map);
    socket.once('resetPasswordUpdateReturn', (data) {
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
      //  Navigator.of(context).maybePop();
        SchedulerBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userFromToken =
        Provider.of<UserFromTokenProvider>(context).userFromToken;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            context.tr('resetPassword'),
          ),
        ),
        bottomNavigationBar: const BottomBar(
          showLogin: true,
        ),
        body: NotificationListener<SubmitNotification>(
          onNotification: (notification) {
            final passwordValue = notification.passwordValue;
            final repeatPasswordValue = notification.repeatPasswordValue;

            if (passwordValue != repeatPasswordValue) {
              setState(() {
                passwordNotSame = true;
              });
            } else {
              setState(() {
                passwordNotSame = false;
              });

            if (_resetPasswordFormKey.currentState!.validate() ) {
              showModalBottomSheet(
                isDismissible: false,
                enableDrag: false,
                showDragHandle: false,
                useSafeArea: true,
                context: context,
                builder: (context) => const LoadingScreen(),
              );
              resetPasswordClicked({
                "password": passwordValue,
                "user_Id": userFromToken!.userId,
                "token": widget.pathParameters['token']!
              });
              log('here we call with $passwordValue & $repeatPasswordValue');
            }
            }
            return true;
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                const AuthHeader(),
                userFromToken == null
                    ? SizedBox(
                        width: 50,
                        height: 10,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballPulse,
                          colors: [
                            Theme.of(context).primaryColorLight,
                            Theme.of(context).primaryColor
                          ],
                          strokeWidth: 1,
                          backgroundColor: Theme.of(context).canvasColor,
                          pathBackgroundColor: Theme.of(context).canvasColor,
                        ),
                      )
                    : Text(
                        '${userFromToken.roleName == "doctors" ? "Dr." : ""}${userFromToken.firstName} ${userFromToken.lastName}'),
                InputFields(
                  passwordController: passwordController,
                  repeatPasswordController: repeatPasswordController,
                  resetPasswordFormKey: _resetPasswordFormKey,
                  passwordNotSame: passwordNotSame,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubmitNotification extends Notification {
  final String passwordValue;
  final String repeatPasswordValue;

  SubmitNotification(this.passwordValue, this.repeatPasswordValue);
}

class InputFields extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController repeatPasswordController;
  final GlobalKey resetPasswordFormKey;
  final bool passwordNotSame;
  const InputFields({
    super.key,
    required this.passwordController,
    required this.repeatPasswordController,
    required this.resetPasswordFormKey,
    required this.passwordNotSame,
  });

  @override
  State<InputFields> createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {
  _resetSubmit() {
    log('resetSubmit: ${widget.passwordController.text}, ${widget.repeatPasswordController.text}');
    SubmitNotification(widget.passwordController.text,
            widget.repeatPasswordController.text)
        .dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AuthContainer(
          formKey: widget.resetPasswordFormKey,
          children: [
            PasswordField(
              passwordController: widget.passwordController,
              fieldName: 'password',
            ),
            const SizedBox(height: 30),
            PasswordField(
              passwordController: widget.repeatPasswordController,
              fieldName: 'repeatPassword',
            ),
            const SizedBox(height: 10),
            if (widget.passwordNotSame) ...[
              Text(
                context.tr('passwordNotSame'),
                style: TextStyle(
                  color: Colors.redAccent.shade400,
                ),
              )
            ],
            ElevatedButton(
              onPressed: _resetSubmit,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(double.maxFinite, 30),
                backgroundColor: Theme.of(context).primaryColorLight,
                elevation: 5.0,
              ),
              child: Text(
                context.tr('resetPassword'),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
