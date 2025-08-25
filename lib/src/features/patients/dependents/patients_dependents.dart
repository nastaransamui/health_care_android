import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/dependents.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/dependents_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/dependents_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/patients/dependents/dependent_form.dart';
import 'package:health_care/src/features/patients/dependents/patients_dependants_show_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientsDependents extends StatefulWidget {
  static const String routeName = "/patient/dashboard/dependent";
  const PatientsDependents({super.key});

  @override
  State<PatientsDependents> createState() => _PatientsDependentsState();
}

class _PatientsDependentsState extends State<PatientsDependents> {
  final ScrollController scrollController = ScrollController();
  late final DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  late final DependentsProvider dependentsProvider;
  final DependentsService dependentsService = DependentsService();
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  late List<String> deleteIds;

  Future<void> getDataOnUpdate() async {
    await dependentsService.getPatientDependent(context);
    setState(() {
      deleteIds.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    deleteIds = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      dependentsProvider = Provider.of<DependentsProvider>(context, listen: false);
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      dataGridProvider.setSortModel([
        {"field": "id", "sort": 'asc'}
      ], notify: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off("getPatientDependentReturn");
    socket.off("updateGetPatientDependent");
    socket.off('deleteDependentReturn');
    socket.off('updateDependentReturn');
    dependentsProvider.setDependents([], notify: false);
    dependentsProvider.setTotal(0, notify: false);
    dataGridProvider.setMongoFilterModel({}, notify: false);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getConfirmationForDeleteDependent(
    BuildContext context,
    List<String> deleteIds,
  ) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColorLight,
            title: const Text("dependentsForDelete").plural(
              deleteIds.length,
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
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
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
                        context.tr("confirmDeleteDependents"),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).primaryColor,
                        ),
                      )),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, deleteIds);
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
      deleteDependentRequestSubmit(context, result);
    }
  }

  Future<void> deleteDependentRequestSubmit(BuildContext context, List<String> deleteIds) async {
    bool success = await dependentsService.deleteDependent(context, deleteIds);

    if (success) {
      if (context.mounted) {
        showErrorSnackBar(context, "${deleteIds.length} Dependent(s) was deleted.");
      }
      setState(() {
        deleteIds.clear();
      });
    }
  }

  Future<void> openAddEditDependentForm(BuildContext context, Dependents dependent) async {
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
          child: DependentForm(
            dependent: dependent,
          ),
        ),
      );

      if (payload != null) {
        if (context.mounted) {
          bool success = await dependentsService.updateDependent(context, payload);

          if (success) {
            if (context.mounted) {
              showErrorSnackBar(context, context.tr('dependentAdded'));
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DependentsProvider>(
      builder: (context, dependentsProvider, _) {
        final dependents = dependentsProvider.dependents;
        bool isLoading = dependentsProvider.isLoading;
        final int totalDepends = dependentsProvider.total;
        final ThemeData theme = Theme.of(context);
        final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        List<String> deleteableDependentList =
            dependents.where((dependent) => dependent.medicalRecordsArray.isEmpty).map((dep) => dep.id.toString()).toList();
        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'isActive', label: Text(context.tr('isActive'))), dataType: 'boolean'),
          FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'fullName', label: Text(context.tr('name'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'relationShip', label: Text(context.tr('relationShip'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'dob', label: Text(context.tr('dob'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'bloodG', label: Text(context.tr('bloodG'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'updateAt', label: Text(context.tr('updateAt'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'createdAt', label: Text(context.tr('createdAt'))), dataType: 'date'),
        ];
        return ScaffoldWrapper(
          title: context.tr('dependent'),
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
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 35,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GradientButton(
                            onPressed: () {
                              String userId = authProvider.patientProfile!.userId;
                              openAddEditDependentForm(context, Dependents.empty(userId: userId));
                            },
                            colors: [
                              Theme.of(context).primaryColorLight,
                              Theme.of(context).primaryColor,
                            ],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.circlePlus, size: 13, color: textColor),
                                const SizedBox(width: 5),
                                Text(
                                  context.tr("addDependent"),
                                  style: TextStyle(fontSize: 12, color: textColor),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
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
                                  "totalDependents",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ).plural(
                                  isFilterActive ? dependents.length : totalDepends,
                                  format: NumberFormat.compact(
                                    locale: context.locale.toString(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                        child: deleteIds.isNotEmpty
                            ? Padding(
                                key: const ValueKey("buttonVisible"),
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  child: GradientButton(
                                    onPressed: () async {
                                      getConfirmationForDeleteDependent(context, deleteIds);
                                    },
                                    colors: const [
                                      Colors.pink,
                                      Colors.red,
                                    ],
                                    child: Center(
                                      child: Text(
                                        "deleteDependentRequest",
                                        style: TextStyle(fontSize: 12, color: textColor),
                                      ).plural(
                                        deleteIds.length,
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
                        count: isFilterActive ? dependents.length : totalDepends,
                        getDataOnUpdate: getDataOnUpdate,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            splashRadius: 0,
                            checkColor: theme.primaryColorLight,
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            value: deleteIds.isNotEmpty,
                            onChanged: (bool? value) {
                              if (value == false) {
                                setState(() {
                                  deleteIds.clear();
                                });
                              } else {
                                setState(() {
                                  deleteIds = deleteableDependentList;
                                });
                              }
                            },
                          ),
                          Text('taggleDependentForDelete',
                              style: TextStyle(
                                fontSize: 18,
                                color: theme.primaryColorLight,
                              )).plural(
                            deleteableDependentList.length,
                            format: NumberFormat.compact(
                              locale: context.locale.toString(),
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        restorationId: 'patientDependents',
                        key: const ValueKey('patientDependents'),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dependents.length,
                        itemBuilder: (context, index) {
                          final dependent = dependents[index];
                          return PatientsDependantsShowBox(
                            dependent: dependent,
                            getDataOnUpdate: getDataOnUpdate,
                            getConfirmationForDeleteDependent: getConfirmationForDeleteDependent,
                            openAddEditDependentForm: openAddEditDependentForm,
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
                      ],
                    ],
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
