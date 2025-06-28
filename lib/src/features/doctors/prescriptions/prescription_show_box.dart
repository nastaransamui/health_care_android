import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/prescriptions.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/prescription_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/src/features/doctors/invoice/doctor_invoice_preview_screen.dart';
import 'package:health_care/src/features/doctors/prescriptions/build_patient_prescription_pdf.dart';
import 'package:health_care/src/features/patients/dependents/patients_dependants_show_box.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class PrescriptionShowBox extends StatefulWidget {
  final Prescriptions prescription;
  final VoidCallback getDataOnUpdate;
  final bool isExpanded;
  final void Function(int index) onToggle;
  final int index;
  const PrescriptionShowBox({
    super.key,
    required this.prescription,
    required this.getDataOnUpdate,
    required this.isExpanded,
    required this.onToggle,
    required this.index,
  });

  @override
  State<PrescriptionShowBox> createState() => _PrescriptionShowBoxState();
}

class _PrescriptionShowBoxState extends State<PrescriptionShowBox> {
  late final String roleName;
  final PrescriptionService prescriptionService = PrescriptionService();
  DoctorsProfile? doctorsProfile;
  bool _isProvidersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      roleName = Provider.of<AuthProvider>(context, listen: false).roleName;

      doctorsProfile = Provider.of<AuthProvider>(context, listen: false).doctorsProfile;

      _isProvidersInitialized = true;
    }
  }

  @override
  void dispose() {
    socket.off('deletePriscriptionRecordReturn');
    super.dispose();
  }

  Future<void> showConfirmDeleteScafold(BuildContext context, String doctorId, String deleteId) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColorLight,
            title: Text(context.tr('deletePrescription')),
            automaticallyImplyLeading: false, // Removes the back button
            actions: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
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
                        context.tr("prescriptionDeleteConfirm"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).primaryColor,
                        ),
                      )),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, deleteId);
                    },
                    child: Text(context.tr("submit")),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    if (!context.mounted) return;

    if (result != null) {
      deleteRecordRequestSubmit(context, doctorId, deleteId);
    }
  }

  Future<void> deleteRecordRequestSubmit(BuildContext context, String doctorId, String deleteId) async {
    bool success = await prescriptionService.deletePriscriptionRecord(context, doctorId, deleteId);

    if (success) {
      if (context.mounted) {
        showErrorSnackBar(context, "Prescription was deleted sucessfully.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Prescriptions prescription = widget.prescription;
    final DoctorUserProfile doctorProfile = prescription.doctorProfile;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final bangkok = tz.getLocation('Asia/Bangkok');
    final bool isSameDoctor = roleName == 'doctors' && doctorsProfile?.userId == prescription.doctorId;
    final String speciality = doctorProfile.specialities.first.specialities;
    final String specialityImage = doctorProfile.specialities.first.image;
    final uri = Uri.parse(specialityImage);
    final imageIsSvg = uri.path.endsWith('.svg');
    final String doctorName = "Dr. ${doctorProfile.fullName}";
    final String doctorProfileImage = doctorProfile.profileImage;
    final ImageProvider<Object> finalImage = doctorProfileImage.isEmpty
        ? const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider
        : CachedNetworkImageProvider(doctorProfileImage);
    final encodedPrescriptionId = base64.encode(utf8.encode(prescription.id.toString()));
    final encodeddoctorId = base64.encode(utf8.encode(prescription.doctorId.toString()));
    final Color statusColor = doctorProfile.idle ?? false
        ? const Color(0xFFFFA812)
        : doctorProfile.online
            ? const Color(0xFF44B700)
            : const Color.fromARGB(255, 250, 18, 2);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        color: theme.canvasColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //profile row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        splashColor: theme.primaryColorLight,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        onTap: () {
                          context.push(Uri(path: '/doctors/profile/$encodeddoctorId').toString());
                        },
                        child: Container(
                          width: 80,
                          height: 80,
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
                            SortIconWidget(
                              columnName: 'doctorProfile.fullName',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
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
                            SortIconWidget(
                              columnName: 'doctorProfile.specialities.0.specialities',
                              getDataOnUpdate: widget.getDataOnUpdate,
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '#${prescription.prescriptionId}',
                                style: TextStyle(color: theme.primaryColorLight),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(columnName: 'id', getDataOnUpdate: widget.getDataOnUpdate),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //Divider
              MyDevider(theme: theme),
              // createdAt
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('${context.tr('createdAt')}: '),
                          Text(
                            DateFormat('dd MMM yyyy HH:mm').format(
                              tz.TZDateTime.from(prescription.createdAt, bangkok),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'createdAt',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              //Divider
              MyDevider(theme: theme),
              // updateAt
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('${context.tr('updateAt')}: '),
                          Text(
                            DateFormat('dd MMM yyyy HH:mm').format(
                              tz.TZDateTime.from(prescription.updateAt, bangkok),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'updateAt',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDevider(theme: theme),
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 35,
                        child: GradientButton(
                          onPressed: () {
                            if (roleName == 'doctors') {
                              context.push(Uri(path: '/doctors/dashboard/editprescription/$encodedPrescriptionId').toString());
                            }
                            if (roleName == 'patient') {
                              context.push(Uri(path: '/patient/dashboard/see-prescription/$encodedPrescriptionId').toString());
                            }
                          },
                          colors: [
                            Theme.of(context).primaryColorLight,
                            Theme.of(context).primaryColor,
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(isSameDoctor ? FontAwesomeIcons.edit : FontAwesomeIcons.eye, size: 13, color: textColor),
                              const SizedBox(width: 5),
                              Text(
                                context.tr(isSameDoctor ? "edit" : "view"),
                                style: TextStyle(fontSize: 12, color: textColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: SizedBox(
                        height: 35,
                        child: GradientButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            Future.delayed(Duration.zero, () async {
                              if (!context.mounted) return;

                              try {
                                final pdf = await buildPatientPrescriptionPdf(context, prescription);
                                final bytes = await pdf.save();

                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                await showModalBottomSheet<Map<String, dynamic>>(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  builder: (context) => FractionallySizedBox(
                                    heightFactor: 1,
                                    child: DoctorInvoicePreviewScreen(
                                      pdfBytes: bytes,
                                      title: Text(context.tr('prescriptionPreview')),
                                    ),
                                  ),
                                );
                                // });
                              } catch (e) {
                                debugPrint('PDF Error: $e');
                              }
                            });
                          },
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColorLight,
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.print, size: 13, color: textColor),
                              const SizedBox(width: 5),
                              Text(
                                context.tr("print"),
                                style: TextStyle(fontSize: 12, color: textColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (roleName == 'doctors') ...[
                      const SizedBox(width: 5),
                      Expanded(
                        child: SizedBox(
                          height: 35,
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.pink,
                                  Colors.red,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.07,
                                ),
                              ),
                              onPressed: !isSameDoctor
                                  ? null
                                  : () {
                                      showConfirmDeleteScafold(context, prescription.doctorId, prescription.id);
                                    },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete, size: 13, color: !isSameDoctor ? Colors.black : textColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    context.tr("delete"),
                                    style: TextStyle(fontSize: 12, color: !isSameDoctor ? Colors.black : textColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              MyDevider(theme: theme),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => widget.onToggle(widget.index),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${context.tr('prescriptions')} :", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Icon(
                      widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: widget.isExpanded ? theme.primaryColorLight : theme.primaryColor,
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: widget.isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Wrap(spacing: 8, runSpacing: 8, children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              height: 1,
                              color: theme.primaryColorLight,
                            ),
                          ),
                          // Header Row
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(context.tr('medicine')),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 5,
                                child: Text(context.tr('description')),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  context.tr('quantity'),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              height: 1,
                              color: theme.primaryColorLight,
                            ),
                          ),
                          // Data Rows
                          ...prescription.prescriptionsArray.map(
                            (PrescriptionDetails detail) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        detail.medicine,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        detail.description,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(color: textColor),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'x${detail.quantity}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(color: theme.primaryColorLight, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ]),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
