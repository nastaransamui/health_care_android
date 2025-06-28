
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/favourites_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/favourite_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/patients/favourites/patients_favourite_show_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientsFavourites extends StatefulWidget {
  static const String routeName = "/patients/dashboard/favourites";
  const PatientsFavourites({super.key});

  @override
  State<PatientsFavourites> createState() => _PatientsFavouritesState();
}

class _PatientsFavouritesState extends State<PatientsFavourites> {
  final ScrollController scrollController = ScrollController();
  late final DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final FavouriteService favouriteService = FavouriteService();
  late final FavouritesProvider favouritesProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate() async {
    final patientProfile = authProvider.patientProfile;
    final favIds = patientProfile?.userProfile.favsId;
    await favouriteService.getFavDoctorsForPatientProfile(context, favIds!);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      favouritesProvider = Provider.of<FavouritesProvider>(context, listen: false);
      dataGridProvider.setSortModel([
        {"field": "profile.id", "sort": 'asc'}
      ], notify: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('getFavDoctorsForPatientProfileReturn');
    socket.off('updateGetFavDoctorsForPatientProfile');
    socket.off('updateGetFavPatientsForDoctorProfilePatient');
    favouritesProvider.setDoctorFavProfileForPatient([], notify: false);
    favouritesProvider.setTotal(0, notify: false);
    dataGridProvider.setMongoFilterModel({}, notify: false);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavouritesProvider>(
      builder: (context, favouritesProvider, _) {
        final doctorFavProfileForPatient = favouritesProvider.doctorFavProfileForPatient;
        bool isLoading = favouritesProvider.isLoading;
        final patientProfile = authProvider.patientProfile;
        final int totalFavourites = patientProfile?.userProfile.favsId.length ?? 0;
        final theme = Theme.of(context);
        bool isFilterActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'profile.id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'profile.fullName', label: Text(context.tr('patientName'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'status.lastLogin.date', label: Text(context.tr('lastLogin'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'profile.dob', label: Text(context.tr('dob'))), dataType: 'date'),
          FilterableGridColumn(
              column: GridColumn(columnName: 'profile.specialities.0.specialities', label: Text(context.tr('speciality'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'profile.city', label: Text(context.tr('city'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'profile.state', label: Text(context.tr('state'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'profile.country', label: Text(context.tr('country'))), dataType: 'string'),
        ];
        return ScaffoldWrapper(
          title: context.tr('favourites'),
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
                                  "totalFavourites",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ).plural(
                                  isFilterActive ? doctorFavProfileForPatient.length : totalFavourites,
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
                        count: isFilterActive ? doctorFavProfileForPatient.length : totalFavourites,
                        getDataOnUpdate: getDataOnUpdate,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        restorationId: 'doctorFavorite',
                        key: ValueKey(doctorFavProfileForPatient.length),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: doctorFavProfileForPatient.length,
                        itemBuilder: (context, index) {
                          final doctorFavProfile = doctorFavProfileForPatient[index];
                          return PatientsFavouriteShowBox(
                            doctorFavProfile: doctorFavProfile,
                            getDataOnUpdate: getDataOnUpdate,
                            patientProfile: patientProfile!,
                            favouritesProvider: favouritesProvider,
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
                          child: SfDataGridFilterWidget(columns: filterableColumns, columnName: 'profile.id'),
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
