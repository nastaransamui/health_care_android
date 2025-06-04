import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/error_handling.dart';
import 'package:health_care/providers/device_provider.dart';
import 'package:health_care/providers/user_data_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/device_service.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/features/auth/auth_container.dart';
import 'package:health_care/src/features/auth/auth_header.dart';
import 'package:health_care/src/features/auth/email_field.dart';
import 'package:health_care/src/features/auth/password_field.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:toastify/toastify.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

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
  final _loginFormKey = GlobalKey<FormState>();
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
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).maybePop();
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
          });
        case 500:
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).maybePop();
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
          });
          break;
        case 410:
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).maybePop();
            showToast(
              context,
              Toast(
                id: '_toast',
                child: CustomInfoToast(
                  onConfirm: () {
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
                  confirmText: 'logoutOthers',
                  closeText: 'close',
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
          });
          break;
        default:
          var token = data['accessToken'];
          authService.loginService(context, token);

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
            if (_loginFormKey.currentState!.validate() &&
                email != '' &&
                password != '') {
              showModalBottomSheet(
                isDismissible: false,
                enableDrag: false,
                showDragHandle: false,
                useSafeArea: true,
                context: context,
                builder: (context) => const LoadingScreen(),
              );
              submitLogin(password, email, userData, deviceData, context);
            }

            return true;
          },
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const AuthHeader(),
                FadeinWidget(
                  isCenter: true,
                  child: AuthContainer(
                    formKey: _loginFormKey,
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
                          Text(context.tr('haveNotAccount')),
                          TextButton(
                              onPressed: () {
                                context.push('/signup');
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
  final formKey = GlobalKey<FormBuilderState>();
  var roleName = '';
  final AuthService authService = AuthService();
  double lifeTime = 2500;
  double duration = 200;

  _formSubmit() {
    SubmitNotification(
      widget.emailController.text.trim().toLowerCase(),
      widget.passwordController.text,
    ).dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    final userData = Provider.of<UserDataProvider>(context).userData;
    final deviceData = Provider.of<DeviceProvider>(context).deviceData;
    void onChanged(dynamic val) {
      setState(() {
        roleName = val.toString();
      });
    }

    const List<String> scopes = <String>[
      'email',
      'profile',
    ];

    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: scopes,
    );
    Future<void> googleLogin(String roleName) async {
      var formData = {"ipAddr": userData?.query, "userAgent": deviceData};
      googleSignIn.signIn().then((result) {
        result?.authentication.then((googleKey) async {
          final http.Response response = await http.get(
              Uri.parse("https://www.googleapis.com/oauth2/v3/userinfo"),
              headers: {
                'Accept': 'application/json',
                "Authorization": "Bearer ${googleKey.accessToken}"
              });
          if (response.statusCode != 200) {
            debugPrint('${response.statusCode} response: ${response.body}');
          } else {
            var info = jsonDecode(response.body);

            formData['email'] = info['email'];
            formData['firstName'] = info['given_name'];
            formData['lastName'] = info['family_name'];
            formData['profileImage'] = info['picture'];
            formData['userType'] = roleName.toLowerCase();
            formData['access_token'] = googleKey.accessToken;
            formData['token_type'] = 'Bearer';
            formData['authuser'] = "0";
            formData['expires_in'] = 3599;
            formData['prompt'] = "none";
            formData['scope'] =
                "email profile https://www.googleapis.com/auth/userinfo.profile openid https://www.googleapis.com/auth/userinfo.email";
            socket.emit('googleLoginSubmit', formData);
            socket.once('googleLoginReturn', (data) {
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
                        onConfirm: () {
                          socket.emit('logOutAllUsersSubmit', {
                            "email": formData['email'],
                            'services': 'google',
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
                        confirmText: 'logoutOthers',
                        closeText: 'close',
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
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    context.push('/');
                  });
                  break;
              }
            });
          }
        }).catchError((err) {
          debugPrint('inner error');
        });
      });
      //If you want further information about Google accounts, such as authentication, use this.
      // final GoogleSignInAuthentication googleAuthentication =
      //     await googleAccount!.authentication;
      // print(googleAccount);
    }

    void onGoogleButtonClicked() {
      Alert(
          closeFunction: () {
            setState(
              () {
                roleName = "";
              },
            );
            Navigator.of(
              context,
            ).pop();
          },
          style: AlertStyle(
            constraints:
                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            alertPadding: const EdgeInsets.only(left: 0, right: 0),
            animationType: AnimationType.fromTop,
            animationDuration: const Duration(milliseconds: 400),
            alertBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
            titleStyle: TextStyle(
              color:
                  brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            descStyle: TextStyle(
              color:
                  brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          context: context,
          closeIcon: Icon(
            Icons.close,
            color: Theme.of(context).primaryColorLight,
          ),
          buttons: [
            DialogButton(
              onPressed: () {
                if (roleName.isNotEmpty) {
                  googleLogin(roleName);
                  Navigator.pop(context);
                }
              },
              border: Border.fromBorderSide(
                BorderSide(
                    color: Theme.of(context).primaryColorLight,
                    width: 1,
                    style: BorderStyle.solid),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColorLight,
                ],
              ),
              child: Text(
                context.tr("loginGoogle"),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Text(context.tr('accountDetails')),
                Divider(
                  color: Theme.of(context).primaryColor,
                ),
                FormBuilder(
                  key: formKey,
                  onChanged: () {
                    formKey.currentState!.save();
                  },
                  autovalidateMode: AutovalidateMode.always,
                  skipDisabled: true,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      FormBuilderRadioGroup<String>(
                        activeColor: Theme.of(context).primaryColorLight,
                        focusColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          labelText: "${context.tr('userType')} *",
                          border: InputBorder.none,
                        ),
                        initialValue: null,
                        name: 'roleName',
                        onChanged: onChanged,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: context.tr('required'))
                        ]),
                        options: [
                          'doctors',
                          'patient',
                          // context.tr('pharmacist')
                        ]
                            .map((role) => FormBuilderFieldOption(
                                  value: role,
                                  child: Text(context.tr(role)),
                                ))
                            .toList(growable: true),
                        controlAffinity: ControlAffinity.leading,
                        orientation: OptionsOrientation.vertical,
                      ),
                    ],
                  ),
                )
              ],
            ),
          )).show();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmailField(emailController: widget.emailController),
        const SizedBox(height: 10),
        PasswordField(
          passwordController: widget.passwordController,
          fieldName: 'password',
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
          onPressed: () {
            onGoogleButtonClicked();
          },
        ),
      ],
    );
  }
}
