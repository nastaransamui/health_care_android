import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:health_care/models/dependents.dart';
import 'package:health_care/models/medical_records.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/src/features/patients/medicalRecords/file_upload_input.dart';
import 'package:health_care/src/features/patients/medicalRecords/is_for_dependent_radio_group.dart';
import 'package:health_care/src/features/patients/medicalRecords/text_input.dart';
import 'package:image_picker/image_picker.dart';

class MedicalRecordForm extends StatefulWidget {
  final String formType;
  final MedicalRecords medicalRecord;
  final List<Dependents> dependents;
  const MedicalRecordForm({
    super.key,
    required this.formType,
    required this.medicalRecord,
    required this.dependents,
  });

  @override
  State<MedicalRecordForm> createState() => _MedicalRecordFormState();
}

class _MedicalRecordFormState extends State<MedicalRecordForm> {
  final ScrollController scrollController = ScrollController();
  final medicalRecordFormKey = GlobalKey<FormBuilderState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController fileNameController;
  bool isForDependentValue = false;
  XFile? _documentXFile;
  final ImagePicker _documentImagePicker = ImagePicker();
  List<Map<String, dynamic>> documentFileList = [];

  @override
  void dispose() {
    scrollController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    fileNameController.dispose();
    _documentXFile = null;
    documentFileList.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isForDependentValue = widget.medicalRecord.isForDependent;
    firstNameController = TextEditingController(text: widget.medicalRecord.firstName);
    lastNameController = TextEditingController(text: widget.medicalRecord.lastName);
    fileNameController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    final String formType = widget.formType;
    final MedicalRecords medicalRecord = widget.medicalRecord;
    final List<Dependents> dependents = widget.dependents;
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return ScaffoldWrapper(
      title: context.tr('${formType}_medicalRecord'),
      children: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FormBuilder(
                key: medicalRecordFormKey,
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
                          name: 'isForDependent',
                          initialValue: isForDependentValue,
                          builder: (field) {
                            return IsForDependentRadioGroup(
                              value: field.value,
                              isView: formType == 'view' || dependents.isEmpty,
                              theme: Theme.of(context),
                              showLabel: true,
                              name: 'isForDependent',
                              onChanged: (val) {
                                setState(() {
                                  isForDependentValue = val!; // updates the local state
                                });
                                if (!val!) {
                                  firstNameController.text = widget.medicalRecord.firstName;
                                  lastNameController.text = widget.medicalRecord.lastName;
                                }
                                field.didChange(val); // updates the FormBuilder form state
                              },
                            );
                          },
                        ),
                        TextInput(
                          medicalRecord: medicalRecord,
                          formType: formType,
                          theme: theme,
                          textColor: textColor,
                          name: 'firstName',
                          isForDependentValue: isForDependentValue,
                          controller: firstNameController,
                        ),
                        TextInput(
                          medicalRecord: medicalRecord,
                          formType: formType,
                          theme: theme,
                          textColor: textColor,
                          name: 'lastName',
                          isForDependentValue: isForDependentValue,
                          controller: lastNameController,
                        ),
                        if (isForDependentValue) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: formType == 'view'
                                ? TextField(
                                    enabled: false,
                                    decoration: InputDecoration(
                                      floatingLabelStyle: TextStyle(color: Theme.of(context).disabledColor),
                                      labelStyle: TextStyle(color: Theme.of(context).disabledColor),
                                      label: RichText(
                                        text: TextSpan(
                                          text: context.tr('dependant'),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Theme.of(context).disabledColor,
                                              ),
                                        ),
                                      ),
                                      hintText: context.tr('dependant'),
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
                                  )
                                : FormBuilderDropdown<String>(
                                    name: 'dependentId',
                                    enabled: formType != 'view',
                                    validator: formType != 'view' || isForDependentValue
                                        ? (fieldValue) {
                                            if (fieldValue == null) {
                                              return context.tr('required');
                                            }
                                            return null;
                                          }
                                        : null,
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(color: Colors.redAccent.shade400),
                                      floatingLabelStyle: TextStyle(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight),
                                      labelStyle: TextStyle(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight),
                                      // labelText: context.tr(key),
                                      label: RichText(
                                        text: TextSpan(
                                          text: context.tr('selectDependent'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: formType == 'view' ? theme.disabledColor : textColor),
                                          children: const [
                                            TextSpan(
                                              text: ' *',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                      hintText: context.tr('selectDependent'),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight, width: 1),
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
                                      // prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
                                      isDense: true,
                                      alignLabelWithHint: false,
                                    ),
                                    items: dependents.map((dependent) {
                                      return DropdownMenuItem<String>(
                                        value: '${dependent.id}',
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(color: theme.primaryColorLight),
                                                shape: BoxShape.rectangle,
                                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                                image: DecorationImage(
                                                    fit: BoxFit.contain,
                                                    image: dependent.profileImage.isEmpty
                                                        ? const AssetImage('assets/images/default-avatar.png') as ImageProvider
                                                        : CachedNetworkImageProvider(dependent.profileImage)),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(dependent.fullName)
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    selectedItemBuilder: (context) {
                                      return dependents.map((dependent) {
                                        return Text('${dependent.dependentId}');
                                      }).toList();
                                    },
                                    onChanged: (selectedId) {
                                      final selected = dependents.firstWhere((d) => d.id == selectedId);
                                      firstNameController.text = selected.firstName;
                                      lastNameController.text = selected.lastName;
                                      medicalRecordFormKey.currentState!.fields['firstName']?.didChange(selected.firstName);
                                      medicalRecordFormKey.currentState!.fields['lastName']?.didChange(selected.lastName);
                                      medicalRecordFormKey.currentState!.fields['dependentId']?.didChange(selectedId);
                                    },
                                  ),
                          ),
                        ],
                        TextInput(
                          medicalRecord: medicalRecord,
                          formType: formType,
                          theme: theme,
                          textColor: textColor,
                          name: 'hospitalName',
                          isForDependentValue: isForDependentValue,
                        ),
                        TextInput(
                          medicalRecord: medicalRecord,
                          formType: formType,
                          theme: theme,
                          textColor: textColor,
                          name: 'date',
                          isForDependentValue: isForDependentValue,
                        ),
                        TextInput(
                          medicalRecord: medicalRecord,
                          formType: formType,
                          theme: theme,
                          textColor: textColor,
                          name: 'symptoms',
                          isForDependentValue: isForDependentValue,
                        ),
                        TextInput(
                          medicalRecord: medicalRecord,
                          formType: formType,
                          theme: theme,
                          textColor: textColor,
                          name: 'description',
                          isForDependentValue: isForDependentValue,
                        ),
                        FileUploadInput(
                          medicalRecord: medicalRecord,
                          formType: formType,
                          theme: theme,
                          textColor: textColor,
                          name: 'documentLink',
                          controller: fileNameController,
                          documentXFile: _documentXFile,
                          onUploadTap: () {
                            if (formType != 'view') {
                              setState(() {
                                documentFileList.clear();
                                _documentXFile = null;
                              });
                              showModalBottomSheet(
                                context: context,
                                builder: ((builder) => bottomSheet('documentFile', 'chooseProfilePhoto')),
                              );
                            }
                          },
                          onDeleteTap: () {
                            setState(() {
                              documentFileList.clear();
                              _documentXFile = null;
                              fileNameController.text = '';
                            });
                          },
                        ),
                        if (formType != 'view') ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 35,
                              child: GradientButton(
                                onPressed: () async {
                                  final isValid = medicalRecordFormKey.currentState?.saveAndValidate() ?? false;

                                  if (!isValid) {
                                    return;
                                  }
                                  final formData = medicalRecordFormKey.currentState!.value;

                                  List<Map<String, dynamic>>? documentFiles = [];
                                  if (medicalRecordFormKey.currentState!.validate()) {
                                    if (documentFileList.isNotEmpty) {
                                      for (var i = 0; i < documentFileList.length; i++) {
                                        var element = documentFileList[i];
                                        final fileFromImage = documentFileList[i]['documentFile'];
                                        List<int> fileBytes = await fileFromImage.readAsBytes();
                                        Uint8List fileUint8List = Uint8List.fromList(fileBytes);
                                        documentFiles = [
                                          {
                                            'document': fileUint8List,
                                            'documentName': element['documentFileName'],
                                            'documentExtentionNoDot': element['documentExtentionNoDot']
                                          }
                                        ];
                                      }
                                    }
                                    final originalDateStr = formData['date'];
                                    final inputFormat = DateFormat('dd MMM yyyy HH:mm');
                                    final localDateTime = inputFormat.parse(originalDateStr);
                                    final isoUtc = localDateTime.toUtc().toIso8601String();
                                    final payload = {
                                      "id": 0,
                                      "firstName": formData['firstName'],
                                      "lastName": formData['lastName'],
                                      "fullName": "",
                                      "dependentId": formData['dependentId'] ?? '',
                                      "userId": widget.medicalRecord.userId,
                                      "date": isoUtc,
                                      "hospitalName": formData['hospitalName'],
                                      "symptoms": formData['symptoms'],
                                      "description": formData['description'],
                                      "documentLink": "",
                                      "isForDependent": formData['isForDependent'],
                                      "documentFiles": documentFiles,
                                    };
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
                        ]
                      ],
                    ),
                  ),
                ),
              )
            ],
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
                  case "documentFile":
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
                  case "documentFile":
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
        'doc',
        'docx',
        'pdf',
        'txt',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'odt',
        'ods',
        'odp',
      ],
    );

    if (image != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
      var element = image.files.first;
      if (element.size < 2000000) {
        setState(() {
          documentFileList = [
            {
              "documentFile": File(element.path!),
              "documentFileName": element.name,
              "documentExtentionNoDot": element.name.split('.').last,
            }
          ];
          fileNameController.text = element.name;
          _documentXFile = image.xFiles.first as XFile?;
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
          documentFileList = [
            {
              "documentFile": File(pickedFile.path),
              "documentFileName": pickedFile.name,
              "documentExtentionNoDot": pickedFile.name.split('.').last,
            }
          ];
          fileNameController.text = pickedFile.name;
          _documentXFile = pickedFile;
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
