
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/bill_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/bill_service.dart';
import 'package:health_care/shared/dashboard_main_card_under_header.dart';
import 'package:health_care/shared/patient_doctor_profile_header.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/patients/check-out/bill_pay_details.dart';
import 'package:health_care/src/features/patients/check-out/bill_summary_card.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class BillCheckOut extends StatefulWidget {
  static const String routeName = "/patient/check-out";

  final String billingId;
  const BillCheckOut({
    super.key,
    required this.billingId,
  });

  @override
  State<BillCheckOut> createState() => _BillCheckOutState();
}

class _BillCheckOutState extends State<BillCheckOut> {
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  final BillService billService = BillService();
  late final BillProvider billProvider;
  late final AuthProvider authProvider;
  bool _isProvidersInitialized = false;
  bool _hasRedirected = false;
  double scrollPercentage = 0;
  bool isLoading = true;
  Future<void> getDataOnUpdate() async {
    String patientId = authProvider.patientProfile!.userId;
    await billService.getSingleBillingForPatient(
      context,
      widget.billingId,
      patientId,
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
      billProvider = Provider.of<BillProvider>(context, listen: false);
      _isProvidersInitialized = false;
    }
  }

  @override
  void dispose() {
    socket.off('getSingleBillingForPatientReturn');
    socket.off('updateGetSingleBillingForPatientReturn');
    socket.off('updateBillingPaymentReturn');
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BillProvider, AuthProvider>(
      builder: (context, billProvider, authProvider, child) {
        final Bills? bill = billProvider.bill;
        final String roleName = authProvider.roleName;
        final PatientUserProfile patientUserProfile = authProvider.patientProfile!.userProfile;
        //Redirect if not login
        if (roleName.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.microtask(() {
              if (context.mounted) {
                context.go('/');
              }
            });
          });
        }
        // redirect if doctor
        if (roleName == 'doctors') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.microtask(() {
              if (context.mounted) {
                context.go('/doctors/dashboard');
              }
            });
          });
        }
        // show loading
        if (isLoading) {
          return ScaffoldWrapper(
            title: context.tr('billCheckout'),
            children: const Center(child: CircularProgressIndicator()),
          );
        }

        //Redirect if id is empty
        if (!isLoading && (bill!.id.isEmpty) && !_hasRedirected) {
          _hasRedirected = true;
          Future.microtask(() {
            if (context.mounted) {
              if (roleName == 'doctors') {
                context.go('/doctors/dashboard');
              } else {
                context.go('/patient/dashboard');
              }
            }
          });
        }
        // Redirect if payed already
        
        final ThemeData theme = Theme.of(context);
        return ScaffoldWrapper(
          title: context.tr('billCheckout'),
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
                      PatientDoctorProfileHeader(doctorUserProfile: bill!.doctorProfile),
                      DashboardMainCardUnderHeader(
                        children: [
                          // Booking Summary
                          BillSummaryCard(
                            bill: bill,
                          ),
                          // Billing Details
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 12,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: theme.primaryColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        context.tr('billingDetails'),
                                        style: TextStyle(fontSize: 20, color: theme.primaryColorLight),
                                      ),
                                    ),
                                    MyDivider(theme: theme),
                                    BillPayDetails(
                                      patientUserProfile: patientUserProfile,
                                      bill: bill,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
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
