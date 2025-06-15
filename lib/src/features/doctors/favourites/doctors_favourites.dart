import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/favourites_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/favourite_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/doctors_patients_show_box.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DoctorsFavourites extends StatefulWidget {
  static const String routeName = "/doctors/dashboard/favourites";
  const DoctorsFavourites({super.key});

  @override
  State<DoctorsFavourites> createState() => _DoctorsFavouritesState();
}

class _DoctorsFavouritesState extends State<DoctorsFavourites> {
  final ScrollController favouritesScrollController = ScrollController();
  late final DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final FavouriteService favouriteService = FavouriteService();
  late final FavouritesProvider favouritesProvider = FavouritesProvider();
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate() async {
    final doctorProfile = authProvider.doctorsProfile;
    final favIds = doctorProfile?.userProfile.favsId;
    await favouriteService.getFavPatientsForDoctorProfile(context, favIds!);
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
      dataGridProvider.setSortModel([
        {"field": "profile.id", "sort": 'asc'}
      ], notify: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('getFavPatientsForDoctorProfileReturn');
    socket.off('updateGetFavPatientsForDoctorProfile');
    socket.off('updateGetFavPatientsForDoctorProfilePatient');
    favouritesProvider.setUserFavProfile([], notify: false);
    favouritesProvider.setTotal(0, notify: false);
    favouritesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavouritesProvider>(
      builder: (context, favouritesProvider, _) {
        final userFavProfile = favouritesProvider.userFavProfile;
        bool isLoading = favouritesProvider.isLoading;
        final doctorProfile = authProvider.doctorsProfile;
        final int totalFavourites = doctorProfile?.userProfile.favsId.length ?? 0;
        final theme = Theme.of(context);

        bool isActive = dataGridProvider.mongoFilterModel.isNotEmpty;
        final List<FilterableGridColumn> filterableColumns = [
          FilterableGridColumn(column: GridColumn(columnName: 'profile.id', label: Text(context.tr('id'))), dataType: 'number'),
          FilterableGridColumn(column: GridColumn(columnName: 'profile.fullName', label: Text(context.tr('patientName'))), dataType: 'string'),
          FilterableGridColumn(column: GridColumn(columnName: 'status.lastLogin.date', label: Text(context.tr('lastLogin'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'profile.dob', label: Text(context.tr('dob'))), dataType: 'date'),
          FilterableGridColumn(column: GridColumn(columnName: 'profile.bloodG', label: Text(context.tr('bloodG'))), dataType: 'string'),
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
                  if (favouritesScrollController.hasClients) {
                    per = ((favouritesScrollController.offset / favouritesScrollController.position.maxScrollExtent));
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
                child: Column(
                  children: [
                    FadeinWidget(
                      isCenter: true,
                      child: Padding(
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
                                "totalFavourites",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ).plural(
                                isActive ? userFavProfile.length : totalFavourites,
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
                      count: isActive ? userFavProfile.length : totalFavourites,
                      getDataOnUpdate: getDataOnUpdate,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                            controller: favouritesScrollController,
                            shrinkWrap: true,
                            restorationId: 'doctorFavorite',
                            key: const ValueKey('doctorFavorite'),
                            physics: const BouncingScrollPhysics(),
                            itemCount: userFavProfile.length,
                            itemBuilder: (context, index) {
                              final patientFavProfile = userFavProfile[index];
                              return DoctorsPatientsShowBox(
                                patientFavProfile: patientFavProfile,
                                getDataOnUpdate: getDataOnUpdate,
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
                          ScrollButton(scrollController: favouritesScrollController, scrollPercentage: scrollPercentage)
                        ],
                      ),
                    )
                  ],
                ),
              ),
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
                        if (isActive)
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
