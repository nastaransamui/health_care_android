import 'package:flutter/scheduler.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/features/auth/auth_container.dart';
import 'package:health_care/src/features/auth/auth_header.dart';
import 'package:health_care/src/features/auth/email_field.dart';
import 'package:health_care/src/features/auth/signup_screen.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/stream_socket.dart';
import 'package:toastify/toastify.dart';

Future<void> func() async {}

class ForgotScreen extends StatefulWidget {
  final emailController = TextEditingController();
  ForgotScreen({
    super.key,
  });

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> removeLoading() async {
    await Future<void>.delayed(const Duration(seconds: 3), () {
      _formKey.currentState!.reset();
      Navigator.pop(context);
      FocusManager.instance.primaryFocus?.unfocus();
      widget.emailController.text = '';
    });
  }

  bool loading = false;
  double lifeTime = 10000;
  double duration = 200;
  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr('forgot'),
          ),
        ),
        body: NotificationListener<SubmitNotification>(
          onNotification: (notification) {
            final email = notification.emailValue;
            if (_formKey.currentState!.validate() && email != '') {
              showModalBottomSheet(
                isDismissible: false,
                enableDrag: false,
                showDragHandle: false,
                useSafeArea: true,
                context: context,
                builder: (context) => const LoadingScreen(),
              );
              socket.emit(
                  'forgetPassword', {"email": widget.emailController.text});
              socket.on('forgetPasswordReturn', (data) {
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
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).maybePop();
                    showToast(
                      context,
                      Toast(
                        id: '_toastSuccess',
                        title: 'Success',
                        description: data['message'],
                        duration: Duration(milliseconds: duration.toInt()),
                        lifeTime: Duration(
                          milliseconds: lifeTime.toInt(),
                        ),
                      ),
                    );
                  });
                }
              });

              // removeLoading();
            }

            return true;
          },
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const AuthHeader(),
                AuthContainer(
                  formKey: _formKey,
                  children: [
                    InputField(
                      emailController: widget.emailController,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.tr('haveAccount')),
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          child: Text(
                            context.tr('login'),
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.tr('haveNotAccount')),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SignupScreen()),
                                );
                              });
                            },
                            child: Text(
                              context.tr('signup'),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ))
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomBar(showLogin: false),
      ),
    );
  }
}

class SubmitNotification extends Notification {
  final String emailValue;

  SubmitNotification(
    this.emailValue,
  );
}

class InputField extends StatefulWidget {
  final TextEditingController emailController;

  const InputField({
    super.key,
    required this.emailController,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  _formSubmit() {
    SubmitNotification(widget.emailController.text.trim()).dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmailField(emailController: widget.emailController),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _formSubmit,
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
        const SizedBox(height: 10),
        SignInButton(
          brightness == Brightness.dark ? Buttons.GoogleDark : Buttons.Google,
          text: context.tr('googleLogin'),
          onPressed: () {},
        ),
      ],
    );
  }
}
