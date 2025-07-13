import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/reservation.dart';
// import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/reservation_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/reservation_service.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/invoice-view/export_as_pdf_button.dart';
import 'package:health_care/src/features/doctors/invoice-view/inline_pdf_preview.dart';
import 'package:health_care/src/features/doctors/invoice-view/invoice_go_back_button.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class InvoiceView extends StatefulWidget {
  static const String routeName = '/doctors/invoice-view/';
  final String reservationId;
  const InvoiceView({
    super.key,
    required this.reservationId,
  });

  @override
  State<InvoiceView> createState() => _InvoiceViewState();
}

class _InvoiceViewState extends State<InvoiceView> {
  final ScrollController scrollController = ScrollController();
  bool isLoading = true;
  late final AuthProvider authProvider;
  final AuthService authService = AuthService();
  late ReservationProvider reservationProvider;
  final ReservationService reservationService = ReservationService();
  bool _isProvidersInitialized = false;
  bool _hasRedirected = false;
  double scrollPercentage = 0;
  Future<void> getDataOnUpdate() async {
    await reservationService.findReservationById(
      context,
      widget.reservationId,
      () {
        if (context.mounted) {
          setState(() => isLoading = false);
        }
      },
    );
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
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('findReservationByIdReturn');
    socket.off('updateReservationById');
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReservationProvider, AuthProvider>(
      builder: (context, reservationProvider, authProvider, child) {
        final Reservation? reservation = reservationProvider.reservation;
        final String roleName = authProvider.roleName;
        // final PatientUserProfile? userProfile = authProvider.patientProfile?.userProfile;
        if (roleName.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.microtask(() {
              if (context.mounted) {
                context.go('/doctors/search/');
              }
            });
          });
        }
        if (isLoading) {
          return ScaffoldWrapper(
            title: context.tr('invoiceView'),
            children: const Center(child: CircularProgressIndicator()),
          );
        }
        //Redirect if id is empty
        if (!isLoading && (reservation!.id.isEmpty) && !_hasRedirected) {
          _hasRedirected = true;
          Future.microtask(() {
            if (context.mounted) {
              context.go('/doctors/search');
            }
          });
        }
        return ScaffoldWrapper(
          title: context.tr('invoiceView'),
          children: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  double per = 0;
                  if (scrollController.hasClients) {
                    per = (scrollController.offset / scrollController.position.maxScrollExtent);
                  }
                  if (per >= 0) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExportAsPdfButton(
                        reservation: reservation!,
                        // userProfile: userProfile!,
                      ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : InlinePdfPreview(
                              reservation: reservation,
                              // userProfile: userProfile,
                            ),
                      InvoiceGoBackButton(roleName: roleName),
                    ],
                  ),
                ),
              ),
              ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
            ],
          ),
        );
      },
    );
  }
}
