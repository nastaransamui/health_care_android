import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/bill_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/bill_service.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/patients/bill-view/bill_go_back_button.dart';
import 'package:health_care/src/features/patients/bill-view/export_bill_as_pdf_button.dart';
import 'package:health_care/src/features/patients/bill-view/inline_bill_pdf_preview.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class BillInvoice extends StatefulWidget {
  static const String routeName = "/patient/dashboard/bill-view";

  final String billingId;
  final String? patientId;
  const BillInvoice({
    super.key,
    required this.billingId,
    this.patientId,
  });

  @override
  State<BillInvoice> createState() => _BillInvoiceState();
}

class _BillInvoiceState extends State<BillInvoice> {
  final ScrollController scrollController = ScrollController();
  bool isLoading = true;
  late final AuthProvider authProvider;
  final AuthService authService = AuthService();
  final BillService billService = BillService();
  late final BillProvider billProvider;
  bool _isProvidersInitialized = false;
  bool _hasRedirected = false;
  double scrollPercentage = 0;
  Future<void> getDataOnUpdate() async {
    String roleName = authProvider.roleName;
    late String patientId;
    if (roleName == 'patient') {
      patientId = authProvider.patientProfile!.userId;
    } else {
      patientId = widget.patientId!;
    }
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
        if (roleName.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.microtask(() {
              if (context.mounted) {
                context.push('/');
              }
            });
          });
        }
        if (isLoading) {
          return ScaffoldWrapper(
            title: context.tr('billView'),
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
        bool isSameDoctor = false;
        if (roleName == 'doctors') {
          final String currentDoctorId = authProvider.doctorsProfile!.userId;
          isSameDoctor = currentDoctorId == bill!.doctorId;
        }
        return ScaffoldWrapper(
          title: context.tr('billView'),
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
                      ExportBillAsPdfButton(
                        bill: bill!,
                        isSameDoctor: widget.billingId.isNotEmpty,
                      ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : InlineBillPdfPreview(
                              bill: bill,
                              isSameDoctor: isSameDoctor,
                            ),
                      BillGoBackButton(roleName: roleName)
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
