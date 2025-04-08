
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:health_care/constants/error_handling.dart';
import 'package:health_care/models/cities.dart';
import 'package:health_care/models/countries.dart';
import 'package:health_care/models/states.dart';
import 'package:health_care/models/user_data.dart';

import 'package:health_care/models/users.dart';
import 'package:health_care/providers/user_data_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/filter_screen.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/features/profile/profile_card_widget.dart';
import 'package:health_care/src/features/profile/profile_input_widget.dart';
import 'package:health_care/src/utils/type_head_suggestions.dart';
import 'package:health_care/stream_socket.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:toastify/toastify.dart';

class PatientsDashboardProfile extends StatefulWidget {
  static const String routeName = '/patient/dashboard/profile';
  final PatientsProfile patientProfile;
  const PatientsDashboardProfile({
    super.key,
    required this.patientProfile,
  });

  @override
  State<PatientsDashboardProfile> createState() => _PatientsDashboardProfileState();
}

class _PatientsDashboardProfileState extends State<PatientsDashboardProfile> {
  final AuthService authService = AuthService();
  final ScrollController patientProfileScrollController = ScrollController();
  final _patientProfileFormKey = GlobalKey<FormState>(debugLabel: 'Patient #Profile ');
  final ImagePicker _patientProfileImagePicker = ImagePicker();
  XFile? _patientProfileimageFile;
  List<Map<String, dynamic>> patientProfileImageFiles = [];
  List<dynamic> deletedImages = [];
  final patientEmailController = TextEditingController();
  final patientFirstNameController = TextEditingController();
  final patientLastNameController = TextEditingController();
  final patientMobileNumberController = TextEditingController();
  String dialCode = "";
  final List<Map<String, dynamic>> patientGenderValues = [
    {"title": 'Mr', 'icon': '👨'},
    {"title": 'Mrs', 'icon': '👩'},
    {"title": 'Mss', 'icon': '👩'},
  ];
  final patientGenderController = TextEditingController();
  final patientDobController = TextEditingController();
  final patientCountryController = TextEditingController();
  final patientStateController = TextEditingController();
  final patientCityController = TextEditingController();
  final patientAddress1Controller = TextEditingController();
  final patientAddress2Controller = TextEditingController();
  final patientzipCodeController = TextEditingController();
  final List<Map<String, dynamic>> bloodGValues = [
    {"title": 'A+', 'icon': '🅰️'},
    {"title": 'A-', 'icon': '🅰️'},
    {"title": 'B+', 'icon': '🅱️'},
    {"title": 'B-', 'icon': '🅱️'},
    {"title": 'AB+', 'icon': '🆎'},
    {"title": 'AB-', 'icon': '🆎'},
    {"title": 'O+', 'icon': '🅾️'},
    {"title": 'O-', 'icon': '🅾️'},
  ];
  final bloodGController = TextEditingController();
  String? countryValue;
  String? stateValue;
  String? cityValue;

  double patientScrollPercentage = 0;

  PhoneNumber number = PhoneNumber(
    isoCode: 'TH',
  );

  void updateState(PatientsProfile patientProfile) async {
    patientEmailController.text = patientProfile.userProfile.userName;
    patientFirstNameController.text = patientProfile.userProfile.firstName;
    patientLastNameController.text = patientProfile.userProfile.lastName;
    patientGenderController.text = patientProfile.userProfile.gender;
    bloodGController.text = patientProfile.userProfile.bloodG;
    if (patientProfile.userProfile.dob.isNotEmpty) {
      patientDobController.text =
          DateFormat("dd MMM yyyy").format(DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(patientProfile.userProfile.dob).toLocal());
    }
    if (patientProfile.userProfile.mobileNumber.isNotEmpty) {
      PhoneNumber mobileNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(
        patientProfile.userProfile.mobileNumber,
      );
      String parsableNumber = mobileNumber.parseNumber().replaceFirst('+', '');
      patientMobileNumberController.text = parsableNumber;

      number = PhoneNumber(isoCode: mobileNumber.isoCode);
      dialCode = '+${mobileNumber.dialCode!}';
    }
    patientAddress1Controller.text = patientProfile.userProfile.address1;
    patientAddress2Controller.text = patientProfile.userProfile.address2;
    patientCountryController.text = patientProfile.userProfile.country;
    patientStateController.text = patientProfile.userProfile.state;
    patientCityController.text = patientProfile.userProfile.city;
    patientzipCodeController.text = patientProfile.userProfile.zipCode;
    countryValue = patientProfile.userProfile.country.isEmpty ? null : patientProfile.userProfile.country;
    stateValue = patientProfile.userProfile.state.isEmpty ? null : patientProfile.userProfile.state;
    cityValue = patientProfile.userProfile.city.isEmpty ? null : patientProfile.userProfile.city;
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    updateState(widget.patientProfile);
  }

  @override
  void didUpdateWidget(covariant PatientsDashboardProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateState(widget.patientProfile);
  }

  Future<void> onFormSubmit() async {
    if (_patientProfileFormKey.currentState!.validate()) {
      Map<String, dynamic> data = {};
      data['accessToken'] = widget.patientProfile.accessToken;
      data['address1'] = patientAddress1Controller.text;
      data['address2'] = patientAddress2Controller.text;
      data['billingsIds'] = widget.patientProfile.userProfile.billingsIds;
      data['bloodG'] = bloodGController.text;
      data['city'] = cityValue ?? '';
      data['country'] = countryValue ?? '';
      data['createdAt'] = widget.patientProfile.userProfile.createdAt.toIso8601String();
      data['dependentsArray'] = widget.patientProfile.userProfile.dependentsArray;
      if (patientDobController.text.isNotEmpty) {
        DateTime parsedDate = DateFormat("dd MMM yyyy").parse(patientDobController.text);
        String isoString = parsedDate.toIso8601String();
        data['dob'] = isoString;
      } else {
        data['dob'] = widget.patientProfile.userProfile.dob ?? '';
      }
      data['doctors_id'] = widget.patientProfile.userProfile.doctorsId;
      data['favs_id'] = widget.patientProfile.userProfile.favsId;
      data['firstName'] = patientFirstNameController.text.trim();
      data['fullName'] = "${patientFirstNameController.text.trim()} ${patientLastNameController.text.trim()}";
      data['gender'] = patientGenderController.text;
      data['invoice_ids'] = widget.patientProfile.userProfile.invoiceIds;
      data['isActive'] = widget.patientProfile.userProfile.isActive;
      data['lastLogin'] = widget.patientProfile.userProfile.lastLogin;
      data['lastName'] = patientLastNameController.text.trim();
      data['lastUpdate'] = widget.patientProfile.userProfile.lastUpdate.toIso8601String();
      data['medicalRecordsArray'] = widget.patientProfile.userProfile.medicalRecordsArray;
      data['mobileNumber'] = '$dialCode${patientMobileNumberController.text}';
      data['online'] = true;
      data['prescriptions_id'] = widget.patientProfile.userProfile.prescriptionsId;
      data['profileImage'] = widget.patientProfile.userProfile.profileImage;
      data['rate_array'] = widget.patientProfile.userProfile.rateArray;
      data['reservations_id'] = widget.patientProfile.userProfile.reservationsId;
      data['reviews_array'] = widget.patientProfile.userProfile.reviewsArray;
      data['roleName'] = widget.patientProfile.roleName;
      data['services'] = widget.patientProfile.services;
      data['state'] = stateValue ?? '';
      data['userName'] = patientEmailController.text;
      data['zipCode'] = patientzipCodeController.text;
      data['_id'] = widget.patientProfile.userId;
      data['userId'] = widget.patientProfile.userId;
      data['id'] = widget.patientProfile.userProfile.patientsId;
      data['clinicImagesFiles'] = [];
      data['profileImageFiles'] = [];
      if (patientProfileImageFiles.isNotEmpty) {
        for (var i = 0; i < patientProfileImageFiles.length; i++) {
          var element = patientProfileImageFiles[i];
          final fileFromImage = patientProfileImageFiles[i]['profileImage'];
          List<int> fileBytes = await fileFromImage.readAsBytes();
          Uint8List fileUint8List = Uint8List.fromList(fileBytes);
          data['profileImageFiles'].add({
            'profileImage': fileUint8List,
            'profileImageName': element['profileImageName'],
            'profileImageExtentionNoDot': element['profileImageExtentionNoDot']
          });
        }
      }
      if (deletedImages.isNotEmpty) {
        data['deletedImages'] = deletedImages;
      } else {
        data['deletedImages'] = [];
      }
      if (mounted) {
        showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          showDragHandle: false,
          useSafeArea: true,
          context: context,
          builder: (context) => const LoadingScreen(),
        );
      }
      socket.emit('profileUpdate', data);
      socket.once('profileUpdateReturn', (msg) {
        if (msg['status'] != 200) {
          Navigator.pop(context);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            showModalBottomSheet(
              isDismissible: true,
              enableDrag: true,
              showDragHandle: true,
              useSafeArea: true,
              context: context,
              constraints: const BoxConstraints.expand(height: 100, width: double.infinity),
              builder: (context) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(msg['message']),
              ),
            );
          });
        } else {
          authService.updateProfile(context, msg['accessToken']);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Future deleteImageFromCache() async {
              late String imageUrl = '';
              if (widget.patientProfile.userProfile.profileImage.isNotEmpty) {
                imageUrl = widget.patientProfile.userProfile.profileImage;
              }
              await CachedNetworkImage.evictFromCache(imageUrl);
            }

            deleteImageFromCache();

            setState(() {
              patientProfileImageFiles.clear();
              _patientProfileimageFile = null;
              deletedImages.clear();
            });
          });
        }
      });
    }
  }

  void confirmDeleteClick(
    UserData userData,
  ) {
    Map<String, dynamic> data = {};
    data['userId'] = widget.patientProfile.userId;
    data['ipAddr'] = userData.query;
    data['userAgent'] = widget.patientProfile.userProfile.lastLogin.userAgent;
    socket.emit('deleteUser', data);
    socket.once('deleteUserReturn', (msg) {
      Navigator.maybePop(context);
      if (msg['status'] != 200) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          showModalBottomSheet(
            isDismissible: true,
            enableDrag: true,
            showDragHandle: true,
            useSafeArea: true,
            context: context,
            constraints: const BoxConstraints.expand(height: 100, width: double.infinity),
            builder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(msg['message'] ?? 'null'),
            ),
          );
        });
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          authService.logoutService();
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    patientProfileScrollController.dispose();
    deletedImages = [];
    _patientProfileimageFile = null;
    patientProfileImageFiles.clear();
    patientEmailController.dispose();
    patientFirstNameController.dispose();
    patientLastNameController.dispose();
    patientMobileNumberController.dispose();
    patientGenderController.dispose();
    patientDobController.dispose();
    patientCountryController.dispose();
    patientStateController.dispose();
    patientCityController.dispose();
    patientAddress1Controller.dispose();
    patientAddress2Controller.dispose();
    patientzipCodeController.dispose();
    bloodGController.dispose();
    countryValue = null;
    stateValue = null;
    cityValue = null;
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    final userData = Provider.of<UserDataProvider>(context).userData;
    PatientsProfile patientsProfile = widget.patientProfile;
    late String imageUrl = '';
    if (patientsProfile.userProfile.profileImage.isNotEmpty) {
      imageUrl = patientsProfile.userProfile.profileImage;
    }
    return ScaffoldWrapper(
      key: const Key('patient_profile'),
      title: context.tr('patientProfile'),
      children: NotificationListener(
        onNotification: (notification) {
          double per = 0;
          if (patientProfileScrollController.hasClients) {
            per = ((patientProfileScrollController.offset / patientProfileScrollController.position.maxScrollExtent));
          }
          if (per >= 0) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  patientScrollPercentage = 307 * per;
                });
              }
            });
          }
          return false;
        },
        child: Stack(
          children: [
            ListView.builder(
              shrinkWrap: true,
              controller: patientProfileScrollController,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Form(
                  key: _patientProfileFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: FadeinWidget(
                    isCenter: false,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Center(
                          child: Stack(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 60.0,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: _patientProfileimageFile == null
                                      ? imageUrl.isEmpty
                                          ? Image.asset(
                                              'assets/images/default-avatar.png',
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fadeInDuration: const Duration(milliseconds: 0),
                                              fadeOutDuration: const Duration(milliseconds: 0),
                                            )
                                      : Image.file(
                                          File(_patientProfileimageFile!.path),
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                ),
                              ),
                              if (_patientProfileimageFile != null) ...[
                                Positioned(
                                  top: 5.0,
                                  left: 7.0,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        patientProfileImageFiles.clear();
                                        _patientProfileimageFile = null;
                                      });
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.pink.shade400,
                                      size: 28.0,
                                    ),
                                  ),
                                ),
                              ],
                              Positioned(
                                top: 5.0,
                                right: 5.0,
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: ((builder) => bottomSheet('profileImage', 'chooseProfilePhoto')),
                                    );
                                  },
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Theme.of(context).primaryColorLight,
                                    size: 28.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Theme.of(context).primaryColorLight,
                        ),
                        //BasidInfo
                        ProfileCardWidget(
                          listTitle: context.tr('basicInfo'),
                          childrens: [
                            ProfileInputWidget(controller: patientEmailController, readOnly: true, lable: context.tr('email')),
                            ProfileInputWidget(
                              controller: patientFirstNameController,
                              readOnly: false,
                              lable: context.tr('firstName'),
                              inputFormatters: FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z]+|\s"),
                              ),
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
                            ),
                            ProfileInputWidget(
                              controller: patientLastNameController,
                              readOnly: false,
                              lable: context.tr('lastName'),
                              inputFormatters: FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z]+|\s"),
                              ),
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InternationalPhoneNumberInput(
                                initialValue: number,
                                errorMessage: context.tr('required'),
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
                                onInputChanged: (PhoneNumber number) async {
                                  setState(() {
                                    dialCode = number.dialCode!;
                                  });
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
                                textFieldController: patientMobileNumberController,
                                formatInput: false,
                                keyboardType: const TextInputType.numberWithOptions(
                                  signed: true,
                                  decimal: true,
                                ),
                                inputDecoration: decoration(context, context.tr('mobileNumber')),
                                onSaved: (PhoneNumber number) {},
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InputDecorator(
                                decoration: decoration(context, context.tr('gender')),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isDense: true,
                                    value: patientGenderController.text.isEmpty ? null : patientGenderController.text,
                                    hint: Text(context.tr('gender')),
                                    items: patientGenderValues.map<DropdownMenuItem<String>>((Map<String, dynamic> values) {
                                      return DropdownMenuItem<String>(
                                        value: values['title'],
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(left: 12.0),
                                              child: Text(values['icon']!),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              values['title']!,
                                              style: TextStyle(
                                                color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        patientGenderController.text = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InputDecorator(
                                decoration: decoration(context, context.tr('bloodG')),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isDense: true,
                                    value: bloodGController.text.isEmpty ? null : bloodGController.text,
                                    hint: Text(context.tr('bloodG')),
                                    items: bloodGValues.map<DropdownMenuItem<String>>((Map<String, dynamic> values) {
                                      return DropdownMenuItem<String>(
                                        value: values['title'],
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(left: 12.0),
                                              child: Text(values['icon']!),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              values['title']!,
                                              style: TextStyle(
                                                color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        bloodGController.text = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            ProfileInputWidget(
                              controller: patientDobController,
                              readOnly: false,
                              lable: context.tr('dob'),
                              keyboardType: TextInputType.none,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    initialDatePickerMode: DatePickerMode.year,
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1924),
                                    lastDate: DateTime.now());
                                if (pickedDate != null) {
                                  String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);

                                  setState(() {
                                    patientDobController.text = formattedDate;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                        const SizedBox(height: 30),
                        //Contact details
                        ProfileCardWidget(
                          listTitle: context.tr('contactDetails'),
                          childrens: [
                            ProfileInputWidget(controller: patientAddress1Controller, readOnly: false, lable: context.tr('address1')),
                            ProfileInputWidget(controller: patientAddress2Controller, readOnly: false, lable: context.tr('address2')),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: TypeAheadField<Countries>(
                                  controller: patientCountryController,
                                  hideWithKeyboard: false,
                                  suggestionsCallback: (search) => countrySuggestionsCallback(search),
                                  itemSeparatorBuilder: (context, index) {
                                    return Divider(
                                      height: 1,
                                      color: Theme.of(context).primaryColor,
                                    );
                                  },
                                  emptyBuilder: (context) => ListTile(
                                    title: Text(
                                      context.tr('noItem'),
                                    ),
                                  ),
                                  errorBuilder: (context, error) {
                                    return ListTile(
                                      title: Text(
                                        error.toString(),
                                        style: TextStyle(color: Theme.of(context).primaryColor),
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: Theme.of(context).primaryColorLight,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      // key: countryProfileKey,
                                      controller: controller,
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                      },
                                      focusNode: focusNode,
                                      autofocus: false,
                                      onChanged: (value) {
                                        patientCountryController.text = value;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColorLight,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 14.0,
                                          horizontal: 8,
                                        ),
                                        suffixIcon: countryValue == null
                                            ? null
                                            : IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    patientCountryController.text = '';
                                                    patientStateController.text = '';
                                                    patientCityController.text = '';
                                                    countryValue = null;
                                                    stateValue = null;
                                                    cityValue = null;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Theme.of(context).primaryColorLight,
                                                ),
                                              ),
                                        border: const OutlineInputBorder(),
                                        labelStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        labelText: context.tr('country'),
                                      ),
                                    );
                                  },
                                  decorationBuilder: (context, child) {
                                    return Material(
                                      type: MaterialType.card,
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(8),
                                      borderOnForeground: true,
                                      child: child,
                                    );
                                  },
                                  offset: const Offset(0, 2),
                                  constraints: const BoxConstraints(maxHeight: 500),
                                  itemBuilder: (context, country) {
                                    List<InlineSpan> temp = highlightText(patientCountryController.text, country.name,
                                        brightness == Brightness.dark ? Colors.white : Colors.black, Theme.of(context).primaryColor);
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8, right: 8),
                                          child: Text(
                                            country.emoji,
                                            style: const TextStyle(fontSize: 24.0),
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: ListTile(
                                            title: Text.rich(
                                              TextSpan(
                                                children: temp,
                                              ),
                                            ),
                                            subtitle: Text(
                                              country.subtitle ?? '{$country.region} - ${country.subregion}',
                                              style: TextStyle(color: brightness == Brightness.dark ? Colors.white : Colors.black),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                  onSelected: (country) {
                                    setState(() {
                                      countryValue = country.name;
                                    });
                                    patientCountryController.text = '${country.emoji} - ${country.name}';
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: TypeAheadField<States>(
                                  controller: patientStateController,
                                  hideWithKeyboard: false,
                                  suggestionsCallback: (search) => stateSuggestionsCallback(search, countryValue),
                                  itemSeparatorBuilder: (context, index) {
                                    return Divider(
                                      height: 1,
                                      color: Theme.of(context).primaryColor,
                                    );
                                  },
                                  emptyBuilder: (context) => ListTile(
                                    title: Text(
                                      context.tr('noItem'),
                                    ),
                                  ),
                                  errorBuilder: (context, error) {
                                    return ListTile(
                                      title: Text(
                                        error.toString(),
                                        style: TextStyle(color: Theme.of(context).primaryColor),
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: Theme.of(context).primaryColorLight,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      // key: stateProfileKey,
                                      controller: controller,
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                      },
                                      focusNode: focusNode,
                                      autofocus: false,
                                      onChanged: (value) {
                                        patientStateController.text = value;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColorLight,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 14.0,
                                          horizontal: 8,
                                        ),
                                        suffixIcon: stateValue == null
                                            ? null
                                            : IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    stateValue = null;
                                                    cityValue = null;
                                                    patientStateController.text = '';
                                                    patientCityController.text = '';
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Theme.of(context).primaryColorLight,
                                                ),
                                              ),
                                        border: const OutlineInputBorder(),
                                        labelStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        labelText: context.tr('state'),
                                      ),
                                    );
                                  },
                                  decorationBuilder: (context, child) {
                                    return Material(
                                      type: MaterialType.card,
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(8),
                                      borderOnForeground: true,
                                      child: child,
                                    );
                                  },
                                  offset: const Offset(0, 2),
                                  constraints: const BoxConstraints(maxHeight: 500),
                                  itemBuilder: (context, state) {
                                    List<InlineSpan> temp = highlightText(patientStateController.text, state.name,
                                        brightness == Brightness.dark ? Colors.white : Colors.black, Theme.of(context).primaryColor);
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8, right: 8),
                                          child: Text(
                                            state.emoji,
                                            style: const TextStyle(fontSize: 24.0),
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: ListTile(
                                            title: Text.rich(TextSpan(children: temp)),
                                            subtitle: Text(
                                              state.subtitle ?? '{$state.countryName} - ${state.iso2}',
                                              style: TextStyle(
                                                color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                  onSelected: (state) {
                                    setState(() {
                                      countryValue = state.countryName;
                                      stateValue = state.name;
                                    });
                                    patientStateController.text = '${state.emoji} - ${state.name}';
                                    patientCountryController.text = '${state.emoji} - ${state.countryName}';
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: TypeAheadField<Cities>(
                                  controller: patientCityController,
                                  hideWithKeyboard: false,
                                  suggestionsCallback: (search) => citySuggestionsCallback(search, countryValue, stateValue),
                                  itemSeparatorBuilder: (context, index) {
                                    return Divider(
                                      height: 1,
                                      color: Theme.of(context).primaryColor,
                                    );
                                  },
                                  emptyBuilder: (context) => ListTile(
                                    title: Text(
                                      context.tr('noItem'),
                                    ),
                                  ),
                                  errorBuilder: (context, error) {
                                    return ListTile(
                                      title: Text(
                                        error.toString(),
                                        style: TextStyle(color: Theme.of(context).primaryColor),
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: Theme.of(context).primaryColorLight,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      // key: cityProfileKey,
                                      controller: controller,
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                      },
                                      focusNode: focusNode,
                                      autofocus: false,
                                      onChanged: (value) {
                                        patientCityController.text = value;
                                      },
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context).primaryColorLight,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 14.0,
                                          horizontal: 8,
                                        ),
                                        suffixIcon: cityValue == null
                                            ? null
                                            : IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    cityValue = null;
                                                    patientCityController.text = '';
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Theme.of(context).primaryColorLight,
                                                ),
                                              ),
                                        border: const OutlineInputBorder(),
                                        labelStyle: const TextStyle(color: Colors.grey),
                                        labelText: context.tr('city'),
                                      ),
                                    );
                                  },
                                  decorationBuilder: (context, child) {
                                    return Material(
                                      type: MaterialType.card,
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(8),
                                      borderOnForeground: true,
                                      child: child,
                                    );
                                  },
                                  offset: const Offset(0, 2),
                                  constraints: const BoxConstraints(maxHeight: 500),
                                  itemBuilder: (context, city) {
                                    List<InlineSpan> temp = highlightText(patientCityController.text, city.name,
                                        brightness == Brightness.dark ? Colors.white : Colors.black, Theme.of(context).primaryColor);
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8, right: 8),
                                          child: Text(
                                            city.emoji,
                                            style: const TextStyle(fontSize: 24.0),
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: ListTile(
                                            title: Text.rich(TextSpan(children: temp)),
                                            subtitle: Text(
                                              city.subtitle ?? '{$city.countryName} - ${city.stateName}',
                                              style: TextStyle(color: brightness == Brightness.dark ? Colors.white : Colors.black),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                  onSelected: (city) {
                                    setState(() {
                                      countryValue = city.countryName;
                                      stateValue = city.stateName;
                                      cityValue = city.name;
                                    });

                                    patientStateController.text = '${city.emoji} - ${city.stateName}';
                                    patientCountryController.text = '${city.emoji} - ${city.countryName}';
                                    patientCityController.text = '${city.emoji} - ${city.name}';
                                  },
                                ),
                              ),
                            ),
                            ProfileInputWidget(
                              controller: patientzipCodeController,
                              readOnly: false,
                              lable: context.tr('zipCode'),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),

                        //Buttons
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(double.maxFinite, 30),
                              elevation: 5.0,
                              foregroundColor: Theme.of(context).primaryColorLight,
                              animationDuration: const Duration(milliseconds: 1000),
                              backgroundColor: Theme.of(context).primaryColorLight,
                              shadowColor: Theme.of(context).primaryColorLight,
                            ),
                            onPressed: onFormSubmit,
                            child: Text(
                              context.tr('submit'),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(double.maxFinite, 30),
                              elevation: 5.0,
                              foregroundColor: Colors.pinkAccent.shade400,
                              animationDuration: const Duration(milliseconds: 1000),
                              backgroundColor: Colors.pinkAccent.shade400,
                              shadowColor: Colors.pinkAccent.shade400,
                            ),
                            onPressed: () {
                              showToast(
                                context,
                                Toast(
                                  id: '_deleteToast',
                                  child: CustomInfoToast(
                                    onConfirm: () {
                                      confirmDeleteClick(userData!);
                                    },
                                    title: '',
                                    description: context.tr('deleteAccountWarning'),
                                    confirmText: 'delete',
                                    closeText: 'cancel',
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              context.tr('deleteAccount'),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: 1,
            ),
            ScrollButton(scrollController: patientProfileScrollController, scrollPercentage: patientScrollPercentage)
          ],
        ),
      ),
    );
  }

  Widget bottomSheet(String imageType, String text) {
    return Container(
      height: 150.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            context.tr(text),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            IconButton(
              icon: const Icon(Icons.camera),
              onPressed: () {
                switch (imageType) {
                  case "profileImage":
                    takePhoto(ImageSource.camera);
                    break;
                  default:
                }
              },
              // label: Text("Camera"),
            ),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () {
                switch (imageType) {
                  case "profileImage":
                    imageSelectorGallery();
                    break;
                  default:
                }
              },
              // label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }

  Future imageSelectorGallery() async {
    if (mounted) {
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: true,
        context: context,
        builder: (context) => const LoadingScreen(),
      ).whenComplete(() {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).maybePop();
        });
      });
    }
    FilePickerResult? image = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
      ],
    );
    if (image != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
      var element = image.files.first;
      if (element.size < 2000000) {
        setState(() {
          patientProfileImageFiles = [
            {
              "profileImage": File(element.path!),
              "profileImageName": element.name,
              "profileImageExtentionNoDot": element.name.split('.').last,
            }
          ];
          _patientProfileimageFile = image.xFiles.first as XFile?;
        });
      } else {
        if (mounted) {
          showToast(
            context,
            Toast(
              title: 'Failed',
              description: context.tr('imageSizeExtend'),
              duration: Duration(milliseconds: 200.toInt()),
              lifeTime: Duration(
                milliseconds: 2500.toInt(),
              ),
            ),
          );
        }
      }
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
    }
  }

  void takePhoto(ImageSource source) async {
    if (mounted) {
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: true,
        context: context,
        builder: (context) => const LoadingScreen(),
      ).whenComplete(() {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).maybePop();
        });
      });
    }
    final pickedFile = await _patientProfileImagePicker.pickImage(
      source: source,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
      var size = await File(pickedFile.path).length();
      if (size < 2000000) {
        setState(() {
          patientProfileImageFiles = [
            {
              "profileImage": File(pickedFile.path),
              "profileImageName": pickedFile.name,
              "profileImageExtentionNoDot": pickedFile.name.split('.').last,
            }
          ];
          _patientProfileimageFile = pickedFile;
        });
      } else {
        if (mounted) {
          showToast(
            context,
            Toast(
              title: 'Failed',
              description: context.tr('imageSizeExtend'),
              duration: Duration(milliseconds: 200.toInt()),
              lifeTime: Duration(
                milliseconds: 2500.toInt(),
              ),
            ),
          );
        }
      }
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
    }
  }
}
