import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/dependents.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/models/medical_records.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/medical_records_provider.dart';
import 'package:health_care/providers/widget_injection_provider.dart';
import 'package:health_care/services/medical_records_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';

import 'package:health_care/src/features/patients/medicalRecords/medical_record_form.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';

import 'package:health_care/stream_socket.dart';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientMedicalRecords extends StatefulWidget {
  static const String routeName = "/patient/dashboard/medicalRecords";
  final String patientId;
  final DoctorPatientProfileModel? doctorPatientProfile;
  const PatientMedicalRecords({
    super.key,
    required this.patientId,
    this.doctorPatientProfile,
  });

  @override
  State<PatientMedicalRecords> createState() => _PatientMedicalRecordsState();
}

class _PatientMedicalRecordsState extends State<PatientMedicalRecords> {
  final ScrollController scrollController = ScrollController();
  final MedicalRecordsService medicalRecordsService = MedicalRecordsService();
  late MedicalRecordsProvider medicalRecordsProvider;
  late DataGridProvider dataGridProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  late List<String> deleteRecordsId;
  late String roleName;
  late PatientsProfile? patientUserProfile;

  Future<void> getDataOnUpdate() async {
    await medicalRecordsService.getMedicalRecordWithDependent(context, widget.patientId);
    setState(() {
      deleteRecordsId.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    deleteRecordsId = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      medicalRecordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
      patientUserProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('getMedicalRecordWithDependentReturn');
    socket.off('updateGetMedicalRecordWithDependent');
    socket.off('deleteMedicalRecordReturn');
    socket.off('updateMedicalRecordReturn');
    medicalRecordsProvider.setTotal(0, notify: false);
    medicalRecordsProvider.setLoading(false, notify: false);
    medicalRecordsProvider.setMedicalRecords([], notify: false);
    dataGridProvider.setMongoFilterModel({}, notify: false);
    scrollController.dispose();
    super.dispose();
  }

  void tougleRecordIdTodeleteRecordsId(String billId) {
    if (deleteRecordsId.contains(billId)) {
      setState(() {
        deleteRecordsId.remove(billId);
      });
    } else {
      setState(() {
        deleteRecordsId.add(billId);
      });
      showConfirmDeleteScafold(context);
    }
  }

  Future<void> deleteRecordRequestSubmit(BuildContext context, List<String> deleteIds) async {
    bool success = await medicalRecordsService.deleteMedicalRecord(context, widget.patientId, deleteIds);

    if (success) {
      if (context.mounted) {
        showErrorSnackBar(context, "${deleteIds.length} Records(s) was deleted.");
      }
      setState(() {
        deleteRecordsId.clear();
      });
    }
  }

  Future<void> showConfirmDeleteScafold(BuildContext context) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColorLight,
            title: const Text("medicalRecordsForDelete").plural(
              deleteRecordsId.length,
              format: NumberFormat.compact(
                locale: context.locale.toString(),
              ),
            ),
            automaticallyImplyLeading: false, // Removes the back button
            actions: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    deleteRecordsId.clear();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FadeinWidget(
                  isCenter: true,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).primaryColorLight),
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                            child: Text(
                          context.tr("medicalRecordDeleteConfirm"),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).primaryColor,
                          ),
                        )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, deleteRecordsId);
                    },
                    child: Text(context.tr("submit")),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    if (!context.mounted) return;

    if (result != null) {
      deleteRecordRequestSubmit(context, result);
    }
  }

  Future<void> openViewEditForm(BuildContext context, MedicalRecords medicalRecord, String formType) async {
    final String? userId = roleName == 'doctors' ? widget.doctorPatientProfile?.id : widget.patientId;

    final url = Uri.parse(
      '${dotenv.env['adminUrl']!}/api/getDependents?_id=$userId',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        // 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Handle the decoded data
      if (data['success']) {
        final dependents = data['dependents'];
        if (dependents is List) {
          final dependentsList = dependents.map((json) => Dependents.fromMap(json)).toList();

          if (context.mounted) {
            final payload = await showModalBottomSheet(
              useSafeArea: true,
              showDragHandle: false,
              isScrollControlled: true,
              isDismissible: false,
              enableDrag: false,
              context: context,
              builder: (context) => FractionallySizedBox(
                heightFactor: 1,
                child: MedicalRecordForm(
                  formType: formType,
                  medicalRecord: medicalRecord,
                  dependents: dependentsList,
                ),
              ),
            );

            if (payload != null) {
              if (context.mounted) {
                bool success = await medicalRecordsService.updateMedicalRecord(context, payload);

                if (success) {
                  if (context.mounted) {
                    showErrorSnackBar(context, context.tr('medicalRecordAdded'));
                  }
                  dependentsList.clear();
                }
              }
            }
          }
        }
      }
    } else {
      // Handle error
      if (context.mounted) {
        showErrorSnackBar(context, 'Error: ${response.statusCode} - ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalRecordsProvider>(
      builder: (context, medicalRecordsProvider, _) {
        final medicalRecords = medicalRecordsProvider.medicalRecords;
        bool isLoading = medicalRecordsProvider.isLoading;
        final int totalMedicalRecords = medicalRecordsProvider.total;
        final theme = Theme.of(context);
        final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        final injected = context.watch<WidgetInjectionProvider>().injectedWidget;
        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'isForDependent', label: Text(context.tr('isForDependent'))), dataType: 'boolean'),
          FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'createdAt', label: Text(context.tr('createdAt'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'updateAt', label: Text(context.tr('updateAt'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'date', label: Text(context.tr('date'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'fullName', label: Text(context.tr('name'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'description', label: Text(context.tr('description'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'symptoms', label: Text(context.tr('symptoms'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'hospitalName', label: Text(context.tr('hospitalName'))), dataType: 'string'),
        ];

        return ScaffoldWrapper(
          title: context.tr('medicalRecords'),
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0.0),
                          topRight: Radius.circular(0.0),
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                      child: Column(
                        children: [
                          if (injected != null) ...[
                            injected,
                          ],
                          if(injected == null) const SizedBox(height: 10),
                          SizedBox(
                            height: 35,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: GradientButton(
                                onPressed: () {
                                  final firstName =
                                      roleName == 'doctors' ? widget.doctorPatientProfile?.firstName : patientUserProfile?.userProfile.firstName;
                                  final lastName =
                                      roleName == 'doctors' ? widget.doctorPatientProfile?.lastName : patientUserProfile?.userProfile.lastName;
                                  final userId = roleName == 'doctors' ? widget.doctorPatientProfile?.id : patientUserProfile?.userProfile.id;
                                  openViewEditForm(context,
                                      MedicalRecords.empty(firstName: firstName ?? "", lastName: lastName ?? '', userId: userId ?? ''), 'create');
                                },
                                colors: [
                                  Theme.of(context).primaryColorLight,
                                  Theme.of(context).primaryColor,
                                ],
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(FontAwesomeIcons.plusCircle, size: 13, color: textColor),
                                    const SizedBox(width: 5),
                                    Text(
                                      context.tr("addMedicalRecord"),
                                      style: TextStyle(fontSize: 12, color: textColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          TotalBox(isFilterActive: isFilterActive, medicalRecords: medicalRecords, totalMedicalRecords: totalMedicalRecords),
                          // confirmed delete
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.vertical,
                                child: child,
                              );
                            },
                            child: deleteRecordsId.isNotEmpty
                                ? Padding(
                                    key: const ValueKey("buttonVisible"),
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 40,
                                      child: GradientButton(
                                        onPressed: () async {
                                          showConfirmDeleteScafold(context);
                                        },
                                        colors: [
                                          Theme.of(context).primaryColorLight,
                                          Theme.of(context).primaryColor,
                                        ],
                                        child: Center(
                                          child: Text(
                                            "deleteMedicalButton",
                                            style: TextStyle(fontSize: 12, color: textColor),
                                          ).plural(
                                            deleteRecordsId.length,
                                            format: NumberFormat.compact(
                                              locale: context.locale.toString(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(key: ValueKey("buttonHidden")),
                          ),
                          const SizedBox(height: 10),
                          CustomPaginationWidget(
                            count: isFilterActive ? medicalRecords.length : totalMedicalRecords,
                            getDataOnUpdate: getDataOnUpdate,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                splashRadius: 0,
                                checkColor: theme.primaryColorLight,
                                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                value: deleteRecordsId.isNotEmpty,
                                onChanged: (bool? value) {
                                  if (value == false) {
                                    setState(() {
                                      deleteRecordsId.clear();
                                    });
                                  } else {
                                    setState(() {
                                      deleteRecordsId = medicalRecords.map((e) => e.id!).toList();
                                    });
                                  }
                                },
                              ),
                              Text('tuggleMedicalForDelete',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: theme.primaryColorLight,
                                  )).plural(
                                medicalRecords.length,
                                format: NumberFormat.compact(
                                  locale: context.locale.toString(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            restorationId: 'medicalRecords',
                            key: const ValueKey('medicalRecords'),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: medicalRecords.length,
                            itemBuilder: (context, index) {
                              final medicalRecord = medicalRecords[index];
                              return MedicalRecordShowBox(
                                medicalRecord: medicalRecord,
                                getDataOnUpdate: getDataOnUpdate,
                                deleteRecordsId: deleteRecordsId,
                                tougleRecordIdTodeleteRecordsId: tougleRecordIdTodeleteRecordsId,
                                doctorPatientProfile: widget.doctorPatientProfile,
                                openViewEditForm: openViewEditForm,
                              );
                            },
                          ),
                          if (isLoading) ...[
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
              Positioned(
                bottom: 10,
                left: 10,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: FloatingActionButton(
                    tooltip: context.tr('filter'),
                    mini: true,
                    onPressed: () async {
                      final result = await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => FractionallySizedBox(
                          heightFactor: 0.9,
                          child: SfDataGridFilterWidget(columns: filterableColumns, columnName: 'id'),
                        ),
                      );

                      if (result != null) {
                        dataGridProvider.setPaginationModel(0, 10);
                        dataGridProvider.setMongoFilterModel({...result});
                        await getDataOnUpdate();
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 25,
                          color: theme.primaryColor,
                        ),
                        if (isFilterActive)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TotalBox extends StatelessWidget {
  const TotalBox({
    super.key,
    required this.isFilterActive,
    required this.medicalRecords,
    required this.totalMedicalRecords,
  });

  final bool isFilterActive;
  final List<MedicalRecords> medicalRecords;
  final int totalMedicalRecords;

  @override
  Widget build(BuildContext context) {
    return FadeinWidget(
      isCenter: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Card(
          elevation: 6,
          color: Theme.of(context).canvasColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).primaryColorLight),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "totalMedicalRecords",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ).plural(
                isFilterActive ? medicalRecords.length : totalMedicalRecords,
                format: NumberFormat.compact(
                  locale: context.locale.toString(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
