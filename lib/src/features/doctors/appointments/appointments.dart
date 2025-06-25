import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/services/appointment_service.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/shared/custom_pagination_widget.dart';
import 'package:health_care/src/commons/fadein_widget.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/appointments/doctor_appointment_show_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class DoctorAppointments extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/appointments';
  const DoctorAppointments({super.key});

  @override
  State<DoctorAppointments> createState() => _DoctorAppointmentsState();
}

class _DoctorAppointmentsState extends State<DoctorAppointments> {
  final ScrollController scrollController = ScrollController();
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
    await appointmentService.getDoctorAppointments(context);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appointmentProvider.setLoading(true);
      getDataOnUpdate();
    });
    scrollController.addListener(loadMore);
  }

  void loadMore() async {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        limit = limit + 10;
        await appointmentService.getDoctorAppointments(context);
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
    dataGridProvider.setMongoFilterModel({}, notify: false);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(builder: (context, appointmentProvider, _) {
      final reservations = appointmentProvider.appointmentReservations;
      final isLoading = appointmentProvider.isLoading;
      final totalAppoint = appointmentProvider.total;
      
      return ScaffoldWrapper(
        title: context.tr('appointments'),
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
                                context.tr("totalReservations", args: ["$totalAppoint"]),
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
                    const SizedBox(height: 10),
                    CustomPaginationWidget(
                      count: totalAppoint,
                      getDataOnUpdate: getDataOnUpdate,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      restorationId: 'doctorAppointment',
                      key: const ValueKey('doctorAppointment'),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];
                        return DoctorAppointmentShowBox(
                          reservation: reservation,
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
          ],
        ),
      );
    });
  }
}
