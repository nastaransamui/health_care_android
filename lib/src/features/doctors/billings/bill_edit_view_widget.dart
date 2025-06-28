
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
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/patient_doctor_profile_header.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/billings/bill_details_form.dart';
import 'package:health_care/src/features/doctors/patient_profile/doctor_pateint_profile_header.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class BillEditViewWidget extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/edit-billing';
  final String billMongoId;
  final String viewType;
  final String userType;
  const BillEditViewWidget({
    super.key,
    required this.billMongoId,
    required this.viewType,
    required this.userType,
  });

  @override
  State<BillEditViewWidget> createState() => _BillEditViewWidgetState();
}

class _BillEditViewWidgetState extends State<BillEditViewWidget> {
  final BillsService billsService = BillsService();
  ScrollController scrollController = ScrollController();
  late final DoctorPatientProfileProvider doctorPatientProfileProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  DoctorsProfile? doctorsProfile;
  bool _hasRedirected = false;

  Future<void> getDataOnUpdate() async {
    billsService.findBillingForDoctorProfileById(context, widget.billMongoId);
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
    socket.off('findBillingForDoctorProfileByIdReturn');
    socket.off('updatefindBillingForDoctorProfileById');
    // socket.off("editPrescriptionReturn");
    super.dispose();
  }

  Future<void> onBillEditSubmit(BuildContext context, Map<String, dynamic> payload) async {
    // Show loading
    if (!context.mounted) return;
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      showDragHandle: false,
      useSafeArea: true,
      context: context,
      builder: (context) => const LoadingScreen(),
    );
    final String? newId = await billsService.updateBilling(context, payload);

    if (!context.mounted) return;

    Navigator.of(context).pop();
    if (!context.mounted) return;
    if (newId == null) {
      showErrorSnackBar(context, context.tr('billRecordEditFailed'));
    } else {
      showErrorSnackBar(context, context.tr('billRecordEditSuccess'));
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
        final Bills? singleBill = doctorPatientProfile.singleBill;
        final String formType = doctorsProfile?.userId == singleBill?.doctorId ? 'edit' : 'view';
        return ScaffoldWrapper(
          title: context.tr('${formType}_bill'),
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
                      if (widget.userType == 'doctors') ...[
                        DoctorPateintProfileHeader(doctorPatientProfile: doctorPatientProfile),
                      ] else
                        ...[
                          PatientDoctorProfileHeader(doctorUserProfile: singleBill!.doctorProfile),
                        ],
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
                                  formType: formType,
                                  doctorsProfile: singleBill?.doctorProfile,
                                  onBillSubmit: (
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
                                      "_id": singleBill.id,
                                      "id": singleBill.billId,
                                      "doctorId": singleBill.doctorId,
                                      "patientId": singleBill.patientId,
                                      "price": price,
                                      "bookingsFee": bookingsFee,
                                      "bookingsFeePrice": bookingsFeePrice,
                                      "total": total,
                                      "currencySymbol": currencySymbol,
                                      "paymentToken": singleBill.paymentToken,
                                      "paymentType": singleBill.paymentType,
                                      "billDetailsArray": billDetailsArray,
                                      "createdAt": singleBill.createdAt.toIso8601String(),
                                      "updateAt": singleBill.updateAt.toIso8601String(),
                                      "invoiceId": singleBill.invoiceId,
                                      "status": singleBill.status,
                                      "paymentDate": singleBill.paymentDate != null && singleBill.paymentDate is DateTime
                                          ? (singleBill.paymentDate as DateTime).toIso8601String()
                                          : '',
                                      "dueDate": singleBill.dueDate.toIso8601String(),
                                    };
                                    onBillEditSubmit(context, payload);
                                  },
                                  billsDetailsList: singleBill!.billDetailsArray,
                                  invoiceId: singleBill.invoiceId,
                                  createdAt: singleBill.createdAt,
                                  dueDate: singleBill.dueDate,
                                  status: singleBill.status,
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
