import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/models/prescriptions.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/doctor_patient_profile_provider.dart';
import 'package:health_care/services/doctor_pateint_profile_service.dart';
import 'package:health_care/services/prescription_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/patient_profile/doctor_pateint_profile_header.dart';
import 'package:provider/provider.dart';

class PrescriptionAddWidget extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/add-prescription';
  final String mongoPatientUserId;
  final String viewType;
  const PrescriptionAddWidget({
    super.key,
    required this.mongoPatientUserId,
    required this.viewType,
  });

  @override
  State<PrescriptionAddWidget> createState() => _PrescriptionAddWidgetState();
}

class _PrescriptionAddWidgetState extends State<PrescriptionAddWidget> {
  ScrollController scrollController = ScrollController();
  final DoctorPateintProfileService doctorPateintProfileService = DoctorPateintProfileService();
  final PrescriptionService prescriptionService = PrescriptionService();
  late final DoctorPatientProfileProvider doctorPatientProfileProvider;
  DoctorsProfile? doctorsProfile;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  bool _hasRedirected = false;

  Future<void> getDataOnUpdate() async {
    doctorPateintProfileService.findDocterPatientProfileById(context, widget.mongoPatientUserId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      doctorPatientProfileProvider = Provider.of<DoctorPatientProfileProvider>(context, listen: false);
      doctorsProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> onPrescriptionSubmit(List<PrescriptionDetails> prescriptionDetailsList) async {
    final List<Map<String, dynamic>> prescriptionsArray = prescriptionDetailsList.map((e) => e.toJson()).toList();
    Map<String, dynamic> payload = {
      "doctorId": doctorsProfile?.userId,
      "patientId": doctorPatientProfileProvider.patientProfile.id,
      "prescriptionsArray": prescriptionsArray,
    };
    final String? newId = await prescriptionService.addPrescription(context, payload);

    if (!mounted) return;
    if (newId == null) {
      showErrorSnackBar(context, context.tr('medicalRecordAdded'));
    } else {
      final encodedPrescriptionId = base64.encode(utf8.encode(newId.toString()));
      context.push(Uri(path: '/doctors/dashboard/editprescription/$encodedPrescriptionId').toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorPatientProfileProvider>(builder: (context, doctorPatientProfileProvider, child) {
      final DoctorPatientProfileModel doctorPatientProfile = doctorPatientProfileProvider.patientProfile;
      final bool isLoading = doctorPatientProfileProvider.isLoading;
      // final ThemeData theme = Theme.of(context);
      if (isLoading) {
        return ScaffoldWrapper(title: context.tr('ss'), children: const Center(child: CircularProgressIndicator()));
      }
      //Redirect if id is empty
      if ((doctorPatientProfile.id?.isEmpty ?? true) && !_hasRedirected) {
        _hasRedirected = true;
        Future.microtask(() {
          if (context.mounted) {
            context.push('/doctors/dashboard');
          }
        });
      }
      String viewType = widget.viewType;

      return ScaffoldWrapper(
        title: context.tr('${viewType}_prescription'),
        children: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                double per = 0;
                if (scrollController.hasClients) {
                  per = ((scrollController.offset / scrollController.position.maxScrollExtent));
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
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    DoctorPateintProfileHeader(doctorPatientProfile: doctorPatientProfile),
                    Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0.0),
                          topRight: Radius.circular(0.0),
                        ),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Column(
                            children: [
                              PrescriptionDetailsForm(
                                formType: 'add',
                                onPrescriptionSubmit: onPrescriptionSubmit,
                                prescriptionDetailsList: [PrescriptionDetails.empty()],
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
            ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
          ],
        ),
      );
    });
  }
}

class PrescriptionDetailsForm extends StatefulWidget {
  final String formType;
  final Future<void> Function(List<PrescriptionDetails>) onPrescriptionSubmit;
  final List<PrescriptionDetails> prescriptionDetailsList;
  const PrescriptionDetailsForm({
    super.key,
    required this.formType,
    required this.onPrescriptionSubmit,
    required this.prescriptionDetailsList,
  });

  @override
  State<PrescriptionDetailsForm> createState() => _PrescriptionDetailsFormState();
}

class _PrescriptionDetailsFormState extends State<PrescriptionDetailsForm> {
  final formKey = GlobalKey<FormBuilderState>();

  late List<PrescriptionDetails> _localList;

  @override
  void initState() {
    super.initState();
    _localList = List.from(widget.prescriptionDetailsList);
  }

  @override
  Widget build(BuildContext context) {
    final String formType = widget.formType;
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    // List<PrescriptionDetails> prescriptionDetailsList = _localList;
    return FormBuilder(
      key: formKey,
      child: Column(
        children: [
          ..._localList.asMap().entries.map((entry) {
            int index = entry.key;
            var detail = entry.value;

            return Card(
              key: ValueKey(detail.uniqueId),
              elevation: 12,
              color: theme.canvasColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.primaryColorLight),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    PrescriptionInput(
                      index: index,
                      detail: detail,
                      formType: formType,
                      theme: theme,
                      textColor: textColor,
                      name: 'medicine',
                    ),
                    PrescriptionInput(
                      index: index,
                      detail: detail,
                      formType: formType,
                      theme: theme,
                      textColor: textColor,
                      name: 'quantity',
                    ),
                    PrescriptionInput(
                      index: index,
                      detail: detail,
                      formType: formType,
                      theme: theme,
                      textColor: textColor,
                      name: 'description',
                    ),
                    if (formType != 'view')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 35,
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.pink,
                                  Colors.red,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.07,
                                ),
                              ),
                              onPressed: () {
                                if (_localList.length > 1) {
                                  setState(() {
                                    _localList.removeAt(index);
                                  });
                                } else {
                                  // Prescription should at least has 1 field
                                  showErrorSnackBar(context, "minPrescriptionError");
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete, size: 13, color: textColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    context.tr("delete"),
                                    style: TextStyle(fontSize: 12, color: textColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          if (formType != 'view' && _localList.length < 5) ...[
            SizedBox(
              height: 35,
              child: GradientButton(
                onPressed: () {
                  setState(() {
                    _localList.add(PrescriptionDetails.empty());
                  });
                },
                colors: [
                  Theme.of(context).primaryColorLight,
                  Theme.of(context).primaryColor,
                ],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.plus, size: 13, color: textColor),
                    const SizedBox(width: 5),
                    Text(
                      context.tr("addPrescription"),
                      style: TextStyle(fontSize: 12, color: textColor),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (formType != 'view')
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth, // this respects the width of the column
                  height: 35,
                  child: GradientButton(
                    onPressed: () {
                      if (formKey.currentState!.saveAndValidate()) {
                        widget.onPrescriptionSubmit(_localList);
                      }
                    },
                    colors: [theme.primaryColor, theme.primaryColorLight],
                    child: Text(
                      context.tr("submit"),
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class PrescriptionInput extends StatelessWidget {
  const PrescriptionInput({
    super.key,
    required this.index,
    required this.detail,
    required this.formType,
    required this.theme,
    required this.textColor,
    required this.name,
  });

  final int index;
  final String name;
  final PrescriptionDetails detail;
  final String formType;
  final ThemeData theme;
  final Color textColor;
  String? getInitialValue() {
    switch (name) {
      case 'description':
        return detail.description;
      case 'medicine':
        return detail.medicine;
      case 'medicineId':
        return detail.medicineId;
      case 'quantity':
        return detail.quantity.toString();
      default:
        return '';
    }
  }

  String? Function(String?)? getValidator(BuildContext context) {
    if (formType == 'view') return null;

    return (fieldValue) {
      if (fieldValue == null || fieldValue.trim().isEmpty) {
        return context.tr('required');
      }

      if (name == 'quantity') {
        final intVal = int.tryParse(fieldValue.trim());
        if (intVal == null || intVal <= 0) {
          return context.tr('mustBePositiveInt');
        }
      }

      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Semantics(
        label: context.tr(name),
        child: FormBuilderTextField(
          enabled: formType != 'view',
          enableSuggestions: true,
          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
          keyboardType: name == 'quantity' ? TextInputType.number : TextInputType.name,
          autovalidateMode: formType != 'view' ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          inputFormatters: name == 'quantity' ? [FilteringTextInputFormatter.digitsOnly] : [],
          validator: getValidator(context),
          name: '${name}_${detail.uniqueId}',
          initialValue: getInitialValue(),
          decoration: InputDecoration(
            errorStyle: TextStyle(color: Colors.redAccent.shade400),
            floatingLabelStyle: TextStyle(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight),
            labelStyle: TextStyle(color: formType == 'view' ? theme.disabledColor : theme.primaryColorLight),
            // labelText: context.tr(key),
            label: RichText(
              text: TextSpan(
                text: context.tr(name),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: formType == 'view' ? theme.disabledColor : textColor),
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            hintText: context.tr(name),
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
            // prefixIcon: Icon(Icons.account_circle_sharp, color: Theme.of(context).primaryColorLight),
            isDense: true,
            alignLabelWithHint: true,
          ),
          onChanged: (val) {
            // Update the detail object directly
            switch (name) {
              case 'description':
                detail.description = val ?? '';
                break;
              case 'medicine':
                detail.medicine = val ?? '';
                break;
              case 'medicineId':
                detail.medicineId = val ?? '';
                break;
              case 'quantity':
                detail.quantity = int.tryParse(val ?? '0') ?? 0;
                break;
            }
          },
        ),
      ),
    );
  }
}
