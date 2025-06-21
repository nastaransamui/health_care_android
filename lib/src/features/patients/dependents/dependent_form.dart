import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/dependents.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/features/patients/dependents/dependent_file_upload_input.dart';
import 'package:health_care/src/features/patients/dependents/dependent_is_active_radio_group.dart';
import 'package:health_care/src/features/patients/dependents/dependent_select_widget.dart';
import 'package:health_care/src/features/patients/dependents/dependent_text_input.dart';
import 'package:image_picker/image_picker.dart';

class DependentForm extends StatefulWidget {
  final Dependents dependent;
  const DependentForm({
    super.key,
    required this.dependent,
  });

  @override
  State<DependentForm> createState() => _DependentFormState();
}

class _DependentFormState extends State<DependentForm> {
  final ScrollController scrollController = ScrollController();
  final dependentFormKey = GlobalKey<FormBuilderState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController fileNameController;
  late TextEditingController genderController;
  late TextEditingController bloodGController;
  bool isActive = true;
  XFile? _dependentProfileimageFile;
  final ImagePicker _documentImagePicker = ImagePicker();
  List<Map<String, dynamic>> profileImageFiles = [];
  static const List<Map<String, dynamic>> patientGenderValues = [
    {"title": 'Mr', 'icon': '👨'},
    {"title": 'Mrs', 'icon': '👩'},
    {"title": 'Mss', 'icon': '👩'},
  ];

  @override
  void initState() {
    super.initState();
    isActive = widget.dependent.isActive;
    firstNameController = TextEditingController(text: widget.dependent.firstName);
    lastNameController = TextEditingController(text: widget.dependent.lastName);
    genderController = TextEditingController(text: widget.dependent.gender);
    bloodGController = TextEditingController(text: widget.dependent.bloodG);
    fileNameController = TextEditingController(text: '');
    firstNameController.addListener(() => setState(() {}));
    lastNameController.addListener(() => setState(() {}));
    genderController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    firstNameController.removeListener(() {});
    lastNameController.removeListener(() {});
    genderController.removeListener(() {});
    scrollController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    fileNameController.dispose();
    genderController.dispose();
    bloodGController.dispose();
    _dependentProfileimageFile = null;
    profileImageFiles.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Dependents dependent = widget.dependent;
    final String formType = dependent.id!.isEmpty ? 'create' : 'edit';
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: _dependentProfileimageFile != null
                    ? FileImage(File(_dependentProfileimageFile!.path))
                    : (dependent.profileImage.isNotEmpty
                        ? CachedNetworkImageProvider(dependent.profileImage)
                        : const AssetImage('assets/images/default-avatar.png') as ImageProvider),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${genderController.text} ${firstNameController.text} ${lastNameController.text}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FormBuilder(
              key: dependentFormKey,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: theme.primaryColor),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormBuilderField<bool>(
                        name: 'isActive',
                        initialValue: isActive,
                        builder: (field) {
                          return DependentIsActiveRadioGroup(
                            value: field.value,
                            theme: Theme.of(context),
                            showLabel: true,
                            name: 'isActive',
                            onChanged: (val) {
                              setState(() {
                                isActive = val!;
                              });
                              field.didChange(val); // updates the FormBuilder form state
                            },
                          );
                        },
                      ),
                      DependentTextInput(
                        dependent: dependent,
                        theme: theme,
                        textColor: textColor,
                        name: 'firstName',
                        controller: firstNameController,
                      ),
                      DependentTextInput(
                        dependent: dependent,
                        theme: theme,
                        textColor: textColor,
                        name: 'lastName',
                        controller: lastNameController,
                      ),
                      DependentTextInput(
                        dependent: dependent,
                        theme: theme,
                        textColor: textColor,
                        name: 'relationShip',
                      ),
                      DependentSelectWidget(
                        controller: genderController,
                        theme: theme,
                        textColor: textColor,
                        name: 'gender',
                        valueArray: patientGenderValues,
                      ),
                      DependentSelectWidget(
                        controller: bloodGController,
                        theme: theme,
                        textColor: textColor,
                        name: 'bloodG',
                        valueArray: bloodGValues,
                      ),
                      DependentTextInput(
                        dependent: dependent,
                        theme: theme,
                        textColor: textColor,
                        name: 'dob',
                      ),
                      DependentTextInput(
                        dependent: dependent,
                        theme: theme,
                        textColor: textColor,
                        name: 'createdAt',
                      ),
                      DependentTextInput(
                        dependent: dependent,
                        theme: theme,
                        textColor: textColor,
                        name: 'updateAt',
                      ),
                      DependentFileUploadInput(
                        dependent: dependent,
                        theme: theme,
                        textColor: textColor,
                        name: 'profileImage',
                        controller: fileNameController,
                        documentXFile: _dependentProfileimageFile,
                        onUploadTap: () {
                          setState(() {
                            profileImageFiles.clear();
                            _dependentProfileimageFile = null;
                          });
                          showModalBottomSheet(
                            context: context,
                            builder: ((builder) => bottomSheet('profileImage', 'chooseProfilePhoto')),
                          );
                        },
                        onDeleteTap: () {
                          setState(() {
                            profileImageFiles.clear();
                            _dependentProfileimageFile = null;
                            fileNameController.text = '';
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 35,
                          child: GradientButton(
                            onPressed: () async {
                              final isValid = dependentFormKey.currentState?.saveAndValidate() ?? false;

                              if (!isValid) {
                                return;
                              }
                              final formData = dependentFormKey.currentState!.value;

                              if (dependentFormKey.currentState!.validate()) {
                                if (profileImageFiles.isNotEmpty) {
                                  for (var i = 0; i < profileImageFiles.length; i++) {
                                    var element = profileImageFiles[i];
                                    final fileFromImage = profileImageFiles[i]['profileImage'];
                                    List<int> fileBytes = await fileFromImage.readAsBytes();
                                    Uint8List fileUint8List = Uint8List.fromList(fileBytes);
                                    profileImageFiles = [
                                      {
                                        'profileImage': fileUint8List,
                                        'profileImageName': element['profileImageName'],
                                        'profileImageExtentionNoDot': element['profileImageExtentionNoDot']
                                      }
                                    ];
                                  }
                                }
                                final originalDateStr = formData['dob'];

                                String? isoUtc;
                                if (originalDateStr != null && originalDateStr.trim().isNotEmpty) {
                                  try {
                                    final inputFormat = DateFormat('dd MMM yyyy');
                                    final localDateTime = inputFormat.parse(originalDateStr);
                                    final utcDate = DateTime.utc(localDateTime.year, localDateTime.month, localDateTime.day);

                                    isoUtc = utcDate.toIso8601String();
                                  } catch (e) {
                                    // Optional: log or handle parsing error
                                    isoUtc = null;
                                  }
                                } else {
                                  isoUtc = null;
                                }
                                final payload = {
                                  if (formType != 'create') '_id': dependent.id,
                                  "userId": dependent.userId,
                                  "firstName": firstNameController.text,
                                  "lastName": lastNameController.text,
                                  "dob": isoUtc ?? '',
                                  "bloodG": bloodGController.text,
                                  "profileImage": dependent.profileImage,
                                  "gender": genderController.text,
                                  "isActive": formData['isActive'],
                                  "relationShip": formData['relationShip'],
                                  "medicalRecordsArray": dependent.medicalRecordsArray,
                                  "fullName": "${firstNameController.text} ${lastNameController.text}",
                                  "id": dependent.dependentId,
                                  if (formType != 'create') "createdAt": dependent.createdAt.toIso8601String(),
                                  "profileImageFiles": profileImageFiles,
                                };
                                log('$payload');
                                if (context.mounted) {
                                  Navigator.pop(context, payload);
                                }
                              }
                            },
                            colors: [
                              Theme.of(context).primaryColorLight,
                              Theme.of(context).primaryColor,
                            ],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
          ),
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
        'png',
        'jpg',
        'jpeg',
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
          fileNameController.text = element.name;
          _dependentProfileimageFile = image.xFiles.first as XFile?;
        });
      } else {
        if (mounted) {
          showErrorSnackBar(context, context.tr('imageSizeExtend'));
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
    final pickedFile = await _documentImagePicker.pickImage(
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
          fileNameController.text = pickedFile.name;
          _dependentProfileimageFile = pickedFile;
        });
      } else {
        if (mounted) {
          showErrorSnackBar(context, context.tr('imageSizeExtend'));
        }
      }
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
    }
  }
}
