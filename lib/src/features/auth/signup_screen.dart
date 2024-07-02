import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:health_care/constants/error_handling.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/device_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_care/providers/device_provider.dart';
import 'package:health_care/providers/user_data_provider.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/features/auth/auth_container.dart';
import 'package:health_care/src/features/auth/auth_header.dart';
import 'package:health_care/src/features/auth/email_field.dart';
import 'package:health_care/src/features/auth/first_name_field.dart';
import 'package:health_care/src/features/auth/last_name_field.dart';
import 'package:health_care/src/features/auth/password_field.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toastify/toastify.dart';

Future<void> func() async {}

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final userTypeController = TextEditingController();
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

  void resetForm() {
    _formKey.currentState?.reset();
    firstNameController.text = "";
    lastNameController.text = "";
    mobileNumberController.text = "";
    emailController.text = "";
    passwordController.text = "";
    repeatPasswordController.text = "";
    userTypeController.text = "";
  }

  double lifeTime = 10000;
  double duration = 200;

  void onRegisterSubmit(Map<String, String> map) {
    socket.emit('registerFormSubmit', map);
    socket.once('registerFormReturn', (data) {
      if (data['status'] != 200) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).maybePop();
          showToast(
            context,
            Toast(
              id: '_toastFailed',
              title: 'Failed',
              description: data['reason'] ?? data['message'],
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
          resetForm();
          showToast(
            context,
            Toast(
              id: '_toastFailed',
              title: 'Failed',
              description: data['reason'] ?? data['message'],
              duration: Duration(milliseconds: duration.toInt()),
              lifeTime: Duration(
                milliseconds: lifeTime.toInt(),
              ),
            ),
          );
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    passwordController.addListener(passwordListener);
    repeatPasswordController.addListener(passwordListener);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    userTypeController.dispose();
    super.dispose();
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
            final firstNameValue = notification.firstNameValue;
            final lastNameValue = notification.lastNameValue;
            final mobileNumberValue = notification.mobileNumberValue;
            final emailValue = notification.emailValue;
            final passwordValue = notification.passwordValue;
            final repeatPasswordValue = notification.repeatPasswordValue;
            final userTypeValue = notification.userTypeValue;
            final dialCodeValue = notification.dialCodeValue;
            if (passwordValue != repeatPasswordValue) {
              setState(() {
                passwordNotSame = true;
              });
            } else {
              setState(() {
                passwordNotSame = false;
              });
              if (_formKey.currentState!.validate()) {
                showModalBottomSheet(
                  isDismissible: false,
                  enableDrag: false,
                  showDragHandle: false,
                  useSafeArea: true,
                  context: context,
                  builder: (context) => const LoadingScreen(),
                );
                onRegisterSubmit({
                  "firstName": firstNameValue,
                  'lastName': lastNameValue,
                  "mobileNumber": "$dialCodeValue$mobileNumberValue",
                  "email": emailValue,
                  "password": passwordValue,
                  "userType": userTypeValue
                });
              }
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
                      firstNameController: firstNameController,
                      lastNameController: lastNameController,
                      mobileNumberController: mobileNumberController,
                      emailController: emailController,
                      passwordController: passwordController,
                      repeatPasswordController: repeatPasswordController,
                      userTypeController: userTypeController,
                      passwordNotSame: passwordNotSame,
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
  final String firstNameValue;
  final String lastNameValue;
  final String mobileNumberValue;
  final String emailValue;
  final String passwordValue;
  final String repeatPasswordValue;
  final String userTypeValue;
  final String dialCodeValue;

  SubmitNotification(
    this.firstNameValue,
    this.lastNameValue,
    this.mobileNumberValue,
    this.emailValue,
    this.passwordValue,
    this.repeatPasswordValue,
    this.userTypeValue,
    this.dialCodeValue,
  );
}

class InputField extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController mobileNumberController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController repeatPasswordController;
  final TextEditingController userTypeController;
  final bool passwordNotSame;

  const InputField({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.mobileNumberController,
    required this.emailController,
    required this.passwordController,
    required this.repeatPasswordController,
    required this.userTypeController,
    required this.passwordNotSame,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  //For google
  final DeviceService deviceService = DeviceService();
  final AuthService authService = AuthService();
  var roleName = '';
  final formKey = GlobalKey<FormBuilderState>();

  double lifeTime = 2500;
  double duration = 200;

  bool _isObscureText = true;
  String dialCode = "";
  showPassword() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  _formSubmit() {
    SubmitNotification(
      widget.firstNameController.text,
      widget.lastNameController.text,
      widget.mobileNumberController.text,
      widget.emailController.text,
      widget.passwordController.text,
      widget.repeatPasswordController.text,
      widget.userTypeController.text,
      dialCode,
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
                        onLogout: () {
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: FormBuilderRadioGroup<String>(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            activeColor: Theme.of(context).primaryColorLight,
            focusColor: Theme.of(context).primaryColor,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                bottom: -10.0,
              ),
              labelText: "${context.tr('userType')} *",
              border: InputBorder.none,
              errorStyle: TextStyle(
                color: Colors.redAccent.shade400,
              ),
              errorMaxLines: 1,
            ),
            initialValue: null,
            name: 'roleName',
            restorationId: 'roleName',
            onChanged: (String? val) {
              widget.userTypeController.text = val.toString();
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return context.tr('required');
              }
              return null;
            },
            // validator: FormBuilderValidators.compose([
            //   FormBuilderValidators.required(errorText: context.tr('required'))
            // ]),
            options: [
              'doctors',
              'patient',
              // context.tr('pharmacist')
            ]
                .map((role) => FormBuilderFieldOption(
                      value: role,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text(context.tr(role)),
                          ),
                        ],
                      ),
                    ))
                .toList(growable: true),
            controlAffinity: ControlAffinity.leading,
            orientation: OptionsOrientation.horizontal,
          ),
        ),
        const SizedBox(height: 10),
        FirstNameField(firstNameController: widget.firstNameController),
        const SizedBox(height: 10),
        LastNameField(lastNameController: widget.lastNameController),
        const SizedBox(height: 10),
        EmailField(emailController: widget.emailController),
        const SizedBox(height: 10),
        InternationalPhoneNumberInput(
          errorMessage: context.tr('required'),
          validator: (userInput) {
            if (userInput!.isEmpty) {
              return context.tr('required');
            }
            if (!RegExp(r'^(\+|00)?[0-9]+$').hasMatch(userInput)) {
              return context
                  .tr('phoneValidate'); //'Please enter a valid phone number';
            }

            if (userInput.length < 7 || userInput.length > 12) {
              return context.tr('required');
            }

            return null; // Return null when the input is valid
          },
          onInputChanged: (PhoneNumber number) async {
            setState(() {
              dialCode = number.dialCode!;
            });
          },
          selectorConfig: const SelectorConfig(
            setSelectorButtonAsPrefixIcon: true,
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            useBottomSheetSafeArea: true,
            leadingPadding: 10,
            trailingSpace: false,
          ),

          ignoreBlank: false,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          selectorTextStyle: TextStyle(
            color: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          // initialValue: number,
          textFieldController: widget.mobileNumberController,
          formatInput: true,
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          inputDecoration: InputDecoration(
            focusedBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            errorStyle: TextStyle(color: Colors.redAccent.shade400),
            floatingLabelAlignment: FloatingLabelAlignment.start,
            labelText: context.tr('mobileNumber'),
            isCollapsed: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            isDense: true,
            // alignLabelWithHint: true,
          ),
          onSaved: (PhoneNumber number) {
            // print('On Saved: $number');
          },
        ),
        const SizedBox(height: 10),
        PasswordField(
          passwordController: widget.passwordController,
          fieldName: 'password',
        ),
        const SizedBox(height: 10),
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
          onPressed: () {
            onGoogleButtonClicked();
          },
        ),
      ],
    );
  }
}
