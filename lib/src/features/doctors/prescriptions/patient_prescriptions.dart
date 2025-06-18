import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/src/features/doctors/prescriptions/prescription_show_box.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/prescription_provider.dart';
import 'package:health_care/providers/widget_injection_provider.dart';
import 'package:health_care/services/prescription_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/stream_socket.dart';

class PatientPrescriptions extends StatefulWidget {
  static const String routeName = "/patient/dashboard/prescriptions";
  final String patientId;
  const PatientPrescriptions({
    super.key,
    required this.patientId,
  });

  @override
  State<PatientPrescriptions> createState() => _PatientPrescriptionsState();
}

class _PatientPrescriptionsState extends State<PatientPrescriptions> {
  final ScrollController scrollController = ScrollController();
  final PrescriptionService prescriptionService = PrescriptionService();
  late PrescriptionProvider prescriptionProvider;
  late DataGridProvider dataGridProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  int? expandedIndex;
  late String roleName;
  Future<void> getDataOnUpdate() async {
    await prescriptionService.getPrescriptionRecord(context, widget.patientId);
    setState(() {
      expandedIndex = null;
    });
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
      prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('getPrescriptionRecordReturn');
    socket.off('updateGetPrescriptionRecord');
    prescriptionProvider.setTotal(0, notify: false);
    prescriptionProvider.setLoading(false, notify: false);
    prescriptionProvider.setPrescriptions([], notify: false);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionProvider>(
      builder: (context, prescriptionProvider, _) {
        final prescriptions = prescriptionProvider.prescriptions;
        bool isLoading = prescriptionProvider.isLoading;
        final int totalPrescriptions = prescriptionProvider.total;
        final theme = Theme.of(context);
        final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        final injected = context.watch<WidgetInjectionProvider>().injectedWidget;

        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'doctorProfile.fullName', label: Text(context.tr('doctorName'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'createdAt', label: Text(context.tr('createdAt'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'updateAt', label: Text(context.tr('updateAt'))), dataType: 'date'),
          FilterableGridColumn(
              column: GridColumn(columnName: 'doctorProfile.specialities.0.specialities', label: Text(context.tr('speciality'))), dataType: 'string'),
        ];

        return ScaffoldWrapper(
          title: context.tr('prescriptions'),
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
                          if (roleName == 'doctors') ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 35,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: GradientButton(
                                  onPressed: () {
                                    final encodedpatientId = base64.encode(utf8.encode(widget.patientId.toString()));
                                    context.push(Uri(path: '/doctors/dashboard/add-prescription/$encodedpatientId').toString());
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
                                        context.tr("addPrescription"),
                                        style: TextStyle(fontSize: 12, color: textColor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          FadeinWidget(
                            isCenter: true,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Card(
                                elevation: 6,
                                color: theme.canvasColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Theme.of(context).primaryColorLight),
                                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      "totalPrescriptions",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ).plural(
                                      isFilterActive ? prescriptions.length : totalPrescriptions,
                                      format: NumberFormat.compact(
                                        locale: context.locale.toString(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomPaginationWidget(
                            count: isFilterActive ? prescriptions.length : totalPrescriptions,
                            getDataOnUpdate: getDataOnUpdate,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            restorationId: 'prescriptions',
                            key: const ValueKey('prescriptions'),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: prescriptions.length,
                            itemBuilder: (context, index) {
                              final prescription = prescriptions[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: PrescriptionShowBox(
                                  getDataOnUpdate: getDataOnUpdate,
                                  prescription: prescription,
                                  isExpanded: expandedIndex == index,
                                  index: index,
                                  onToggle: (tappedIndex) {
                                    setState(() {
                                      expandedIndex = (expandedIndex == tappedIndex) ? null : tappedIndex;
                                    });
                                  },
                                ),
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
