import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/features/auth/auth_container.dart';
import 'package:health_care/src/features/auth/auth_header.dart';
import 'package:health_care/src/features/auth/email_field.dart';
import 'package:health_care/src/features/auth/password_field.dart';
import 'package:health_care/src/features/loading_screen.dart';

Future<void> func() async {}

class SignupScreen extends StatefulWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  SignupScreen({
    super.key,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> removeLoading() async {
    await Future<void>.delayed(const Duration(seconds: 3), () {
      _formKey.currentState!.reset();
      Navigator.pop(context);
      FocusManager.instance.primaryFocus?.unfocus();
      widget.emailController.text = '';
      widget.passwordController.text = '';
    });
  }

  bool loading = false;
  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('signup')),
        ),
        body: NotificationListener<SubmitNotification>(
          onNotification: (notification) {
            final email = notification.emailValue;
            final password = notification.passwordValue;
            if (_formKey.currentState!.validate() &&
                email != '' &&
                password != '') {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => const LoadingScreen(),
              );
              removeLoading();
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
                      passwordController: widget.passwordController,
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/forgot');
                      },
                      child: Text(
                        context.tr('forgotPasswordLink'),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
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
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        )
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
  final String passwordValue;

  SubmitNotification(this.emailValue, this.passwordValue);
}

class InputField extends StatefulWidget {
  final TextEditingController passwordController;

  final TextEditingController emailController;

  const InputField({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _isObscureText = true;

  showPassword() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  _formSubmit() {
    SubmitNotification(
            widget.emailController.text, widget.passwordController.text)
        .dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmailField(emailController: widget.emailController),
        const SizedBox(height: 10),
        PasswordField(passwordController: widget.passwordController),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _formSubmit,
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(double.maxFinite, 30),
            backgroundColor: Theme.of(context).primaryColorLight,
            elevation: 5.0,
          ),
          child: Text(
            context.tr('signup'),
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
