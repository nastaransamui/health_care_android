import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_care/constants/error_handling.dart';
import 'package:health_care/models/user_data.dart';
import 'package:health_care/providers/device_provider.dart';
import 'package:health_care/providers/user_data_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/device_service.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/features/auth/auth_header.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/utils/validate_email.dart';
import 'package:health_care/src/utils/validate_password.dart';
import 'package:health_care/stream_socket.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toastify/toastify.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  var _signupFormKey = GlobalKey<FormBuilderState>();
  bool passwordNotSame = false;
  late UserData userData;
  bool _initialized = false;
  late Map<String, dynamic> deviceData;
  //For google
  final DeviceService deviceService = DeviceService();
  final AuthService authService = AuthService();
  var roleName = '';
  final formKey = GlobalKey<FormBuilderState>();
  void onChanged(dynamic val) {
    setState(() {
      roleName = val.toString();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      userData = Provider.of<UserDataProvider>(context, listen: false).userData!;
      deviceData = Provider.of<DeviceProvider>(context, listen: false).deviceData;
      _initialized = true;
    }
  }

  double lifeTime = 10000;
  double duration = 200;
  String dialCode = "";

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
          FocusScope.of(context).unfocus();
          // --- Crucial part to clear errors and reset form ---
          // Assign a new GlobalKey to the FormBuilder to completely reset its state
          setState(() {
            _signupFormKey = GlobalKey<FormBuilderState>();
            dialCode = '';
            passwordNotSame = false;
          });
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
      }
    });
  }

  void _formSubmit() {
    final isValid = _signupFormKey.currentState?.saveAndValidate() ?? false;

    if (!isValid) {
      // Errors will automatically be shown next to each field including RadioGroup
      return;
    }

    final formData = _signupFormKey.currentState!.value;

    if (_signupFormKey.currentState!.validate()) {
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: true,
        context: context,
        builder: (context) => const LoadingScreen(),
      );
      onRegisterSubmit({
        "firstName": formData['firstName'],
        'lastName': formData['lastName'],
        "mobileNumber": formData['mobileNumber'],
        "email": formData['email'],
        "password": formData['password'],
        "userType": formData['roleName']
      });
    }
  }

  static const List<String> scopes = <String>[
    'email',
    'profile',
  ];

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: scopes,
  );
  Future<void> googleLogin(String roleName) async {
    var formData = {"ipAddr": userData.query, "userAgent": deviceData};
    googleSignIn.signIn().then((result) {
      result?.authentication.then((googleKey) async {
        final http.Response response = await http.get(Uri.parse("https://www.googleapis.com/oauth2/v3/userinfo"),
            headers: {'Accept': 'application/json', "Authorization": "Bearer ${googleKey.accessToken}"});
        if (response.statusCode != 200) {
          debugPrint('${response.statusCode} response: ${response.body}');
        } else {
          var info = jsonDecode(response.body);

          formData['email'] = info['email'];
          formData['firstName'] = info['given_name'];
          formData['lastName'] = info['family_name'];
          formData['profileImage'] = info['picture'];
          formData['userType'] = roleName.toLowerCase();
          formData['access_token'] = googleKey.accessToken!;
          formData['token_type'] = 'Bearer';
          formData['authuser'] = "0";
          formData['expires_in'] = 3599;
          formData['prompt'] = "none";
          formData['scope'] = "email profile https://www.googleapis.com/auth/userinfo.profile openid https://www.googleapis.com/auth/userinfo.email";
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
                      description: '${data['reason'].replaceAll(RegExp(r"\n"), " ").replaceAll('   ', '')}',
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
    var brightness = Theme.of(context).brightness;
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
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
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
            color: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          descStyle: TextStyle(
            color: brightness == Brightness.dark ? Colors.white : Colors.black,
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
              BorderSide(color: Theme.of(context).primaryColorLight, width: 1, style: BorderStyle.solid),
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
                      validator: FormBuilderValidators.compose([FormBuilderValidators.required(errorText: context.tr('required'))]),
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

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('signup')),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Center(child: AuthHeader()),
              FadeinWidget(
                isCenter: true,
                child: FormBuilder(
                  key: _signupFormKey,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
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
                                child: Column(
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
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return context.tr('required');
                                      }
                                      return null;
                                    },
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
                                const FirstNameInput(),
                                const SizedBox(height: 10),
                                const LastNameInput(),
                                const SizedBox(height: 10),
                                const EmailInput(),
                                const SizedBox(height: 10),
                                FormBuilderPhoneNumber(
                                  name: 'mobileNumber',
                                  onDialCodeChanged: (code) {
                                    dialCode = code; // or setState
                                  },
                                ),
                                const SizedBox(height: 10),
                                const PasswordInput(),
                                const SizedBox(height: 10),
                                RepeatPasswordInput(formKey: _signupFormKey),
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
                                  onPressed: () {
                                    onGoogleButtonClicked();
                                  },
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
                                        style: TextStyle(color: Theme.of(context).primaryColor),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: const BottomBar(showLogin: false),
      ),
    );
  }
}

class FirstNameInput extends StatelessWidget {
  const FirstNameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('firstName'),
      child: FormBuilderTextField(
        name: 'firstName',
        keyboardType: TextInputType.name,
        enableSuggestions: true,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return context.tr('firstNameEnter');
          }
          if (value.length < 2) {
            return context.tr('minFirstName');
          }
          return null;
        },
        decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.redAccent.shade400),
          labelText: context.tr('firstName'),
          hintText: context.tr('firstName'),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
          filled: true,
          prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
          isDense: true,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}

class LastNameInput extends StatelessWidget {
  const LastNameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('lastName'),
      child: FormBuilderTextField(
        name: 'lastName',
        keyboardType: TextInputType.name,
        enableSuggestions: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return context.tr('lastNameEnter');
          }
          if (value.length < 2) {
            return context.tr('minLastName');
          }
          return null;
        },
        decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.redAccent.shade400),
          labelText: context.tr('lastName'),
          hintText: context.tr('lastName'),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
          filled: true,
          prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
          isDense: true,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  const EmailInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('email'),
      child: FormBuilderTextField(
        name: 'email',
        keyboardType: TextInputType.emailAddress,
        enableSuggestions: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return context.tr('emailEnter');
          } else {
            return validateEmail(value);
          }
        },
        decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.redAccent.shade400),
          labelText: context.tr('email'),
          hintText: context.tr('email'),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
          filled: true,
          prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
          isDense: true,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}

class FormBuilderPhoneNumber extends StatelessWidget {
  final String name;
  final String? initialValue;
  final Function(String)? onDialCodeChanged;

  const FormBuilderPhoneNumber({
    super.key,
    required this.name,
    this.initialValue,
    this.onDialCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return FormBuilderField<String>(
      name: name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.tr('required');
        }
        if (!RegExp(r'^(\+|00)?[0-9]+$').hasMatch(value)) {
          return context.tr('phoneValidate');
        }
        if (value.length < 7 || value.length > 12) {
          return context.tr('required');
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InternationalPhoneNumberInput(
              errorMessage: context.tr('required'),
              initialValue: PhoneNumber(isoCode: 'TH'),
              onInputChanged: (PhoneNumber number) {
                field.didChange(number.phoneNumber); // this updates form state
                if (onDialCodeChanged != null) {
                  onDialCodeChanged!(number.dialCode ?? '');
                }
              },
              selectorConfig: const SelectorConfig(
                setSelectorButtonAsPrefixIcon: true,
                selectorType: PhoneInputSelectorType.DIALOG,
                useBottomSheetSafeArea: true,
                leadingPadding: 10,
                trailingSpace: false,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              selectorTextStyle: TextStyle(
                color: brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
              formatInput: false,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              inputDecoration: InputDecoration(
                labelText: context.tr('mobileNumber'),
                hintText: context.tr('mobileNumber'),
                errorText: field.errorText,
                errorStyle: TextStyle(color: Colors.redAccent.shade400),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                ),
                fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
                filled: true,
                prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
                isDense: true,
                alignLabelWithHint: true,
                floatingLabelAlignment: FloatingLabelAlignment.start,
                isCollapsed: true,
              ),
            ),
          ],
        );
      },
    );
  }
}

class PasswordInput extends StatefulWidget {
  const PasswordInput({super.key});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _isObscureText = true;
  void showPassword() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('password'),
      child: FormBuilderTextField(
        name: 'password',
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        obscureText: _isObscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return context.tr('passwordEnter', args: [context.tr('password')]);
          }
          return validatePassword(context, value, context.tr('password'));
        },
        decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.redAccent.shade400),
          labelText: context.tr('password'),
          hintText: context.tr('password'),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
          filled: true,
          prefixIcon: Icon(Icons.password, color: Theme.of(context).primaryColorLight),
          suffixIcon: IconButton(
            onPressed: showPassword,
            icon: Icon(
              _isObscureText ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).primaryColor,
            ),
          ),
          isDense: true,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}

class RepeatPasswordInput extends StatefulWidget {
  final GlobalKey<FormBuilderState> formKey;

  const RepeatPasswordInput({
    super.key,
    required this.formKey,
  });

  @override
  State<RepeatPasswordInput> createState() => _RepeatPasswordInputState();
}

class _RepeatPasswordInputState extends State<RepeatPasswordInput> {
  bool _isObscureText = true;
  void showPassword() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('repeatPassword'),
      child: FormBuilderTextField(
        name: 'repeatPassword',
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        obscureText: _isObscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          final password = widget.formKey.currentState?.fields['password']?.value;
          if (value == null || value.isEmpty) {
            return context.tr('repeatPassword');
          }
          if (value != password) {
            return context.tr('passwordNotSame');
          }
          return null;
        },
        decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.redAccent.shade400),
          labelText: context.tr('repeatPassword'),
          hintText: context.tr('repeatPassword'),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
          ),
          fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
          filled: true,
          prefixIcon: Icon(Icons.password, color: Theme.of(context).primaryColorLight),
          suffixIcon: IconButton(
            onPressed: showPassword,
            icon: Icon(
              _isObscureText ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).primaryColor,
            ),
          ),
          isDense: true,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
