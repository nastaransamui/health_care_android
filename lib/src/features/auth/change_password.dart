import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/utils/validate_password.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  static const String rounteName = '/patient/dashboard/changePassword';
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final ScrollController scrollController = ScrollController();
  late final AuthProvider authProvider;
  final AuthService authService = AuthService();
  bool _isProvidersInitialized = false;
  var changePasswordFormKey = GlobalKey<FormBuilderState>();
  final ValueNotifier<bool> _oldPasswordObscureNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _newPasswordObscureNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _repeatPasswordObscureNotifier = ValueNotifier<bool>(true);

  void toggleObscureText(ValueNotifier<bool> notifier) {
    notifier.value = !notifier.value;
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    _oldPasswordObscureNotifier.dispose();
    _newPasswordObscureNotifier.dispose();
    _repeatPasswordObscureNotifier.dispose();
    super.dispose();
  }

  Future<void> onSubmitChangePassword() async {
    if (changePasswordFormKey.currentState?.saveAndValidate() ?? false) {
      final oldPassword = changePasswordFormKey.currentState?.fields['oldPassword']?.value;
      final newPassword = changePasswordFormKey.currentState?.fields['newPassword']?.value;
      final String roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
      String userId = "";
      if (roleName == 'doctors') {
        userId = authProvider.doctorsProfile!.userId;
      } else if (roleName == 'patient') {
        userId = authProvider.patientProfile!.userId;
      }
      var payload = {
        "user_Id": userId,
        "newPassword": newPassword,
        "oldPassword": oldPassword,
      };
      if (context.mounted) {
        showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          showDragHandle: false,
          useSafeArea: true,
          context: context,
          builder: (context) => const LoadingScreen(),
        );
      }
      socket.emit('passwordUpdate', payload);
      socket.once('passwordUpdateReturn', (msg) {
        if (!context.mounted) {
          log('Context not mounted after socket response. Cannot pop loading screen.');
          return;
        }
        // Navigator.pop(context);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            log('Context not mounted in post-frame callback. Cannot show status modal.');
            return;
          }

          if (msg['status'] != 200) {
            // Show error message
            Navigator.pop(context);
            showErrorSnackBar(context, msg['message'] ?? 'An unknown error occurred.');
          } else {
            Navigator.pop(context);
            SchedulerBinding.instance.addPostFrameCallback((_) {
              setState(() {
                changePasswordFormKey = GlobalKey<FormBuilderState>();
              });
            });
            showErrorSnackBar(context, msg['message']);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return ScaffoldWrapper(
      title: context.tr('changePasswrod'),
      children: SingleChildScrollView(
        controller: scrollController,
        child: FadeinWidget(
          isCenter: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: theme.primaryColorLight),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          context.tr("changePassword"),
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.primaryColorLight),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: FormBuilder(
                    key: changePasswordFormKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: [
                          // Old password
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Semantics(
                              label: context.tr('oldPassword'),
                              child: ValueListenableBuilder(
                                valueListenable: _oldPasswordObscureNotifier,
                                builder: (context, isObscure, child) {
                                  return FormBuilderTextField(
                                    name: 'oldPassword',
                                    enableSuggestions: false,
                                    obscureText: isObscure,
                                    validator: ((value) {
                                      if (value == null || value.isEmpty) {
                                        return context.tr('passwordEnter', args: [context.tr('oldPassword')]);
                                      } else {
                                        return validatePassword(context, value, context.tr('oldPassword'));
                                      }
                                    }),
                                    onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(color: Colors.redAccent.shade400),
                                      errorMaxLines: 2,
                                      floatingLabelStyle: TextStyle(color: theme.primaryColorLight),
                                      labelStyle: TextStyle(color: theme.primaryColorLight),
                                      // labelText: context.tr(key),
                                      label: Text(
                                        context.tr('oldPassword'),
                                        style: TextStyle(color: textColor),
                                      ),
                                      prefixIcon: Icon(Icons.password, color: theme.primaryColorLight),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isObscure ? Icons.visibility : Icons.visibility_off,
                                          color: textColor,
                                        ),
                                        onPressed: () => toggleObscureText(_oldPasswordObscureNotifier),
                                      ),
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
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).disabledColor, width: 1),
                                      ),
                                      fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
                                      filled: true,
                                      isDense: true,
                                      alignLabelWithHint: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // New password field
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Semantics(
                              label: context.tr('newPassword'),
                              child: ValueListenableBuilder(
                                valueListenable: _newPasswordObscureNotifier,
                                builder: (context, isObscure, child) {
                                  return FormBuilderTextField(
                                    name: 'newPassword',
                                    enableSuggestions: false,
                                    obscureText: isObscure,
                                    validator: (value) {
                                      final repeatValue = changePasswordFormKey.currentState?.fields['repeatPassword']?.value;
                                      if (value == null || value.isEmpty) {
                                        return context.tr('passwordEnter', args: [context.tr('newPassword')]);
                                      }

                                      final pwdValidation = validatePassword(context, value, context.tr('newPassword'));
                                      if (pwdValidation != null) return pwdValidation;

                                      if (repeatValue != null && repeatValue.isNotEmpty && value != repeatValue) {
                                        return context.tr('passwordNotSame');
                                      }

                                      return null;
                                    },
                                    onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(color: Colors.redAccent.shade400),
                                      errorMaxLines: 2,
                                      floatingLabelStyle: TextStyle(color: theme.primaryColorLight),
                                      labelStyle: TextStyle(color: theme.primaryColorLight),
                                      // labelText: context.tr(key),
                                      label: Text(
                                        context.tr('newPassword'),
                                        style: TextStyle(color: textColor),
                                      ),
                                      prefixIcon: Icon(Icons.password, color: theme.primaryColorLight),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isObscure ? Icons.visibility : Icons.visibility_off,
                                          color: textColor,
                                        ),
                                        onPressed: () => toggleObscureText(_newPasswordObscureNotifier),
                                      ),
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
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).disabledColor, width: 1),
                                      ),
                                      fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
                                      filled: true,
                                      isDense: true,
                                      alignLabelWithHint: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Repeat password field
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Semantics(
                              label: context.tr('repeatPassword'),
                              child: ValueListenableBuilder(
                                valueListenable: _repeatPasswordObscureNotifier,
                                builder: (context, isObscure, child) {
                                  return FormBuilderTextField(
                                    name: 'repeatPassword',
                                    enableSuggestions: false,
                                    obscureText: isObscure,
                                    validator: (value) {
                                      final newPasswordValue = changePasswordFormKey.currentState?.fields['newPassword']?.value;
                                      if (value == null || value.isEmpty) {
                                        return context.tr('passwordEnter', args: [context.tr('repeatPassword')]);
                                      }

                                      final pwdValidation = validatePassword(context, value, context.tr('repeatPassword'));
                                      if (pwdValidation != null) return pwdValidation;

                                      if (newPasswordValue != null && newPasswordValue.isNotEmpty && value != newPasswordValue) {
                                        return context.tr('passwordNotSame');
                                      }

                                      return null;
                                    },
                                    onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(color: Colors.redAccent.shade400),
                                      errorMaxLines: 2,
                                      floatingLabelStyle: TextStyle(color: theme.primaryColorLight),
                                      labelStyle: TextStyle(color: theme.primaryColorLight),
                                      // labelText: context.tr(key),
                                      label: Text(
                                        context.tr('repeatPassword'),
                                        style: TextStyle(color: textColor),
                                      ),
                                      prefixIcon: Icon(Icons.password, color: theme.primaryColorLight),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isObscure ? Icons.visibility : Icons.visibility_off,
                                          color: textColor,
                                        ),
                                        onPressed: () => toggleObscureText(_repeatPasswordObscureNotifier),
                                      ),
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
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).disabledColor, width: 1),
                                      ),
                                      fillColor: Theme.of(context).canvasColor.withAlpha((0.1 * 255).round()),
                                      filled: true,
                                      isDense: true,
                                      alignLabelWithHint: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Submit Button
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 16.0, bottom: 16.0, right: 16.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 45,
                              child: GradientButton(
                                onPressed: onSubmitChangePassword,
                                colors: [
                                  Theme.of(context).primaryColorLight,
                                  Theme.of(context).primaryColor,
                                ],
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(FontAwesomeIcons.eye, size: 13, color: textColor),
                                    const SizedBox(width: 5),
                                    Text(
                                      context.tr("submit"),
                                      style: TextStyle(fontSize: 12, color: textColor),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
