// import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/user_data.dart';
import 'package:health_care/providers/user_data_provider.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/profile/profile_card_widget.dart';
import 'package:health_care/src/features/profile/profile_input_widget.dart';

import 'package:health_care/src/utils/get_image_xfile_by_url.dart';
import 'package:health_care/src/utils/type_head_suggestions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:toastify/toastify.dart';

import 'package:health_care/constants/error_handling.dart';
import 'package:health_care/models/cities.dart';
import 'package:health_care/models/countries.dart';
import 'package:health_care/models/specialities.dart';
import 'package:health_care/models/states.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/specialities_service.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/filter_screen.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/utils/generate_random_string.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:health_care/stream_socket.dart';
import 'package:health_care/theme_config.dart';

class DoctorsDashboardProfile extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/profile';
  final DoctorsProfile doctorProfile;
  const DoctorsDashboardProfile({
    super.key,
    required this.doctorProfile,
  });

  @override
  State<DoctorsDashboardProfile> createState() => _DoctorsDashboardProfileState();
}

class _DoctorsDashboardProfileState extends State<DoctorsDashboardProfile> {
  final AuthService authService = AuthService();
  final ScrollController profileScrollController = ScrollController();
  final profileFormKey = GlobalKey<FormState>();

  final ImagePicker _profileImagePicker = ImagePicker();
  XFile? _profileimageFile;
  List<Map<String, dynamic>> profileImageFiles = [];
  List<XFile> _clinicXfileFiles = [];
  List<Map<String, dynamic>> clinicImageFiles = [];
  List<dynamic> deletedImages = [];
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  String dialCode = "";
  final List<Map<String, dynamic>> genderValues = [
    {"title": 'Mr', 'icon': '👨'},
    {"title": 'Mrs', 'icon': '👩'},
    {"title": 'Mss', 'icon': '👩'},
  ];
  final genderController = TextEditingController();
  final dobController = TextEditingController();
  final aboutMeController = TextEditingController();
  final clinicNameController = TextEditingController();
  final clinicAddressController = TextEditingController();
  // final GlobalObjectKey countryProfileKey = const GlobalObjectKey('profilecountry');
  final profileCountryController = TextEditingController();
  // final GlobalObjectKey stateProfileKey = const GlobalObjectKey('profilestate');
  final profileStateController = TextEditingController();
  // final GlobalObjectKey cityProfileKey = const GlobalObjectKey('profilecity');
  final profileCityController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final zipCodeController = TextEditingController();
  final specialitiesServices = StringTagController();
  final speciality = TextEditingController();
  List<Specialities> specialityValue = [];
  List<Map<String, TextEditingController>> educationController = [];
  List<Map<String, TextEditingController>> experinceController = [];
  List<Map<String, TextEditingController>> awardController = [];
  List<Map<String, TextEditingController>> membershipController = [];
  List<Map<String, TextEditingController>> registrationController = [];

  String? countryValue;
  String? stateValue;
  String? cityValue;
  List<List<int>> experienceFromDate = [];
  List<List<int>> experienceToDate = [];

  final SpecialitiesService specialitiesService = SpecialitiesService();
  double scrollPercentage = 0;

  PhoneNumber number = PhoneNumber(
    isoCode: '',
  );

  void updateState(DoctorsProfile doctorProfile) async {
    emailController.text = doctorProfile.userProfile.userName;
    firstNameController.text = doctorProfile.userProfile.firstName;
    lastNameController.text = doctorProfile.userProfile.lastName;
    if (doctorProfile.userProfile.mobileNumber.isNotEmpty) {
      PhoneNumber mobileNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(
        doctorProfile.userProfile.mobileNumber,
      );
      String parsableNumber = mobileNumber.parseNumber().replaceFirst('+', '');
      mobileNumberController.text = parsableNumber;

      number = PhoneNumber(isoCode: mobileNumber.isoCode);
      dialCode = '+${mobileNumber.dialCode!}';
    }
    genderController.text = doctorProfile.userProfile.gender;
    if (doctorProfile.userProfile.dob.isNotEmpty) {
      dobController.text = DateFormat("dd MMM yyyy").format(DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(doctorProfile.userProfile.dob).toLocal());
    }
    aboutMeController.text = doctorProfile.userProfile.aboutMe;
    clinicNameController.text = doctorProfile.userProfile.clinicAddress;
    clinicAddressController.text = doctorProfile.userProfile.clinicAddress;
    if (doctorProfile.userProfile.clinicImages.isNotEmpty) {
      if (clinicImageFiles.length < doctorProfile.userProfile.clinicImages.length) {
        for (var i = 0; i < doctorProfile.userProfile.clinicImages.length; i++) {
          var element = doctorProfile.userProfile.clinicImages[i];

          clinicImageFiles = [
            ...clinicImageFiles,
            {
              "src": element.src,
              "width": element.width,
              "height": element.height,
              "isSelected": false,
              "name": element.name,
              "uuid": element.uuid,
              "random": element.random,
              "tags": [
                {"value": "value", "title": element.name}
              ]
            }
          ];
          String url = element.src;
          XFile reteriveXfile = await getImageXFileByUrl(url);
          _clinicXfileFiles.add(reteriveXfile);
        }
      }
    }
    address1Controller.text = doctorProfile.userProfile.address1;
    address2Controller.text = doctorProfile.userProfile.address2;
    profileCountryController.text = doctorProfile.userProfile.country;
    profileStateController.text = doctorProfile.userProfile.state;
    profileCityController.text = doctorProfile.userProfile.city;
    zipCodeController.text = doctorProfile.userProfile.zipCode;
    countryValue = doctorProfile.userProfile.country.isEmpty ? null : doctorProfile.userProfile.country;
    stateValue = doctorProfile.userProfile.state.isEmpty ? null : doctorProfile.userProfile.state;
    cityValue = doctorProfile.userProfile.city.isEmpty ? null : doctorProfile.userProfile.city;
    if (doctorProfile.userProfile.specialities.isNotEmpty) {
      speciality.text = doctorProfile.userProfile.specialities.first.specialities;
      specialityValue = doctorProfile.userProfile.specialities;
    }
    if (doctorProfile.userProfile.educations.isNotEmpty) {
      educationController.clear();
      for (var i = 0; i < doctorProfile.userProfile.educations.length; i++) {
        var element = doctorProfile.userProfile.educations[i];
        educationController.add({
          "collage": TextEditingController(text: element.collage),
          "degree": TextEditingController(text: element.degree),
          "yearOfCompletion": TextEditingController(
              text: DateFormat("dd MMM yyyy").format(DateFormat("yyyy-MM-ddTHH:mm:ss.Z").parseUTC(element.yearOfCompletion).toLocal())),
        });
      }
    }

    if (doctorProfile.userProfile.experinces.isNotEmpty) {
      experinceController.clear();
      for (var i = 0; i < doctorProfile.userProfile.experinces.length; i++) {
        var element = doctorProfile.userProfile.experinces[i];
        experinceController.add({
          "hospitalName": TextEditingController(text: element.hospitalName),
          "from": TextEditingController(text: DateFormat("dd MMM yyyy").format(DateFormat("yyyy-MM-ddTHH:mm:ss.Z").parseUTC(element.from).toLocal())),
          "to": TextEditingController(text: DateFormat("dd MMM yyyy").format(DateFormat("yyyy-MM-ddTHH:mm:ss.Z").parseUTC(element.to).toLocal())),
          "designation": TextEditingController(text: element.designation),
        });
        experienceToDate.add([1934, 1, 1]);
        experienceFromDate.add([1934, 1, 1]);
      }
    }
    if (doctorProfile.userProfile.awards.isNotEmpty) {
      awardController.clear();
      for (var i = 0; i < doctorProfile.userProfile.awards.length; i++) {
        var element = doctorProfile.userProfile.awards[i];
        awardController.add({
          "award": TextEditingController(text: element.award),
          'year': TextEditingController(text: DateFormat("yyyy").format(DateFormat("yyyy-MM-ddTHH:mm:ss.Z").parseUTC(element.year).toLocal())),
        });
      }
    }
    if (doctorProfile.userProfile.memberships.isNotEmpty) {
      membershipController.clear();
      for (var i = 0; i < doctorProfile.userProfile.memberships.length; i++) {
        var element = doctorProfile.userProfile.memberships[i];
        membershipController.add({
          "membership": TextEditingController(text: element.membership),
        });
      }
    }
    if (doctorProfile.userProfile.registrations.isNotEmpty) {
      registrationController.clear();
      for (var i = 0; i < doctorProfile.userProfile.registrations.length; i++) {
        var element = doctorProfile.userProfile.registrations[i];
        registrationController.add({
          "registration": TextEditingController(text: element.registration),
          "year": TextEditingController(text: DateFormat('yyyy').format(DateFormat("yyyy-MM-ddTHH:mm:ss.Z").parseUTC(element.year).toLocal())),
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    specialitiesService.getSpecialitiesData(context);
    updateState(widget.doctorProfile);
  }

  @override
  void didUpdateWidget(covariant DoctorsDashboardProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateState(widget.doctorProfile);
  }

  Future<void> onFormSubmit() async {
    if (profileFormKey.currentState!.validate() && specialitiesServices.getTags!.isNotEmpty) {
      Map<String, dynamic> data = {};
      data['createdAt'] = widget.doctorProfile.userProfile.createdAt;
      data['userName'] = emailController.text;
      data['firstName'] = firstNameController.text.trim();
      data['lastName'] = lastNameController.text.trim();
      data['mobileNumber'] = '$dialCode${mobileNumberController.text}';
      data['gender'] = genderController.text;
      if (dobController.text.isNotEmpty) {
        data['dob'] = DateFormat("yyyy-MM-ddTHH:mm:ssZ").format(DateFormat("dd MMM yyyy").parseUTC(dobController.text).toLocal());
      } else {
        data['dob'] = widget.doctorProfile.userProfile.dob;
      }

      data['aboutMe'] = aboutMeController.text;
      data['clinicName'] = clinicNameController.text;
      data['clinicAddress'] = clinicAddressController.text;

      data['clinicImages'] = widget.doctorProfile.userProfile.clinicImages.map((x) => x.toMap()).toList();
      data['profileImage'] = widget.doctorProfile.userProfile.profileImage;
      data['roleName'] = widget.doctorProfile.roleName;
      data['services'] = widget.doctorProfile.services;

      data['address1'] = address1Controller.text;
      data['address2'] = address2Controller.text;
      data['country'] = countryValue ?? '';
      data['state'] = stateValue ?? '';
      data['city'] = cityValue ?? '';
      data['zipCode'] = zipCodeController.text;
      data['pricing'] = widget.doctorProfile.userProfile.pricing;
      data['specialitiesServices'] = specialitiesServices.getTags;
      if (specialityValue.isNotEmpty) {
        data['specialities'] = [
          {
            "specialities": specialityValue.first.specialities,
            "description": specialityValue.first.description,
            "image": specialityValue.first.image,
            "imageId": specialityValue.first.imageId,
            "users_id": specialityValue.first.usersId,
          }
        ];
      }
      data['educations'] = [];
      if (deletedImages.isNotEmpty) {
        data['deletedImages'] = deletedImages;
        for (var i = 0; i < deletedImages.length; i++) {
          var random = deletedImages[i];
          data['clinicImages'].removeWhere((img) => img['random'] == random);
        }
      } else {
        data['deletedImages'] = [];
      }
      if (educationController.isNotEmpty) {
        for (var element in educationController) {
          Map<String, dynamic> educate = {};
          element.forEach((k, v) {
            String value = v.text;
            if (k == 'yearOfCompletion') {
              value = DateFormat("yyyy-MM-ddTHH:mm:ss.Z").format(DateFormat("dd MMM yyyy").parseUTC(v.text).toLocal());
            }
            educate[k] = value;
          });
          data['educations'].add(educate);
        }
      } else {
        data['educations'].clear();
      }
      data['experinces'] = [];
      if (experinceController.isNotEmpty) {
        for (var element in experinceController) {
          Map<String, dynamic> experince = {};
          element.forEach((k, v) {
            String value = v.text;
            if (k == 'from' || k == 'to') {
              value = DateFormat("yyyy-MM-ddTHH:mm:ss.Z").format(DateFormat("dd MMM yyyy").parseUTC(v.text).toLocal());
            }
            experince[k] = value;
          });
          data['experinces'].add(experince);
        }
      } else {
        data['experinces'].clear();
      }
      data['awards'] = [];
      if (awardController.isNotEmpty) {
        for (var element in awardController) {
          Map<String, dynamic> award = {};
          element.forEach((k, v) {
            String value = v.text;
            if (k == 'year') {
              value = DateFormat("yyyy-MM-ddTHH:mm:ss.Z").format(DateFormat("yyyy").parseUTC(v.text).toLocal());
            }
            award[k] = value;
          });
          data['awards'].add(award);
        }
      } else {
        data['awards'].clear();
      }
      data['memberships'] = [];
      if (membershipController.isNotEmpty) {
        for (var element in membershipController) {
          Map<String, dynamic> membe = {};
          element.forEach((k, v) => membe[k] = v.text);
          data['memberships'].add(membe);
        }
      } else {
        data['memberships'].clear();
      }
      data['socialMedia'] = widget.doctorProfile.userProfile.socialMedia;
      data['registrations'] = [];
      if (registrationController.isNotEmpty) {
        for (var element in registrationController) {
          Map<String, dynamic> regist = {};
          element.forEach((k, v) {
            String value = v.text;
            if (k == 'year') {
              value = DateFormat("yyyy-MM-ddTHH:mm:ss.Z").format(DateFormat("yyyy").parseUTC(v.text).toLocal());
            }
            regist[k] = value;
          });
          data['registrations'].add(regist);
        }
      } else {
        data['registrations'].clear();
      }
      data['accessToken'] = widget.doctorProfile.accessToken;
      data['isActive'] = widget.doctorProfile.userProfile.isActive;
      data['invoice_ids'] = widget.doctorProfile.userProfile.invoiceIds;
      data['reviews_array'] = widget.doctorProfile.userProfile.reviewsArray;
      data['rate_array'] = widget.doctorProfile.userProfile.rateArray;
      data['timeSlotId'] = widget.doctorProfile.userProfile.timeSlotId;
      data['patients_id'] = widget.doctorProfile.userProfile.patientsId;
      data['favs_id'] = widget.doctorProfile.userProfile.favsId;
      data['reservations_id'] = widget.doctorProfile.userProfile.reservationsId;
      data['prescriptions_id'] = widget.doctorProfile.userProfile.prescriptionsId;
      data['lastUpdate'] = widget.doctorProfile.userProfile.lastUpdate;
      data['online'] = true;
      data['lastLogin'] = widget.doctorProfile.userProfile.lastLogin;
      data['_id'] = widget.doctorProfile.userId;
      data['clinicImagesFiles'] = [];
      if (clinicImageFiles.isNotEmpty) {
        for (var i = 0; i < clinicImageFiles.length; i++) {
          var element = clinicImageFiles[i];
          if (!element['src'].startsWith(RegExp(r'^(http|https)://'))) {
            final fileFromImage = File(element['src']);
            List<int> fileBytes = await fileFromImage.readAsBytes();
            Uint8List fileUint8List = Uint8List.fromList(fileBytes);
            data['clinicImages'].add({
              "src": element['src'],
              "width": element['width'],
              "height": element['height'],
              "isSelected": element['isSelected'],
              "name": element['name'],
              "random": element['random'],
              "tags": element['tags'],
            });
            data['clinicImagesFiles'].add({
              "clinicImage": fileUint8List,
              'clinicImageName': element['name'],
              'random': element['random'],
            });
          }
        }
      }
      data['profileImageFiles'] = [];
      if (profileImageFiles.isNotEmpty) {
        for (var i = 0; i < profileImageFiles.length; i++) {
          var element = profileImageFiles[i];
          final fileFromImage = profileImageFiles[i]['profileImage'];
          List<int> fileBytes = await fileFromImage.readAsBytes();
          Uint8List fileUint8List = Uint8List.fromList(fileBytes);
          data['profileImageFiles'].add({
            'profileImage': fileUint8List,
            'profileImageName': element['profileImageName'],
            'profileImageExtentionNoDot': element['profileImageExtentionNoDot']
          });
        }
      }
      data['userId'] = widget.doctorProfile.userId;

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
              if (widget.doctorProfile.userProfile.profileImage.isNotEmpty) {
                imageUrl = widget.doctorProfile.userProfile.profileImage; //?random=${DateTime.now().millisecondsSinceEpoch}
              }
              await CachedNetworkImage.evictFromCache(imageUrl);
            }

            deleteImageFromCache();

            setState(() {
              profileImageFiles.clear();
              _profileimageFile = null;
              deletedImages.clear();
              _clinicXfileFiles.clear();
              clinicImageFiles.clear();
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
    data['userId'] = widget.doctorProfile.userId;
    data['ipAddr'] = userData.query;
    data['userAgent'] = widget.doctorProfile.userProfile.lastLogin.userAgent;
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
    _profileimageFile = null;
    _clinicXfileFiles = [];
    profileImageFiles = [];
    clinicImageFiles = [];
    deletedImages = [];
    profileImageFiles.clear();
    profileScrollController.dispose();
    profileCountryController.dispose();
    profileStateController.dispose();
    profileCityController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    mobileNumberController.dispose();
    genderController.dispose();
    dobController.dispose();
    aboutMeController.dispose();
    clinicNameController.dispose();
    clinicAddressController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    specialitiesServices.dispose();
    speciality.dispose();
    if (educationController.isNotEmpty) {
      for (var map in educationController) {
        for (var entry in map.entries) {
          entry.value.dispose();
        }
      }
      educationController.clear();
    }
    if (experinceController.isNotEmpty) {
      for (var map in experinceController) {
        for (var entry in map.entries) {
          entry.value.dispose();
        }
      }
      experinceController.clear();
    }
    if (awardController.isNotEmpty) {
      for (var map in awardController) {
        for (var entry in map.entries) {
          entry.value.dispose();
        }
      }
      awardController.clear();
    }
    if (membershipController.isNotEmpty) {
      for (var map in membershipController) {
        for (var entry in map.entries) {
          entry.value.dispose();
        }
      }
      membershipController.clear();
    }
    if (registrationController.isNotEmpty) {
      for (var map in registrationController) {
        for (var entry in map.entries) {
          entry.value.dispose();
        }
      }
      registrationController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;
    final specialities = Provider.of<SpecialitiesProvider>(context).specialities;
    final userData = Provider.of<UserDataProvider>(context).userData;
    DoctorsProfile doctorProfile = widget.doctorProfile;
    late String imageUrl = '';
    if (doctorProfile.userProfile.profileImage.isNotEmpty) {
      imageUrl = doctorProfile.userProfile.profileImage; //?random=${DateTime.now().millisecondsSinceEpoch}
    }

    return ScaffoldWrapper(
      key: const Key('doctor_profile'),
      title: context.tr('doctorProfile'),
      children: NotificationListener(
        onNotification: (notification) {
          double per = 0;
          if (profileScrollController.hasClients) {
            per = ((profileScrollController.offset / profileScrollController.position.maxScrollExtent));
          }
          if (per >= 0) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  scrollPercentage = 307 * per;
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
              controller: profileScrollController,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Form(
                  key: profileFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: FadeinWidget(
                    isCenter: true,
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
                                  child: _profileimageFile == null
                                      ? imageUrl.isEmpty
                                          ? Image.asset(
                                              'assets/images/doctors_profile.jpg',
                                            )
                                          : CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: imageUrl,
                                              fadeInDuration: const Duration(milliseconds: 0),
                                              fadeOutDuration: const Duration(milliseconds: 0),
                                            )
                                      : Image.file(
                                          File(_profileimageFile!.path),
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                ),
                              ),
                              if (_profileimageFile != null) ...[
                                Positioned(
                                  top: 5.0,
                                  left: 7.0,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        profileImageFiles.clear();
                                        _profileimageFile = null;
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
                        const SizedBox(height: 10),
                        //BasicInformation
                        ProfileCardWidget(
                          childrens: [
                            ProfileInputWidget(controller: emailController, readOnly: true, lable: context.tr('email')),
                            ProfileInputWidget(
                              controller: firstNameController,
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
                              controller: lastNameController,
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
                                textFieldController: mobileNumberController,
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
                                    value: genderController.text.isEmpty ? null : genderController.text,
                                    hint: Text(context.tr('gender')),
                                    items: genderValues.map<DropdownMenuItem<String>>((Map<String, dynamic> values) {
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
                                        genderController.text = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            ProfileInputWidget(
                              controller: dobController,
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
                                String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate!);

                                setState(() {
                                  dobController.text = formattedDate;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                          listTitle: context.tr('basicInfo'),
                        ),
                        const SizedBox(height: 30),
                        //aboutme
                        ProfileCardWidget(
                          listTitle: context.tr('aboutMe'),
                          childrens: [
                            ProfileInputWidget(
                              controller: aboutMeController,
                              readOnly: false,
                              lable: context.tr('aboutMe'),
                              keyboardType: TextInputType.multiline,
                              minLines: 5,
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        //clinicInfo
                        ProfileCardWidget(
                          listTitle: context.tr('clinicInfo'),
                          childrens: [
                            ProfileInputWidget(controller: clinicNameController, readOnly: false, lable: context.tr('clinicName')),
                            ProfileInputWidget(controller: clinicAddressController, readOnly: false, lable: context.tr('clinicAddress')),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (_clinicXfileFiles.length < 4) {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: ((builder) => bottomSheet('clinicImages', 'chooseClinicPhoto')),
                                    );
                                  }
                                },
                                child: Container(
                                  constraints: const BoxConstraints.expand(height: 100, width: double.infinity),
                                  child: DottedBorder(
                                    dashPattern: const [8, 4],
                                    strokeWidth: 2,
                                    color: _clinicXfileFiles.length < 4
                                        ? hexToColor(
                                            secondaryDarkColorCodeReturn(homeThemeName),
                                          )
                                        : Theme.of(context).disabledColor,
                                    padding: const EdgeInsets.all(8),
                                    borderPadding: const EdgeInsets.all(4),
                                    child: Center(
                                      child: Text(
                                        context.tr('max4File'),
                                        style: TextStyle(
                                          color: _clinicXfileFiles.length < 4
                                              ? brightness == Brightness.dark
                                                  ? Colors.white
                                                  : Colors.blue
                                              : Theme.of(context).disabledColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_clinicXfileFiles.isNotEmpty) ...[
                              CarouselSlider(
                                  options: CarouselOptions(
                                    height: 190.0,
                                    autoPlay: false,
                                    enlargeCenterPage: true,
                                  ),
                                  items: _clinicXfileFiles.map((image) {
                                    var index = _clinicXfileFiles.indexOf(image);
                                    return Stack(
                                      children: [
                                        SizedBox(
                                          height: 180,
                                          width: 180,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.file(
                                              File(image.path),
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: -10,
                                          right: -10,
                                          child: IconButton(
                                            color: Colors.pinkAccent.shade400,
                                            onPressed: () {
                                              if (clinicImageFiles[index]['src'].startsWith(RegExp(r'^(http|https)://'))) {
                                                setState(() {
                                                  deletedImages.add(clinicImageFiles[index]['random']);
                                                });
                                              }

                                              setState(() {
                                                _clinicXfileFiles.removeAt(index);
                                                clinicImageFiles.removeAt(index);
                                              });
                                            },
                                            icon: const Icon(Icons.delete),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList())
                            ] else ...[
                              const SizedBox(
                                height: 30,
                              )
                            ],
                          ],
                        ),
                        const SizedBox(height: 30),
                        //Contact details
                        ProfileCardWidget(
                          listTitle: context.tr('contactDetails'),
                          childrens: [
                            ProfileInputWidget(controller: address1Controller, readOnly: false, lable: context.tr('address1')),
                            ProfileInputWidget(controller: address2Controller, readOnly: false, lable: context.tr('address2')),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: TypeAheadField<Countries>(
                                  controller: profileCountryController,
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
                                        profileCountryController.text = value;
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
                                                    profileCountryController.text = '';
                                                    profileStateController.text = '';
                                                    profileCityController.text = '';
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
                                    List<InlineSpan> temp = highlightText(profileCountryController.text, country.name,
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
                                    profileCountryController.text = '${country.emoji} - ${country.name}';
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: TypeAheadField<States>(
                                  controller: profileStateController,
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
                                        profileStateController.text = value;
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
                                                    profileStateController.text = '';
                                                    profileCityController.text = '';
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
                                    List<InlineSpan> temp = highlightText(profileStateController.text, state.name,
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
                                    profileStateController.text = '${state.emoji} - ${state.name}';
                                    profileCountryController.text = '${state.emoji} - ${state.countryName}';
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: TypeAheadField<Cities>(
                                  controller: profileCityController,
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
                                        profileCityController.text = value;
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
                                                    profileCityController.text = '';
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
                                    List<InlineSpan> temp = highlightText(profileCityController.text, city.name,
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

                                    profileStateController.text = '${city.emoji} - ${city.stateName}';
                                    profileCountryController.text = '${city.emoji} - ${city.countryName}';
                                    profileCityController.text = '${city.emoji} - ${city.name}';
                                  },
                                ),
                              ),
                            ),
                            ProfileInputWidget(
                              controller: zipCodeController,
                              readOnly: false,
                              lable: context.tr('zipCode'),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        //ServicesandSpecialization
                        ProfileCardWidget(
                          listTitle: context.tr('servicesAndSpecialization'),
                          childrens: [
                            if (doctorProfile.userProfile.specialitiesServices!.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5.0,
                                    foregroundColor: Theme.of(context).primaryColorLight,
                                    animationDuration: const Duration(milliseconds: 1000),
                                    backgroundColor: Theme.of(context).primaryColorLight,
                                    shadowColor: Theme.of(context).primaryColorLight,
                                  ),
                                  onPressed: () {
                                    specialitiesServices.clearTags();
                                    // doctorProfile.userProfile.specialitiesServices!.clear();
                                  },
                                  child: Text(
                                    context.tr('clearTags'),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: TextFieldTags<String>(
                                textfieldTagsController: specialitiesServices,
                                initialTags: doctorProfile.userProfile.specialitiesServices,
                                // textSeparators: const [ ' '],
                                //For empty tag error
                                validator: (tag) {
                                  return null;
                                },
                                letterCase: LetterCase.normal,
                                inputFieldBuilder: (context, inputFieldValues) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: TextField(
                                      maxLength: 100,
                                      textAlignVertical: TextAlignVertical.top,
                                      onTapOutside: (event) {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                      },
                                      onEditingComplete: () {},
                                      textInputAction: TextInputAction.send,
                                      onTap: () {
                                        specialitiesServices.getFocusNode?.requestFocus();
                                      },
                                      controller: inputFieldValues.textEditingController,
                                      focusNode: inputFieldValues.focusNode,
                                      decoration: InputDecoration(
                                        counterStyle: TextStyle(color: Theme.of(context).primaryColorLight),
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
                                        labelStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        isDense: true,
                                        // helperText: context.tr('Type&Press'),
                                        helperStyle: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        label: Text(context.tr('pressForNewTag')),
                                        floatingLabelBehavior:
                                            inputFieldValues.tags.isNotEmpty ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto,
                                        errorText: specialitiesServices.getTags!.isEmpty ? context.tr('required') : null,
                                        prefixIcon: inputFieldValues.tags.isNotEmpty
                                            ? SingleChildScrollView(
                                                controller: inputFieldValues.tagScrollController,
                                                scrollDirection: Axis.vertical,
                                                child: SizedBox(
                                                  width: MediaQuery.of(context).size.width / 2,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(
                                                      top: 8,
                                                      bottom: 8,
                                                      left: 8,
                                                    ),
                                                    child: Wrap(
                                                        runSpacing: 4.0,
                                                        spacing: 4.0,
                                                        direction: Axis.horizontal,
                                                        children: inputFieldValues.tags.map((String tag) {
                                                          return Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: const BorderRadius.all(
                                                                Radius.circular(20.0),
                                                              ),
                                                              color: brightness == Brightness.dark ? Colors.black : Colors.white,
                                                            ),
                                                            margin: const EdgeInsets.symmetric(
                                                              horizontal: 5.0,
                                                            ),
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Flexible(
                                                                  fit: FlexFit.loose,
                                                                  child: InkWell(
                                                                    child: Text(
                                                                      tag,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      maxLines: 10,
                                                                      softWrap: true,
                                                                      style: TextStyle(
                                                                        color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                                                      ),
                                                                    ),
                                                                    onTap: () {},
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4.0,
                                                                ),
                                                                InkWell(
                                                                  child: Icon(
                                                                    Icons.cancel,
                                                                    size: 14.0,
                                                                    color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                                                  ),
                                                                  onTap: () {
                                                                    inputFieldValues.onTagRemoved(
                                                                      tag,
                                                                    );
                                                                    // doctorProfile.userProfile.specialitiesServices!.remove(tag);
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        }).toList()),
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      onChanged: (value) {
                                        inputFieldValues.onTagChanged(value);
                                      },
                                      onSubmitted: (value) {
                                        // doctorProfile.userProfile.specialitiesServices!.add(value);
                                        inputFieldValues.onTagSubmitted(value);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (specialities.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButtonFormField<String>(
                                  decoration: decoration(context, context.tr('speciality')),
                                  isDense: true,
                                  validator: (value) => value == null ? context.tr('required') : null,
                                  value: speciality.text.isEmpty ? null : speciality.text,
                                  hint: Text(context.tr('speciality')),
                                  items: specialities.map<DropdownMenuItem<String>>((Specialities values) {
                                    final name = context.tr(values.specialities);
                                    final imageSrc = values.image;
                                    final imageIsSvg = imageSrc.endsWith('.svg');
                                    return DropdownMenuItem<String>(
                                      value: values.specialities,
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 12.0,
                                            ),
                                            child: imageIsSvg
                                                ? SvgPicture.network(
                                                    imageSrc, //?random=${DateTime.now().millisecondsSinceEpoch}
                                                    width: 20,
                                                    height: 20,
                                                    fit: BoxFit.fitHeight,
                                                  )
                                                : Image.network(
                                                    imageSrc, //?random=${DateTime.now().millisecondsSinceEpoch}
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            name,
                                            style: TextStyle(color: brightness == Brightness.dark ? Colors.white : Colors.black),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    var index = specialities.indexWhere((map) => map.specialities == newValue);
                                    setState(() {
                                      specialityValue.clear();
                                      specialityValue.add(specialities[index]);
                                      speciality.text = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 30),
                        //Educations
                        ProfileCardWidget(
                          listTitle: context.tr('educations'),
                          childrens: [
                            if (educationController.isNotEmpty) ...[
                              ...educationController.map((map) {
                                var index = educationController.indexOf(map);
                                return Card(
                                  elevation: 12,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      for (var entry in map.entries) ...[
                                        entry.key != 'yearOfCompletion'
                                            ? ProfileInputWidget(
                                                controller: entry.value,
                                                readOnly: false,
                                                lable: context.tr(entry.key),
                                                validator: ((value) {
                                                  if (value == null || value.isEmpty) {
                                                    return context.tr('${entry.key}Required');
                                                  }
                                                  return null;
                                                }),
                                              )
                                            : ProfileInputWidget(
                                                controller: entry.value,
                                                readOnly: false,
                                                lable: context.tr(entry.key),
                                                validator: ((value) {
                                                  if (value == null || value.isEmpty) {
                                                    return context.tr('${entry.key}Required');
                                                  }
                                                  return null;
                                                }),
                                                keyboardType: TextInputType.none,
                                                onTap: () async {
                                                  DateTime? pickedDate = await showDatePicker(
                                                      initialDatePickerMode: DatePickerMode.year,
                                                      context: context,
                                                      initialDate: DateTime.now(),
                                                      firstDate: DateTime(1924),
                                                      lastDate: DateTime.now());
                                                  String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate!);

                                                  setState(() {
                                                    entry.value.text = formattedDate;
                                                  });
                                                },
                                              ),
                                      ],
                                      IconButton(
                                        color: Colors.pinkAccent.shade400,
                                        onPressed: () {
                                          setState(() {
                                            educationController.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            if (educationController.length < 5) ...[
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).primaryColorLight,
                                ),
                                onPressed: () {
                                  setState(() {
                                    educationController.add({
                                      "collage": TextEditingController(),
                                      "degree": TextEditingController(),
                                      "yearOfCompletion": TextEditingController(),
                                    });
                                  });
                                },
                                icon: FaIcon(FontAwesomeIcons.plusCircle, color: Theme.of(context).primaryColorLight),
                                label: Text(context.tr('addMore')),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 30),
                        //Experinces
                        ProfileCardWidget(
                          listTitle: context.tr('experinces'),
                          childrens: [
                            if (experinceController.isNotEmpty) ...[
                              ...experinceController.map((map) {
                                var index = experinceController.indexOf(map);
                                return Card(
                                  elevation: 12,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ...map.entries.map(
                                        (entry) {
                                          return entry.key != 'from' && entry.key != 'to'
                                              ? ProfileInputWidget(
                                                  controller: entry.value,
                                                  readOnly: false,
                                                  lable: context.tr(entry.key),
                                                  validator: ((value) {
                                                    if (value == null || value.isEmpty) {
                                                      return context.tr('${entry.key}Required');
                                                    }
                                                    return null;
                                                  }),
                                                )
                                              : ProfileInputWidget(
                                                  controller: entry.value,
                                                  readOnly: false,
                                                  lable: context.tr(entry.key),
                                                  validator: ((value) {
                                                    if (value == null || value.isEmpty) {
                                                      return context.tr('${entry.key}Required');
                                                    }
                                                    return null;
                                                  }),
                                                  suffixIcon: entry.value.text.isEmpty
                                                      ? null
                                                      : IconButton(
                                                          splashColor: Colors.transparent,
                                                          highlightColor: Colors.transparent,
                                                          onPressed: () {
                                                            if (entry.key == 'to') {
                                                              setState(() {
                                                                entry.value.text = '';
                                                              });
                                                            }
                                                            if (entry.key == 'from') {
                                                              experienceToDate[index][0] = 1934;
                                                              experienceToDate[index][1] = 1;
                                                              experienceToDate[index][2] = 1;
                                                              setState(() {
                                                                entry.value.text = '';
                                                              });
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons.close,
                                                            color: Theme.of(context).primaryColorLight,
                                                          ),
                                                        ),
                                                  keyboardType: TextInputType.none,
                                                  onTap: () async {
                                                    if (entry.key == 'from') {
                                                      int endFromYear = DateTime.now().year;
                                                      int endFromMonth = DateTime.now().month;
                                                      int endFromDay = DateTime.now().day;
                                                      if (experinceController[index]['to']!.text.isNotEmpty) {
                                                        DateFormat inputFormat = DateFormat("dd MMM yyyy");
                                                        DateTime dateTime = inputFormat.parse(experinceController[index]['to']!.text);
                                                        endFromYear = dateTime.year;
                                                        endFromMonth = dateTime.month;
                                                        endFromDay = dateTime.day;
                                                      }
                                                      DateTime? fromDate = await showDatePicker(
                                                          initialDatePickerMode: DatePickerMode.year,
                                                          context: context,
                                                          firstDate: DateTime(experienceFromDate[index].first, experienceFromDate[index][1],
                                                              experienceFromDate[index][2]),
                                                          lastDate: DateTime(endFromYear, endFromMonth, endFromDay));
                                                      String formattedDate = DateFormat('dd MMM yyyy').format(fromDate!);
                                                      experienceToDate[index][0] = fromDate.year;
                                                      experienceToDate[index][1] = fromDate.month;
                                                      experienceToDate[index][2] = fromDate.day;
                                                      setState(() {
                                                        entry.value.text = formattedDate;
                                                      });
                                                    } else {
                                                      DateTime? toDate = await showDatePicker(
                                                          initialDatePickerMode: DatePickerMode.year,
                                                          context: context,
                                                          firstDate: DateTime(
                                                              experienceToDate[index].first, experienceToDate[index][1], experienceToDate[index][2]),
                                                          lastDate: DateTime.now());

                                                      String formattedDate = DateFormat('dd MMM yyyy').format(toDate!);
                                                      setState(() {
                                                        entry.value.text = formattedDate;
                                                      });
                                                    }
                                                  },
                                                );
                                        },
                                      ),
                                      // for (var entry in map.entries) ...[
                                      //  ],
                                      IconButton(
                                        color: Colors.pinkAccent.shade400,
                                        onPressed: () {
                                          setState(() {
                                            experinceController.removeAt(index);
                                            experienceToDate.removeAt(index);
                                            experienceFromDate.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            if (experinceController.length < 5) ...[
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).primaryColorLight,
                                ),
                                onPressed: () {
                                  setState(() {
                                    experinceController.add({
                                      "hospitalName": TextEditingController(),
                                      "from": TextEditingController(),
                                      "to": TextEditingController(),
                                      "designation": TextEditingController(),
                                    });
                                    experienceToDate.add([1934, 1, 1]);
                                    experienceFromDate.add([1934, 1, 1]);
                                  });
                                },
                                icon: FaIcon(FontAwesomeIcons.plusCircle, color: Theme.of(context).primaryColorLight),
                                label: Text(context.tr('addMore')),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 30),
                        //Awards
                        ProfileCardWidget(
                          childrens: [
                            if (awardController.isNotEmpty) ...[
                              ...awardController.map((map) {
                                var index = awardController.indexOf(map);
                                return Card(
                                  elevation: 12,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      for (var entry in map.entries) ...[
                                        entry.key != 'year'
                                            ? ProfileInputWidget(
                                                controller: entry.value,
                                                readOnly: false,
                                                lable: context.tr(entry.key),
                                                validator: ((value) {
                                                  if (value == null || value.isEmpty) {
                                                    return context.tr('${entry.key}Required');
                                                  }
                                                  return null;
                                                }),
                                              )
                                            : ProfileInputWidget(
                                                controller: entry.value,
                                                readOnly: false,
                                                lable: context.tr(entry.key),
                                                validator: ((value) {
                                                  if (value == null || value.isEmpty) {
                                                    return context.tr('${entry.key}Required');
                                                  }
                                                  return null;
                                                }),
                                                keyboardType: TextInputType.none,
                                                onTap: () async {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(context.tr('selectYear')),
                                                        content: SizedBox(
                                                          width: MediaQuery.of(context).size.width,
                                                          height: 300,
                                                          child: YearPicker(
                                                            firstDate: DateTime(DateTime.now().year - 100, 1),
                                                            lastDate: DateTime(DateTime.now().year, 1),
                                                            selectedDate: DateTime.now(),
                                                            onChanged: (DateTime dateTime) {
                                                              Navigator.pop(context);
                                                              setState(() {
                                                                entry.value.text = dateTime.year.toString();
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                      ],
                                      IconButton(
                                        color: Colors.pinkAccent.shade400,
                                        onPressed: () {
                                          setState(() {
                                            awardController.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            if (awardController.length < 5) ...[
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).primaryColorLight,
                                ),
                                onPressed: () {
                                  setState(() {
                                    awardController.add({
                                      "award": TextEditingController(),
                                      "year": TextEditingController(),
                                    });
                                  });
                                },
                                icon: FaIcon(FontAwesomeIcons.plusCircle, color: Theme.of(context).primaryColorLight),
                                label: Text(context.tr('addMore')),
                              ),
                            ]
                          ],
                          listTitle: context.tr('awards'),
                        ),
                        const SizedBox(height: 30),
                        //Membership
                        ProfileCardWidget(
                          listTitle: context.tr('memberships'),
                          childrens: [
                            if (membershipController.isNotEmpty) ...[
                              ...membershipController.map((map) {
                                var index = membershipController.indexOf(map);
                                return Card(
                                  elevation: 12,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      for (var entry in map.entries) ...[
                                        ProfileInputWidget(
                                          controller: entry.value,
                                          readOnly: false,
                                          lable: context.tr(entry.key),
                                          validator: ((value) {
                                            if (value == null || value.isEmpty) {
                                              return context.tr('${entry.key}Required');
                                            }
                                            return null;
                                          }),
                                        )
                                      ],
                                      IconButton(
                                        color: Colors.pinkAccent.shade400,
                                        onPressed: () {
                                          setState(() {
                                            membershipController.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            if (membershipController.length < 5) ...[
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).primaryColorLight,
                                ),
                                onPressed: () {
                                  setState(() {
                                    membershipController.add({
                                      "membership": TextEditingController(),
                                    });
                                  });
                                },
                                icon: FaIcon(FontAwesomeIcons.plusCircle, color: Theme.of(context).primaryColorLight),
                                label: Text(context.tr('addMore')),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 30),
                        //Registrations
                        ProfileCardWidget(
                          childrens: [
                            if (registrationController.isNotEmpty) ...[
                              ...registrationController.map((map) {
                                var index = registrationController.indexOf(map);
                                return Card(
                                  elevation: 12,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      for (var entry in map.entries) ...[
                                        entry.key != 'year'
                                            ? ProfileInputWidget(
                                                controller: entry.value,
                                                readOnly: false,
                                                lable: context.tr(entry.key),
                                                validator: ((value) {
                                                  if (value == null || value.isEmpty) {
                                                    return context.tr('${entry.key}Required');
                                                  }
                                                  return null;
                                                }),
                                              )
                                            : ProfileInputWidget(
                                                controller: entry.value,
                                                readOnly: false,
                                                lable: context.tr(entry.key),
                                                validator: ((value) {
                                                  if (value == null || value.isEmpty) {
                                                    return context.tr('${entry.key}Required');
                                                  }
                                                  return null;
                                                }),
                                                keyboardType: TextInputType.none,
                                                onTap: () async {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(context.tr('selectYear')),
                                                        content: SizedBox(
                                                          width: MediaQuery.of(context).size.width,
                                                          height: 300,
                                                          child: YearPicker(
                                                            firstDate: DateTime(DateTime.now().year - 100, 1),
                                                            lastDate: DateTime(DateTime.now().year, 1),
                                                            selectedDate: DateTime.now(),
                                                            onChanged: (DateTime dateTime) {
                                                              Navigator.pop(context);
                                                              setState(() {
                                                                entry.value.text = dateTime.year.toString();
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                      ],
                                      IconButton(
                                        color: Colors.pinkAccent.shade400,
                                        onPressed: () {
                                          setState(() {
                                            registrationController.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            if (registrationController.length < 5) ...[
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).primaryColorLight,
                                ),
                                onPressed: () {
                                  setState(() {
                                    registrationController.add({
                                      "registration": TextEditingController(),
                                      "year": TextEditingController(),
                                    });
                                  });
                                },
                                icon: FaIcon(FontAwesomeIcons.plusCircle, color: Theme.of(context).primaryColorLight),
                                label: Text(context.tr('addMore')),
                              ),
                            ]
                          ],
                          listTitle: context.tr('registrations'),
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
            ScrollButton(scrollController: profileScrollController, scrollPercentage: scrollPercentage)
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
                  case "clinicImages":
                    takePhotoForClinic(ImageSource.camera);
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
                  case "clinicImages":
                    Navigator.of(context).maybePop();
                    clinicSelectorGallery();
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
          profileImageFiles = [
            {
              "profileImage": File(element.path!),
              "profileImageName": element.name,
              "profileImageExtentionNoDot": element.name.split('.').last,
            }
          ];
          _profileimageFile = image.xFiles.first as XFile?;
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

  Future clinicSelectorGallery() async {
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
    FilePickerResult? images = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      withData: false,
      withReadStream: true,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
      ],
    );
    int totalClinicImages = _clinicXfileFiles.length;
    if (images != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
      for (var i = 0; i < images.files.length; i++) {
        var element = images.files[i];
        if (element.size < 2000000) {
          totalClinicImages++;
          if (totalClinicImages <= 4) {
            _clinicXfileFiles = [..._clinicXfileFiles, images.xFiles[i]];
            File fileFromImage = File(element.path!);
            var decodedImage = await decodeImageFromList(fileFromImage.readAsBytesSync());

            setState(() {
              clinicImageFiles = [
                ...clinicImageFiles,
                {
                  "src": element.path,
                  "width": decodedImage.width,
                  "height": decodedImage.height,
                  "isSelected": false,
                  "name": element.name,
                  "random": generateRandomString(19),
                  "tags": [
                    {"value": "value", "title": element.name}
                  ]
                }
              ];
            });
          } else {
            if (mounted) {
              showToast(
                context,
                Toast(
                  title: 'Failed',
                  description: context.tr('max4FileExtend'),
                  duration: Duration(milliseconds: 200.toInt()),
                  lifeTime: Duration(
                    milliseconds: 2500.toInt(),
                  ),
                ),
              );
            }
          }
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
      }
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
    }
  }

  void takePhotoForClinic(ImageSource source) async {
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
    final pickedFile = await _profileImagePicker.pickImage(
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
        if (_clinicXfileFiles.length < 4) {
          File fileFromImage = File(pickedFile.path); // Or any other way to get a File instance.
          var decodedImage = await decodeImageFromList(fileFromImage.readAsBytesSync());
          _clinicXfileFiles = [..._clinicXfileFiles, pickedFile];
          clinicImageFiles = [
            ...clinicImageFiles,
            {
              // "src": File(pickedFile.path),
              "src": pickedFile.path,
              "width": decodedImage.width,
              "height": decodedImage.height,
              "isSelected": false,
              "name": pickedFile.name,
              "random": generateRandomString(19),
              "tags": [
                {"value": "value", "title": pickedFile.name}
              ]
            }
          ];
          setState(() {
            clinicImageFiles = clinicImageFiles;
          });
        } else {
          if (mounted) {
            showToast(
              context,
              Toast(
                title: 'Failed',
                description: context.tr('max4FileExtend'),
                duration: Duration(milliseconds: 200.toInt()),
                lifeTime: Duration(
                  milliseconds: 2500.toInt(),
                ),
              ),
            );
          }
        }
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
    final pickedFile = await _profileImagePicker.pickImage(
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
          profileImageFiles = [
            {
              "profileImage": File(pickedFile.path),
              "profileImageName": pickedFile.name,
              "profileImageExtentionNoDot": pickedFile.name.split('.').last,
            }
          ];
          _profileimageFile = pickedFile;
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
