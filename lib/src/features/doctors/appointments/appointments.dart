import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/services/appointment_service.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/appointments/doctor_appointment_show_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class DoctorAppointments extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/appointments';
  const DoctorAppointments({super.key});

  @override
  State<DoctorAppointments> createState() => _DoctorAppointmentsState();
}

class _DoctorAppointmentsState extends State<DoctorAppointments> {
  final ScrollController appointmentScrollController = ScrollController();
  final AppointmentService appointmentService = AppointmentService();
  late AppointmentProvider appointmentProvider;
  late AuthProvider authProvider;
  late DataGridProvider dataGridProvider;
  final AuthService authService = AuthService();

  int limit = 10;
  int currentPage = 0;

  bool _isAppointmentProviderInitialized = false;
  double scrollPercentage = 0;

  Future<void> getDataOnUpdate() async {
    await appointmentService.getDoctorAppointments(context, limit);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appointmentProvider.setLoading(true);
      getDataOnUpdate();
    });
    appointmentScrollController.addListener(loadMore);
  }

  void loadMore() async {
    if (appointmentScrollController.hasClients) {
      if (appointmentScrollController.position.pixels == appointmentScrollController.position.maxScrollExtent) {
        limit = limit + 10;
        await appointmentService.getDoctorAppointments(context, limit);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAppointmentProviderInitialized) {
      appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
      _isAppointmentProviderInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('getDoctorAppointmentsReturn');
    socket.off('updateGetDoctorAppointments');
    appointmentProvider.setTotal(0, notify: false);
    appointmentProvider.setLoading(false, notify: false);
    appointmentProvider.setAppointmentReservations([], notify: false);
    appointmentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(builder: (context, appointmentProvider, _) {
      final reservations = appointmentProvider.appointmentReservations;
      final isLoading = appointmentProvider.isLoading;
      final doctorProfile = authProvider.doctorsProfile;
      final theme = Theme.of(context);

      // This is the total number of reservations that *should* be available eventually.
      final int totalReservationsExpected = doctorProfile?.userProfile.reservationsId.length ?? 0;

      // Determine the actual itemCount for the ListView.
      // It's the number of currently loaded reservations plus 1 if loading and more data is expected.
      int actualItemCount = reservations.length;
      if (isLoading && reservations.length < totalReservationsExpected) {
        actualItemCount++; // Add a slot for the loading indicator
      }
      return ScaffoldWrapper(
        title: context.tr('appointments'),
        children: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            double per = 0;
            if (appointmentScrollController.hasClients) {
              per = ((appointmentScrollController.offset / appointmentScrollController.position.maxScrollExtent));
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
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColorLight),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          context.tr("totalReservations", args: ["$totalReservationsExpected"]),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (reservations.isEmpty && isLoading)
                Center(
                  child: SizedBox(
                    height: 100, // Adjust size as needed
                    width: 100,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballRotateChase,
                      colors: [theme.primaryColorLight, theme.primaryColor],
                      strokeWidth: 2.0,
                      pathBackgroundColor: null,
                    ),
                  ),
                )
              else if (reservations.isEmpty && !isLoading) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 6,
                    color: theme.canvasColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: theme.primaryColor),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 200,
                        maxWidth: double.infinity,
                      ),
                      child: Center(
                        child: Text(context.tr('noHaveBookingYet')),
                      ),
                    ),
                  ),
                )
              ] else
                Expanded(
                  child: Stack(
                    children: [
                      ListView.builder(
                          controller: appointmentScrollController,
                          shrinkWrap: true,
                          restorationId: 'doctorAppointment',
                          key: const ValueKey('doctorAppointment'),
                          physics: const BouncingScrollPhysics(),
                          // Item count is total reservations + 1 loader if loading and not at end
                          itemCount: actualItemCount,
                          itemBuilder: (context, index) {
                            // If it's the last item and we're loading AND expecting more, show loader
                            if (index == reservations.length) {
                              // This will be the extra slot for the loader
                              if (isLoading && reservations.length < totalReservationsExpected) {
                                return Center(
                                  child: Padding(
                                    // Add padding to separate from last item
                                    padding: const EdgeInsets.all(16.0),
                                    child: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: LoadingIndicator(
                                          indicatorType: Indicator.ballRotateChase,
                                          colors: [theme.primaryColorLight, theme.primaryColor],
                                          strokeWidth: 2.0,
                                          pathBackgroundColor: null),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink(); // Should not happen if logic is correct
                            }

                            // Otherwise, display a reservation
                            final reservation = reservations[index];
                            return DoctorAppointmentShowBox(
                              reservation: reservation,
                            );
                          }),
                      ScrollButton(
                        scrollController: appointmentScrollController,
                        scrollPercentage: scrollPercentage,
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      );
    });
  }
}
