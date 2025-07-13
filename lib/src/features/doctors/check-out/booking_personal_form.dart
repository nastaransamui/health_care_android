
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/src/features/doctors/check-out/checkout_text_field.dart';
import 'package:health_care/src/features/doctors/profile/reviews/review_button_sheet.dart';
import 'package:health_care/src/utils/validate_email.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class BookingPersonalForm extends StatefulWidget {
  final PatientUserProfile patientUserProfile;
  final VoidCallback onSubmit;
  final GlobalKey<FormBuilderState> formKey;
  final Widget submitButtonText;
  const BookingPersonalForm({
    super.key,
    required this.patientUserProfile,
    required this.onSubmit,
    required this.formKey,
    required this.submitButtonText,
  });

  @override
  State<BookingPersonalForm> createState() => _BookingPersonalFormState();
}

class _BookingPersonalFormState extends State<BookingPersonalForm> {
  final TextEditingController mobileNumberController = TextEditingController();
  String dialCode = "";
  PhoneNumber number = PhoneNumber(
    isoCode: '',
  );
  @override
  void initState() {
    super.initState();
    _initializePhoneNumber();
  }

  Future<void> _initializePhoneNumber() async {
    if (widget.patientUserProfile.mobileNumber.isNotEmpty) {
      try {
        PhoneNumber mobileNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(
          widget.patientUserProfile.mobileNumber,
        );

        String parsableNumber = mobileNumber.parseNumber().replaceFirst('+', '');

        if (mounted) {
          setState(() {
            number = PhoneNumber(
              isoCode: mobileNumber.isoCode,
              phoneNumber: parsableNumber,
            );
            dialCode = '+${mobileNumber.dialCode!}';
            mobileNumberController.text = parsableNumber;
          });
          widget.formKey.currentState?.fields['mobileNumber']?.didChange(parsableNumber);
        }
      } catch (e) {
        debugPrint('Error initializing phone number: $e');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    mobileNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('personalInformation'),
          style: TextStyle(fontSize: 20, color: theme.primaryColor),
        ),
        // updateMyInfo
        FormBuilderField<bool>(
          name: 'updateMyInfo',
          initialValue: false,
          autovalidateMode: AutovalidateMode.disabled,
          builder: (field) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: field.value ?? false,
                  onChanged: (val) {
                    field.didChange(val);
                  },
                  visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Transform.translate(
                  offset: const Offset(5, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('updateMyProfile'),
                        style: TextStyle(
                          color: theme.primaryColorLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Name
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: FormBuilderField<String>(
                name: 'firstName',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: widget.patientUserProfile.firstName,
                validator: ((value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('firstNameEnter');
                  } else {
                    if (value.length < 2) {
                      return context.tr('minFirstName');
                    }
                  }
                  return null;
                }),
                builder: (field) {
                  final controller = TextEditingController(text: field.value);

                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckoutTextField(
                        controller: controller,
                        theme: theme,
                        textColor: textColor,
                        name: 'firstName',
                        onChanged: (val) => field.didChange(val),
                        inputFormatters: FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-Z]+|\s"),
                        ),
                      ),
                      if (field.hasError)
                        Text(
                          field.errorText!,
                          style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12),
                        ),
                    ],
                  );
                },
              ),
            ),
            // Last Name
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: FormBuilderField<String>(
                name: 'lastName',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: widget.patientUserProfile.lastName,
                validator: ((value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('lastNameEnter');
                  } else {
                    if (value.length < 2) {
                      return context.tr('minLastName');
                    }
                  }
                  return null;
                }),
                builder: (field) {
                  final controller = TextEditingController(text: field.value);

                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckoutTextField(
                        controller: controller,
                        theme: theme,
                        textColor: textColor,
                        name: 'lastName',
                        onChanged: (val) => field.didChange(val),
                        inputFormatters: FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-Z]+|\s"),
                        ),
                      ),
                      if (field.hasError)
                        Text(
                          field.errorText!,
                          style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12),
                        ),
                    ],
                  );
                },
              ),
            ),
            // Email
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: FormBuilderField<String>(
                name: 'email',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: widget.patientUserProfile.userName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('emailEnter');
                  } else {
                    return validateEmail(value);
                  }
                },
                builder: (field) {
                  final controller = TextEditingController(text: field.value);

                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckoutTextField(
                        controller: controller,
                        theme: theme,
                        textColor: textColor,
                        name: 'email',
                        onChanged: (val) => field.didChange(val),
                        // inputFormatters: FilteringTextInputFormatter.allow(
                        //   RegExp(r"[a-zA-Z]+|\s"),
                        // ),
                      ),
                      if (field.hasError)
                        Text(
                          field.errorText!,
                          style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12),
                        ),
                    ],
                  );
                },
              ),
            ),
            // Mobile Phone
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: FormBuilderField<String>(
                name: 'mobileNumber',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (userInput) {
                  if (userInput == null || userInput.isEmpty) {
                    return context.tr('required');
                  }
                  if (!RegExp(r'^(\+|00)?[0-9]+$').hasMatch(userInput)) {
                    return context.tr('phoneValidate'); // 'Please enter a valid phone number';
                  }
                  if (userInput.length < 7 || userInput.length > 12) {
                    return context.tr('required');
                  }
                  return null;
                },
                builder: (field) {
                  final controller = TextEditingController(text: field.value ?? '');
                  controller.text = field.value ?? number.phoneNumber ?? '';
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InternationalPhoneNumberInput(
                        textFieldController: mobileNumberController,
                        initialValue: number,
                        // errorMessage: context.tr('required'),
                        validator: (userInput) {
                          if (userInput!.isEmpty) {
                            return context.tr('required');
                          }
                          if (!RegExp(r'^(\+|00)?[0-9]+$').hasMatch(userInput)) {
                            return context.tr('phoneValidate'); //'Please enter a valid phone number';
                          }

                          if (userInput.length < 7 || userInput.length > 12) {
                            return context.tr('required');
                          }

                          return null; // Return null when the input is valid
                        },
                        onInputChanged: (PhoneNumber number) {
                          field.didChange(number.phoneNumber); // ← important to sync with form
                          setState(() {
                            dialCode = number.dialCode ?? '';
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
                          color: textColor,
                        ),
                        formatInput: false,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        // inputDecoration: decoration(context, context.tr('mobileNumber')),
                        inputDecoration: InputDecoration(
                          labelText: context.tr('mobileNumber'),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pinkAccent.shade400, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pinkAccent.shade400, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 8,
                          ),
                          border: const OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: textColor,
                          ),
                        ),
                        onSaved: (PhoneNumber number) {},
                      ),
                      // if (field.hasError)
                      //   Text(
                      //     field.errorText!,
                      //     style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12),
                      //   ),
                    ],
                  );
                },
              ),
            ),
            const TermsWidget(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 38,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColorLight,
                    ],
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8),
                    right: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.all(1),
                child: GestureDetector(
                  onTap: () {
                    widget.onSubmit();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColorLight,
                          theme.primaryColor,
                        ],
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(7),
                        right: Radius.circular(7),
                      ),
                    ),
                    child: widget.submitButtonText
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
