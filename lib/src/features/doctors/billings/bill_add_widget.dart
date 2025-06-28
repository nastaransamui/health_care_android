import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/doctor_patient_profile_provider.dart';
import 'package:health_care/services/bills_service.dart';
import 'package:health_care/services/doctor_pateint_profile_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/billings/bill_details_form.dart';
import 'package:health_care/src/features/doctors/patient_profile/doctor_pateint_profile_header.dart';
import 'package:provider/provider.dart';

class BillAddWidget extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/add-billing';
  final String mongoPatientUserId;
  final String viewType;
  const BillAddWidget({
    super.key,
    required this.mongoPatientUserId,
    required this.viewType,
  });

  @override
  State<BillAddWidget> createState() => _BillAddWidgetState();
}

class _BillAddWidgetState extends State<BillAddWidget> {
  ScrollController scrollController = ScrollController();
  final DoctorPateintProfileService doctorPateintProfileService = DoctorPateintProfileService();
  final BillsService billsService = BillsService();
  late final DoctorPatientProfileProvider doctorPatientProfileProvider;
  DoctorsProfile? doctorsProfile;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  bool _hasRedirected = false;
  Future<void> getDataOnUpdate() async {
    doctorPateintProfileService.findDocterPatientProfileById(context, widget.mongoPatientUserId);
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
      doctorPatientProfileProvider = Provider.of<DoctorPatientProfileProvider>(context, listen: false);
      doctorsProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> onAddBillSubmit(
    double price,
    double bookingsFee,
    double bookingsFeePrice,
    double total,
    String currencySymbol,
    String dueDate,
    List<BillingsDetails> billingDetailsList,
  ) async {
    final List<Map<String, dynamic>> billDetailsArray = billingDetailsList.map((e) => e.toJson()).toList();

    Map<String, dynamic> payload = {
      "doctorId": doctorsProfile?.userId,
      "patientId": doctorPatientProfileProvider.patientProfile.id,
      "price": price,
      'bookingsFee': bookingsFee,
      "bookingsFeePrice": bookingsFeePrice,
      "total": total,
      "currencySymbol": currencySymbol,
      "paymentToken": "",
      "paymentType": "",
      "billDetailsArray": billDetailsArray,
      "status": "Pending",
      "paymentDate": "",
      "dueDate": DateFormat('d MMM yyyy').parse(dueDate).toIso8601String()
    };
    final String? newId = await billsService.updateBilling(context, payload);

    if (!mounted) return;
    if (newId == null) {
      showErrorSnackBar(context, context.tr('billRecordAddedFailed'));
    } else {
      final encodedPrescriptionId = base64.encode(utf8.encode(newId.toString()));
      context.push(Uri(path: '/doctors/dashboard/edit-billing/$encodedPrescriptionId').toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorPatientProfileProvider>(
      builder: (context, doctorPatientProfileProvider, child) {
        final DoctorPatientProfileModel doctorPatientProfile = doctorPatientProfileProvider.patientProfile;
        final bool isLoading = doctorPatientProfileProvider.isLoading;
        if (isLoading) {
          return ScaffoldWrapper(title: context.tr('loading'), children: const Center(child: CircularProgressIndicator()));
        }

        //Redirect if id is empty
        if ((doctorPatientProfile.id?.isEmpty ?? true) && !_hasRedirected) {
          _hasRedirected = true;
          Future.microtask(() {
            if (context.mounted) {
              context.push('/doctors/dashboard');
            }
          });
        }
        String viewType = widget.viewType;
        return ScaffoldWrapper(
          title: context.tr('${viewType}_bill'),
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
                      DoctorPateintProfileHeader(doctorPatientProfile: doctorPatientProfile),
                      Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Column(
                              children: [
                                BillDetailsForm(
                                  formType: 'add',
                                  onBillSubmit: onAddBillSubmit,
                                  billsDetailsList: [BillingsDetails.empty()],
                                  doctorsProfile: doctorsProfile!.userProfile,
                                )
                              ],
                            ),
                          ),
                        ),
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
