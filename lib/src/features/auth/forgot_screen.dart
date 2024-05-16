
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/features/auth/signup_screen.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/utils/validate_email.dart';

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
                  _header(context),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Card(
                      child: Stack(
                        fit: StackFit.loose,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              top: 20.0,
                            ),
                            child: SizedBox(
                              child: Form(
                                key: _formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: Column(
                                  children: [
                                    InputField(
                                      emailController:
                                          widget.emailController,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        context.tr('login'),
                                        style: TextStyle(
                                            color:Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(context.tr('haveAccount')),
                                        TextButton(
                                            onPressed: () {
                                              setState(() {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SignupScreen()
                                                  ),
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
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
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

_header(context) {
  return Container(
    margin: const EdgeInsets.only(
      top: 24.0,
    ),
    height: 200,
    decoration: const BoxDecoration(
      image: DecorationImage(
          image: AssetImage('assets/images/register-top-img.png')),
    ),
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
  bool _isObscureText = true;

  showPassword() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  _formSubmit() {
    SubmitNotification(widget.emailController.text.trim()).dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: context.tr('email'),
          child: TextFormField(
            controller: widget.emailController,
            enableSuggestions: true,
            validator: ((value) {
              if (value == null || value.isEmpty) {
                return context.tr('emailEnter');
              } else {
                return validateEmail(value);
              }
            }),
            decoration: InputDecoration(
              errorStyle: TextStyle(color: Colors.redAccent.shade400),
              hintText: context.tr('email'),
              labelText: context.tr('email'),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.email_sharp),
              isDense: true,
            ),
          ),
        ),
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
