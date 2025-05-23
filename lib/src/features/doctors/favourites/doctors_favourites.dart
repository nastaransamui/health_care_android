import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/favourites_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/favourite_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sf_data_grid_filter_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:timezone/timezone.dart' as tz;

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
      favouritesProvider.setLoading(true);
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
    // favouritesProvider.setLoading(false);
    favouritesProvider.setUserFavProfile([]);
    favouritesProvider.setTotal(0);
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
                                return DoctorsFavouriteShowBox(
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
            ));
      },
    );
  }
}

class DoctorsFavouriteShowBox extends StatefulWidget {
  final PatientUserProfile patientFavProfile;
  final VoidCallback getDataOnUpdate;
  const DoctorsFavouriteShowBox({
    super.key,
    required this.patientFavProfile,
    required this.getDataOnUpdate,
  });

  @override
  State<DoctorsFavouriteShowBox> createState() => _DoctorsFavouriteShowBoxState();
}

class _DoctorsFavouriteShowBoxState extends State<DoctorsFavouriteShowBox> {
  @override
  Widget build(BuildContext context) {
    final PatientUserProfile patientProfile = widget.patientFavProfile;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
    final bangkok = tz.getLocation('Asia/Bangkok');
    late String years = '--';
    late String months = '--';
    late String days = '--';
    if (patientProfile.dob is DateTime) {
      DateTime dob = patientProfile.dob;
      DateTime today = DateTime.now();
      DateTime b = DateTime(dob.year, dob.month, dob.day);
      int totalDays = today.difference(b).inDays;
      int y = totalDays ~/ 365;
      int m = (totalDays - y * 365) ~/ 30;
      int d = totalDays - y * 365 - m * 30;

      years = '$y';
      months = '$m';
      days = '$d';
    }
    final String gender = patientProfile.gender;
    final String patientName = "$gender${gender != '' ? '. ' : ''}${patientProfile.fullName}";
    final String profileImage = patientProfile.profileImage;
    final String? patientId = patientProfile.id;
    final LastLogin lastLogin = patientProfile.lastLogin;
    final DateTime lastLoginDate = lastLogin.date;
    final encodedId = base64.encode(utf8.encode(patientId.toString()));
    Color statusColor = patientProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : patientProfile.online
            ? const Color(0xFF44B700)
            : Colors.pinkAccent;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        color: theme.canvasColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        splashColor: theme.primaryColorLight,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        onTap: () {
                          context.push(
                            Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                          );
                        },
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: theme.primaryColorLight),
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: profileImage.isEmpty
                                  ? const AssetImage(
                                      'assets/images/default-avatar.png',
                                    ) as ImageProvider
                                  : CachedNetworkImageProvider(
                                      profileImage,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.primaryColor, width: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.push(
                                Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                              );
                            },
                            child: Text(
                              patientName,
                              style: TextStyle(
                                color: theme.primaryColorLight,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SortIconWidget(columnName: 'profile.fullName', getDataOnUpdate: widget.getDataOnUpdate)
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('#${patientProfile.patientsId}', style: TextStyle(color: theme.primaryColorLight)),
                          const SizedBox(width: 6),
                          SortIconWidget(columnName: 'profile.id', getDataOnUpdate: widget.getDataOnUpdate)
                        ],
                      ),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.clock, size: 13, color: theme.primaryColorLight),
                          const SizedBox(width: 5),
                          Text(context.tr('lastLogin'), style: const TextStyle(fontSize: 12)),
                          Text(
                            dateTimeFormat.format(tz.TZDateTime.from(lastLoginDate, bangkok)),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 6),
                          SortIconWidget(columnName: 'status.lastLogin.date', getDataOnUpdate: widget.getDataOnUpdate)
                        ],
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cake,
                        size: 14,
                        color: theme.primaryColorLight,
                      ),
                      const SizedBox(width: 3),
                      Text('${context.tr('dob')} :'),
                      Text(
                        " ${patientProfile.dob is String ? '---- -- --' : DateFormat("dd MMM yyyy").format(patientProfile.dob.toLocal())}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      SortIconWidget(columnName: 'profile.dob', getDataOnUpdate: widget.getDataOnUpdate)
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        bloodGValues.firstWhere(
                              (bg) => bg['title'] == patientProfile.bloodG,
                              orElse: () => {'icon': '❓'},
                            )['icon'] ??
                            '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 5),
                      Text('${context.tr('bloodG')} : '),
                      Text(patientProfile.bloodG),
                      const SizedBox(width: 6),
                      SortIconWidget(columnName: 'profile.bloodG', getDataOnUpdate: widget.getDataOnUpdate)
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.userClock,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text('${context.tr('age')} :'),
                      const SizedBox(width: 5),
                      Text(
                        "$years ${context.tr('years')}, $months ${context.tr('month')}, $days ${context.tr('days')}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                      const SizedBox(width: 5),
                      Text('${context.tr('city')} '),
                      Text(patientProfile.city == '' ? '---' : patientProfile.city),
                      const SizedBox(width: 6),
                      SortIconWidget(columnName: 'profile.city', getDataOnUpdate: widget.getDataOnUpdate)
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                      const SizedBox(width: 3),
                      Text('${context.tr('state')} '),
                      Text(patientProfile.state == '' ? '---' : patientProfile.state),
                      const SizedBox(width: 3),
                      SortIconWidget(columnName: 'profile.state', getDataOnUpdate: widget.getDataOnUpdate)
                    ],
                  ),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.mapMarked, size: 13, color: theme.primaryColorLight),
                      const SizedBox(width: 5),
                      Text('${context.tr('country')} '),
                      Text(patientProfile.country == '' ? '---' : patientProfile.country),
                      const SizedBox(width: 6),
                      SortIconWidget(columnName: 'profile.country', getDataOnUpdate: widget.getDataOnUpdate)
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    height: 40,
                    child: GradientButton(
                      onPressed: () {
                        context.push(
                          Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                        );
                      },
                      colors: [
                        Theme.of(context).primaryColorLight,
                        Theme.of(context).primaryColor,
                      ],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.eye, size: 13, color: textColor),
                          const SizedBox(width: 5),
                          Text(
                            context.tr("view"),
                            style: TextStyle(fontSize: 12, color: textColor),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SortIconWidget extends StatefulWidget {
  final String columnName;
  final VoidCallback getDataOnUpdate;
  const SortIconWidget({
    super.key,
    required this.columnName,
    required this.getDataOnUpdate,
  });

  @override
  State<SortIconWidget> createState() => _SortIconWidgetState();
}

class _SortIconWidgetState extends State<SortIconWidget> {
  late final DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final FavouriteService favouriteService = FavouriteService();
  bool _isProvidersInitialized = false;
  Future<void> updateSort(List<Map<String, dynamic>> newSortModel) async {
    dataGridProvider.setSortModel(newSortModel);
    widget.getDataOnUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String direction = dataGridProvider.sortModel.first['sort'] == 'asc' ? 'desc' : 'asc';
    return GestureDetector(
      onTap: () {
        updateSort([
          {"field": widget.columnName, "sort": direction}
        ]);
      },
      child: FaIcon(direction == 'desc' ? FontAwesomeIcons.arrowAltCircleDown : FontAwesomeIcons.arrowAltCircleUp,
          size: 16, color: Theme.of(context).primaryColor),
      // Icon(
      //  Icons.unfold_more,
      //   size: 16,
      //   color: Theme.of(context).primaryColor,
      // ),
    );
  }
}
