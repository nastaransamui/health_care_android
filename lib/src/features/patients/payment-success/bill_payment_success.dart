import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/bill_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/bill_service.dart';
import 'package:health_care/shared/dashboard_main_card_under_header.dart';
import 'package:health_care/shared/patient_doctor_profile_header.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/patients/check-out/bill_summary_card.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class BillPaymentSuccess extends StatefulWidget {
  static const String routeName = "/patient/payment-success";

  final String billingId;
  const BillPaymentSuccess({
    super.key,
    required this.billingId,
  });

  @override
  State<BillPaymentSuccess> createState() => _BillPaymentSuccessState();
}

class _BillPaymentSuccessState extends State<BillPaymentSuccess> {
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
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BillProvider, AuthProvider>(
      builder: (context, billProvider, authProvider, child) {
        final Bills? bill = billProvider.bill;
        final String roleName = authProvider.roleName;

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
        // show loading
        if (isLoading || bill == null) {
          return ScaffoldWrapper(
            title: context.tr('billPaidSuccessfuly'),
            children: const Center(child: CircularProgressIndicator()),
          );
        }

        //Redirect if id is empty
        if (!isLoading && (bill.id.isEmpty) && !_hasRedirected) {
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
        return ScaffoldWrapper(
          title: context.tr('billPaidSuccessfuly'),
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
                      PatientDoctorProfileHeader(doctorUserProfile: bill.doctorProfile),
                      DashboardMainCardUnderHeader(
                        children: [
                          BillPaymentSuccessCard(bill: bill),
                        ],
                      ),
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

class BillPaymentSuccessCard extends StatelessWidget {
  final Bills bill;
  const BillPaymentSuccessCard({
    super.key,
    required this.bill,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColorLight),
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: BoxBorder.all(color: theme.primaryColorLight),
                    color: theme.primaryColor,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 30,
                    color: textColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Center(
                  child: Text(
                    context.tr('billPaidSuccessfuly'),
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: theme.primaryColor),
                  ),
                ),
              ),
              BillSummaryCard(
                bill: bill,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Container(
                    height: 38,
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor,
                          theme.primaryColorLight,
                        ],
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(8),
                        right: Radius.circular(8),
                      ),
                    ),
                    padding: const EdgeInsets.all(1),
                    child: GestureDetector(
                      onTap: () {
                        final encodedBillId = base64.encode(utf8.encode(bill.id.toString()));
                        context.push(Uri(path: '/patient/dashboard/bill-view/$encodedBillId').toString());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColorLight,
                              theme.primaryColor,
                            ],
                          ),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(7),
                            right: Radius.circular(7),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            context.tr("viewInvoice"),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
