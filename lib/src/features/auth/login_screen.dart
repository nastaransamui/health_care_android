import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:health_care/constants/error_handling.dart';
import 'package:health_care/providers/device_provider.dart';
import 'package:health_care/providers/user_data_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/device_service.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/features/auth/forgot_screen.dart';
import 'package:health_care/src/features/auth/signup_screen.dart';
import 'package:health_care/src/utils/validate_email.dart';
import 'package:health_care/src/utils/validate_password.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:toastify/toastify.dart';

Future<void> func() async {}

class LoginScreen extends StatefulWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final DeviceService deviceService = DeviceService();
  final AuthService authService = AuthService();

  double lifeTime = 2500;
  double duration = 200;
  @override
  void initState() {
    super.initState();
    deviceService.getDeviceService(context);
  }

  Future<void> submitLogin(
    String password,
    String email,
    userData,
    deviceData,
    context,
  ) async {
    var formData = {
      "password": password,
      "email": email,
      "ipAddr": userData?.query,
      "userAgent": deviceData
    };
    FocusManager.instance.primaryFocus?.unfocus();
    socket.emit('loginFormSubmit', formData);
    socket.once('loginFormReturn', (data) {
      switch (data['status']) {
        case 400:
        case 403:
          showToast(
            context,
            Toast(
              title: 'Failed',
              description: data['reason'],
              duration: Duration(milliseconds: duration.toInt()),
              lifeTime: Duration(
                milliseconds: lifeTime.toInt(),
              ),
            ),
          );
        case 500:
          showToast(
            context,
            Toast(
              title: 'Failed',
              description: data['reason'],
              duration: Duration(milliseconds: duration.toInt()),
              lifeTime: Duration(
                milliseconds: lifeTime.toInt(),
              ),
            ),
          );
          break;
        case 410:
          showToast(
            context,
            Toast(
              id: '_toast',
              child: CustomInfoToast(
                onLogout: () {
                  socket.emit('logOutAllUsersSubmit', {
                    "email": formData['email'],
                    'services': 'password',
                    "password": formData['password']
                  });
                  socket.once('logOutAllUsersReturn', (msg) {
                    Navigator.pop(context);
                    if (msg['status'] != 200) {
                      showToast(
                        context,
                        Toast(
                          title: 'Failed',
                          description: msg['reason']!,
                          duration: Duration(milliseconds: 200.toInt()),
                          lifeTime: Duration(
                            milliseconds: 2500.toInt(),
                          ),
                        ),
                      );
                    } else {
                      showToast(
                        context,
                        Toast(
                          title: 'Succeded',
                          description: msg['message']!,
                          duration: Duration(milliseconds: 200.toInt()),
                          lifeTime: Duration(
                            milliseconds: 2500.toInt(),
                          ),
                        ),
                      );
                    }
                  });
                },
                title: '',
                description:
                    '${data['reason'].replaceAll(RegExp(r"\n"), " ").replaceAll('   ', '')}',
              ),
              transitionBuilder: (animation, child, isRemoving) {
                if (isRemoving) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: child,
                  );
                }
                return SlideTransition(
                  position: animation.drive(
                    Tween(
                      begin: const Offset(1, 0),
                      end: const Offset(0, 0),
                    ),
                  ),
                  child: child,
                );
              },
            ),
            width: MediaQuery.of(context).size.width - 10,
          );
          break;
        default:
          var token = data['accessToken'];
          authService.loginService(context, token);
          Navigator.pushNamed(context, '/');

          break;
      }
    });
  }

  bool loading = false;
  @override
  Widget build(
    BuildContext context,
  ) {
    final userData = Provider.of<UserDataProvider>(context).userData;
    final deviceData = Provider.of<DeviceProvider>(context).deviceData;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('login')),
        ),
        body: NotificationListener<SubmitNotification>(
          onNotification: (notification) {
            final email = notification.emailValue;
            final password = notification.passwordValue;
            if (_formKey.currentState!.validate() &&
                email != '' &&
                password != '') {
              submitLogin(password, email, userData, deviceData, context);
            }

            return true;
          },
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _header(context),
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
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
                                    emailController: widget.emailController,
                                    passwordController:
                                        widget.passwordController,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ForgotScreen()),
                                        );
                                      });
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
                                            setState(() {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SignupScreen()),
                                              );
                                            });
                                          },
                                          child: Text(
                                            context.tr('signup'),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
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
  final String passwordValue;

  SubmitNotification(this.emailValue, this.passwordValue);
}

_header(context) {
  return Container(
    margin: const EdgeInsets.only(
      top: 8.0,
    ),
    height: 180,
    decoration: const BoxDecoration(
      image: DecorationImage(
          image: AssetImage('assets/images/register-top-img.png')),
    ),
  );
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
            widget.emailController.text.trim(), widget.passwordController.text)
        .dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
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
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.passwordController,
          enableSuggestions: true,
          validator: ((value) {
            if (value == null || value.isEmpty) {
              return context.tr('passwordEnter');
            } else {
              return validatePassword(value);
            }
          }),
          decoration: InputDecoration(
            errorMaxLines: 3,
            errorStyle: TextStyle(
              color: Colors.redAccent.shade400,
            ),
            hintText: context.tr('password'),
            labelText: context.tr('password'),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
            suffixIcon: IconButton(
              onPressed: showPassword,
              icon: Icon(
                _isObscureText ? Icons.visibility_off : Icons.visibility,
              ),
            ),
            isDense: true,
          ),
          obscureText: _isObscureText,
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
            context.tr('login'),
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
