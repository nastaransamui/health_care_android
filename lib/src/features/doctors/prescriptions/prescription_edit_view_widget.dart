import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/models/prescriptions.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/doctor_patient_profile_provider.dart';
import 'package:health_care/services/prescription_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/patient_doctor_profile_header.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/features/doctors/patient_profile/doctor_pateint_profile_header.dart';
import 'package:health_care/src/features/doctors/prescriptions/prescription_add_widget.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class PrescriptionEditViewWidget extends StatefulWidget {
  static const String routeName = '/doctors/dashboard/editprescription';
  final String prescriptionMongoId;
  final String viewType;
  const PrescriptionEditViewWidget({
    super.key,
    required this.prescriptionMongoId,
    required this.viewType,
  });

  @override
  State<PrescriptionEditViewWidget> createState() => _PrescriptionEditViewWidgetState();
}

class _PrescriptionEditViewWidgetState extends State<PrescriptionEditViewWidget> {
  final PrescriptionService prescriptionService = PrescriptionService();
  ScrollController scrollController = ScrollController();
  late final DoctorPatientProfileProvider doctorPatientProfileProvider;
  late final AuthProvider authProvider;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  DoctorsProfile? doctorsProfile;
  bool _hasRedirected = false;

  Future<void> getDataOnUpdate() async {
    prescriptionService.findPrescriptionForDoctorProfileById(context, widget.prescriptionMongoId);
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
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      doctorsProfile = authProvider.doctorsProfile;
      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('findPrescriptionForDoctorProfileByIdReturn');
    socket.off('updatefindPrescriptionForDoctorProfileById');
    socket.off("editPrescriptionReturn");
    super.dispose();
  }

  Future<void> onPrescriptionEditSubmit(List<PrescriptionDetails> prescriptionDetailsList, Prescriptions singlePrescription) async {
    final List<Map<String, dynamic>> prescriptionsArray = prescriptionDetailsList.map((e) => e.toJson()).toList();

    Map<String, dynamic> payload = {
      "_id": singlePrescription.id,
      "doctorId": doctorsProfile?.userId,
      "patientId": doctorPatientProfileProvider.patientProfile.id,
      "prescriptionsArray": prescriptionsArray,
      "createdAt": singlePrescription.createdAt.toIso8601String(),
      "id": singlePrescription.prescriptionId,
    };
    // Show loading
    if (!mounted) return;
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      showDragHandle: false,
      useSafeArea: true,
      context: context,
      builder: (context) => const LoadingScreen(),
    );
    bool success = await prescriptionService.editPrescription(context, payload);
    if (!mounted) return;
    Navigator.of(context).pop(); // Hide loading

    if (!mounted) return;
    if (success) {
      showErrorSnackBar(context, context.tr("editPrescriptionSuccess")); // or dialog, etc.
    } else {
      showErrorSnackBar(context, context.tr("editPrescriptionFailed"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DoctorPatientProfileProvider, AuthProvider>(builder: (context, doctorPatientProfileProvider, authProvider, child) {
      final theme = Theme.of(context);
      final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
      final String roleName = authProvider.roleName;
      final DoctorPatientProfileModel doctorPatientProfile = doctorPatientProfileProvider.patientProfile;
      final bool isLoading = doctorPatientProfileProvider.isLoading;
      // final ThemeData theme = Theme.of(context);
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
      final String formType = doctorsProfile?.userId == doctorPatientProfile.singlePrescription?.doctorId ? 'edit' : 'view';
      final DoctorUserProfile prescriptionDoctorProfile = doctorPatientProfile.singlePrescription!.doctorProfile;
      final String speciality = prescriptionDoctorProfile.specialities.first.specialities;
      final String specialityImage = prescriptionDoctorProfile.specialities.first.image;
      final bangkok = tz.getLocation(dotenv.env['TZ']!);
      final uri = Uri.parse(specialityImage);
      final imageIsSvg = uri.path.endsWith('.svg');
      final String doctorName = "Dr. ${prescriptionDoctorProfile.fullName}";
      final String doctorProfileImage = prescriptionDoctorProfile.profileImage;
      final encodeddoctorId = base64.encode(utf8.encode(doctorPatientProfile.singlePrescription!.doctorId.toString()));
      final ImageProvider<Object> finalImage = doctorProfileImage.isEmpty
          ? const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider
          : CachedNetworkImageProvider(doctorProfileImage);
      final Color statusColor = prescriptionDoctorProfile.idle ?? false
          ? const Color(0xFFFFA812)
          : prescriptionDoctorProfile.online
              ? const Color(0xFF44B700)
              : const Color.fromARGB(255, 250, 18, 2);
      return ScaffoldWrapper(
          title: context.tr('${formType}_prescription'),
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
                      roleName == 'doctors'
                          ? DoctorPateintProfileHeader(doctorPatientProfile: doctorPatientProfile)
                          : PatientDoctorProfileHeader(doctorUserProfile: prescriptionDoctorProfile),
                      Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10.0, right: 16.0, bottom: 16.0, left: 16.0),
                              child: Column(
                                children: [
                                  OriginalDoctorPrescription(
                                    theme: theme,
                                    encodeddoctorId: encodeddoctorId,
                                    finalImage: finalImage,
                                    statusColor: statusColor,
                                    doctorName: doctorName,
                                    imageIsSvg: imageIsSvg,
                                    specialityImage: specialityImage,
                                    speciality: speciality,
                                    doctorPatientProfile: doctorPatientProfile,
                                    bangkok: bangkok,
                                    textColor: textColor,
                                    formType: formType,
                                  ),
                                  PrescriptionDetailsForm(
                                    formType: formType,
                                    onPrescriptionSubmit: (List<PrescriptionDetails> prescriptionDetailsList) async {
                                      onPrescriptionEditSubmit(prescriptionDetailsList, doctorPatientProfile.singlePrescription!);
                                    },
                                    prescriptionDetailsList: doctorPatientProfile.singlePrescription!.prescriptionsArray,
                                  )
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
            ],
          ));
    });
  }
}

class OriginalDoctorPrescription extends StatelessWidget {
  const OriginalDoctorPrescription({
    super.key,
    required this.theme,
    required this.encodeddoctorId,
    required this.finalImage,
    required this.statusColor,
    required this.doctorName,
    required this.imageIsSvg,
    required this.specialityImage,
    required this.speciality,
    required this.doctorPatientProfile,
    required this.bangkok,
    required this.textColor,
    required this.formType,
  });

  final ThemeData theme;
  final String encodeddoctorId;
  final ImageProvider<Object> finalImage;
  final Color statusColor;
  final String doctorName;
  final bool imageIsSvg;
  final String specialityImage;
  final String speciality;
  final DoctorPatientProfileModel doctorPatientProfile;
  final tz.Location bangkok;
  final Color textColor;
  final String formType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        color: theme.canvasColor,
        elevation: 12,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (formType != 'edit')
                  Stack(
                    children: [
                      InkWell(
                        splashColor: theme.primaryColorLight,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        onTap: () {
                          context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: theme.primaryColorLight),
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            image: DecorationImage(fit: BoxFit.contain, image: finalImage),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        bottom: 10,
                        child: AvatarGlow(
                          glowColor: statusColor,
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
                      ),
                    ],
                  ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
                              },
                              child: Text(
                                doctorName,
                                style: TextStyle(
                                  color: theme.primaryColorLight,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '#${doctorPatientProfile.singlePrescription?.prescriptionId}',
                            style: TextStyle(color: textColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                imageIsSvg
                                    ? SvgPicture.network(
                                        specialityImage,
                                        width: 15,
                                        height: 15,
                                        fit: BoxFit.fitHeight,
                                      )
                                    : SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CachedNetworkImage(
                                          imageUrl: specialityImage,
                                          fadeInDuration: const Duration(milliseconds: 0),
                                          fadeOutDuration: const Duration(milliseconds: 0),
                                          errorWidget: (ccontext, url, error) {
                                            return Image.asset(
                                              'assets/images/default-avatar.png',
                                            );
                                          },
                                        ),
                                      ),
                                const SizedBox(width: 5),
                                Text(
                                  speciality,
                                  style: const TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMM yyyy HH:mm').format(tz.TZDateTime.from(doctorPatientProfile.singlePrescription!.updateAt, bangkok)),
                            style: TextStyle(color: textColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
