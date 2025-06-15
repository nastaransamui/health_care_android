import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/providers/billing_provider.dart';
import 'package:health_care/providers/doctor_patient_profile_provider.dart';
import 'package:health_care/providers/medical_records_provider.dart';
import 'package:health_care/providers/patient_appointment_provider.dart';
import 'package:health_care/providers/prescription_provider.dart';
import 'package:health_care/providers/widget_injection_provider.dart';
import 'package:health_care/src/features/doctors/patient_profile/dcoctor_pateint_profile_header.dart';
import 'package:health_care/src/features/doctors/patient_profile/four_card_pateint_doctor_lottie.dart';
import 'package:health_care/src/features/patients/appointments/patient_appointments.dart';
import 'package:health_care/src/features/patients/billings/patient_billings.dart';
import 'package:health_care/src/features/patients/medicalRecords/patient_medical_records.dart';
import 'package:health_care/src/features/doctors/prescriptions/patient_prescriptions.dart';
import 'package:provider/provider.dart';

class FourCardDoctorPatientProfile extends StatefulWidget {
  const FourCardDoctorPatientProfile({
    super.key,
    required this.doctorPatientProfile,
  });

  final DoctorPatientProfileModel doctorPatientProfile;

  @override
  State<FourCardDoctorPatientProfile> createState() => _FourCardDoctorPatientProfileState();
}

class _FourCardDoctorPatientProfileState extends State<FourCardDoctorPatientProfile> {
  final List<String> cardTitles = const [
    'drPatientappointment',
    'drPatientprescription',
    'drPatientmedicalRecord',
    'drPatientbilling',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: Theme.of(context).canvasColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).primaryColorLight),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: cardTitles.map((title) {
            final int length = title == 'drPatientappointment'
                ? widget.doctorPatientProfile.reservationsId.length
                : title == 'drPatientprescription'
                    ? widget.doctorPatientProfile.prescriptionsId.length
                    : title == 'drPatientmedicalRecord'
                        ? widget.doctorPatientProfile.medicalRecordsArray.length
                        : widget.doctorPatientProfile.billingsIds.length;

            return InkWell(
              splashColor: theme.primaryColor.withAlpha((0.5 * 255).round()),
              onTap: () {
                final Widget modalWidget = title == 'drPatientappointment'
                    ? FractionallySizedBox(
                        heightFactor: 1,
                        child: MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              create: (context) => PatientAppointmentProvider(),
                            ),
                            ChangeNotifierProvider(
                              create: (context) => WidgetInjectionProvider(),
                            ),
                            ChangeNotifierProvider.value(
                              value: context.read<DoctorPatientProfileProvider>(),
                            ),
                          ],
                          child: Builder(
                            builder: (context) {
                              // Now the provider is available!
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context.read<WidgetInjectionProvider>().inject(
                                  Consumer<DoctorPatientProfileProvider>(
                                    builder: (context, provider, _) {
                                      return DcoctorPateintProfileHeader(
                                        doctorPatientProfile: provider.patientProfile,
                                      );
                                    },
                                  ),
                                );
                              });

                              return PatientAppointments(
                                patientId: widget.doctorPatientProfile.id!,
                                doctorPatientProfile: widget.doctorPatientProfile,
                              );
                            },
                          ),
                        ),
                      )
                    : title == 'drPatientprescription'
                        ? FractionallySizedBox(
                            heightFactor: 1,
                            child: MultiProvider(
                              providers: [
                                ChangeNotifierProvider(
                                  create: (context) => PrescriptionProvider(),
                                ),
                                ChangeNotifierProvider(
                                  create: (context) => WidgetInjectionProvider(),
                                ),
                                ChangeNotifierProvider.value(
                                  value: context.read<DoctorPatientProfileProvider>(),
                                ),
                              ],
                              child: Builder(
                                builder: (context) {
                                  // Now the provider is available!
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) {
                                      context.read<WidgetInjectionProvider>().inject(
                                        Consumer<DoctorPatientProfileProvider>(
                                          builder: (context, provider, _) {
                                            return DcoctorPateintProfileHeader(
                                              doctorPatientProfile: provider.patientProfile,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                  return PatientPrescriptions(
                                    patientId: widget.doctorPatientProfile.id!,
                                  );
                                },
                              ),
                            ),
                          )
                        : title == 'drPatientmedicalRecord'
                            ? FractionallySizedBox(
                            heightFactor: 1,
                            child: MultiProvider(
                              providers: [
                                ChangeNotifierProvider(
                                  create: (context) => MedicalRecordsProvider(),
                                ),
                                ChangeNotifierProvider(
                                  create: (context) => WidgetInjectionProvider(),
                                ),
                                ChangeNotifierProvider.value(
                                  value: context.read<DoctorPatientProfileProvider>(),
                                ),
                              ],
                              child: Builder(
                                builder: (context) {
                                  // Now the provider is available!
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) {
                                      context.read<WidgetInjectionProvider>().inject(
                                        Consumer<DoctorPatientProfileProvider>(
                                          builder: (context, provider, _) {
                                            return DcoctorPateintProfileHeader(
                                              doctorPatientProfile: provider.patientProfile,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                  return PatientMedicalRecords(
                                    patientId: widget.doctorPatientProfile.id!,
                                    doctorPatientProfile: widget.doctorPatientProfile,
                                  );
                                },
                              ),
                            ),
                          )
                            : FractionallySizedBox(
                                heightFactor: 1,
                                child: MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                      create: (context) => BillingProvider(),
                                    ),
                                    ChangeNotifierProvider(
                                      create: (context) => WidgetInjectionProvider(),
                                    ),
                                    ChangeNotifierProvider.value(
                                      value: context.read<DoctorPatientProfileProvider>(),
                                    ),
                                  ],
                                  child: Builder(
                                    builder: (context) {
                                      // Now the provider is available!
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        context.read<WidgetInjectionProvider>().inject(
                                          Consumer<DoctorPatientProfileProvider>(
                                            builder: (context, provider, _) {
                                              return DcoctorPateintProfileHeader(
                                                doctorPatientProfile: provider.patientProfile,
                                              );
                                            },
                                          ),
                                        );
                                      });

                                      return PatientBillings(
                                        patientId: widget.doctorPatientProfile.id!,
                                      );
                                    },
                                  ),
                                ),
                              );
                showModalBottomSheet(
                  useSafeArea: true,
                  showDragHandle: false,
                  isScrollControlled: true,
                  isDismissible: false,
                  enableDrag: false,
                  context: context,
                  builder: (context) {
                    return modalWidget;
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    FourCardPateintDoctorLottie(title: title),
                    const SizedBox(height: 8),
                    Flexible(
                      flex: 3,
                      child: Text(
                        context.tr(title, args: ['$length']),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
