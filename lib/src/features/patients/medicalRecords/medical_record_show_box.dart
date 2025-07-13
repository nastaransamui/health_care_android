import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/models/dependents.dart';
import 'package:health_care/models/doctor_patient_profile_model.dart';
import 'package:health_care/models/medical_records.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/src/features/patients/medicalRecords/download_file.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class MedicalRecordShowBox extends StatefulWidget {
  final MedicalRecords medicalRecord;
  final VoidCallback getDataOnUpdate;
  final List<String> deleteRecordsId;
  final void Function(String) tougleRecordIdTodeleteRecordsId;
  final void Function(BuildContext, MedicalRecords, String) openViewEditForm;
  final DoctorPatientProfileModel? doctorPatientProfile;
  const MedicalRecordShowBox({
    super.key,
    required this.medicalRecord,
    required this.getDataOnUpdate,
    required this.deleteRecordsId,
    required this.tougleRecordIdTodeleteRecordsId,
    required this.openViewEditForm,
    this.doctorPatientProfile,
  });

  @override
  State<MedicalRecordShowBox> createState() => _MedicalRecordShowBoxState();
}

class _MedicalRecordShowBoxState extends State<MedicalRecordShowBox> {
  late String roleName;
  bool _isProvidersInitialized = false;
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};
  late PatientsProfile? patientUserProfile;
  late List<Dependents> dependents;

  @override
  void initState() {
    super.initState();
    dependents = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
      patientUserProfile = Provider.of<AuthProvider>(context, listen: false).patientProfile;
      _isProvidersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final MedicalRecords medicalRecord = widget.medicalRecord;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    final bool isForDependent = medicalRecord.isForDependent;
    final Dependents? dependentProfile = medicalRecord.dependentProfile;
    final ImageProvider<Object> finalImage = isForDependent
        ? dependentProfile!.profileImage.isEmpty
            ? const AssetImage('assets/images/default-avatar.png') as ImageProvider
            : CachedNetworkImageProvider(dependentProfile.profileImage)
        : roleName == 'doctors'
            ? widget.doctorPatientProfile!.profileImage.isEmpty
                ? const AssetImage('assets/images/default-avatar.png') as ImageProvider
                : CachedNetworkImageProvider(widget.doctorPatientProfile!.profileImage)
            : patientUserProfile!.userProfile.profileImage.isEmpty
                ? const AssetImage('assets/images/doctors_profile.jpg') as ImageProvider
                : CachedNetworkImageProvider(patientUserProfile!.userProfile.profileImage);

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
              //profilerow
              ProfileRow(
                  theme: theme,
                  finalImage: finalImage,
                  isForDependent: isForDependent,
                  widget: widget,
                  medicalRecord: medicalRecord,
                  bangkok: bangkok,
                  textColor: textColor),
              MyDivider(theme: theme),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            '${context.tr('date')}: ',
                            style: TextStyle(color: theme.primaryColorLight, fontSize: 12),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy HH:mm').format(
                              tz.TZDateTime.from(medicalRecord.date, bangkok),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SortIconWidget(
                      columnName: 'date',
                      getDataOnUpdate: widget.getDataOnUpdate,
                    )
                  ],
                ),
              ),
              MyDivider(theme: theme),
              // // createdAt
              CreatedRow(textColor: textColor, medicalRecord: medicalRecord, bangkok: bangkok, theme: theme, widget: widget),
              //Divider
              MyDivider(theme: theme),
              // createdAt
              UpdateRow(textColor: textColor, medicalRecord: medicalRecord, bangkok: bangkok, theme: theme, widget: widget),
              //Divider
              MyDivider(theme: theme),
              //Description and Symptoms
              DescriptionRow(textColor: textColor, medicalRecord: medicalRecord, theme: theme, widget: widget),
              //Divider
              MyDivider(theme: theme),
              SymptomRow(textColor: textColor, medicalRecord: medicalRecord, theme: theme, widget: widget),

              //Divider
              MyDivider(theme: theme),
              //hospital and attachment
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    //  hospital view
                    Hospital(textColor: textColor, medicalRecord: medicalRecord, theme: theme, widget: widget),
                  ],
                ),
              ),

              //Divider
              MyDivider(theme: theme),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    // attachment
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  context.tr('${context.tr("attachment")}: '),
                                  style: TextStyle(color: theme.primaryColorLight),
                                ),
                                medicalRecord.documentLink.isEmpty
                                    ? Text(
                                        '--',
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontSize: 16,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isDownloading[medicalRecord.id!] = true;
                                            _downloadProgress[medicalRecord.id!] = 0.0;
                                          });

                                          downloadFile(
                                            medicalRecord.documentLink,
                                            context,
                                            (progress) {
                                              setState(() {
                                                _downloadProgress[medicalRecord.id!] = progress;
                                              });
                                            },
                                            (path) {
                                              setState(() {
                                                _isDownloading[medicalRecord.id!] = false;
                                              });
                                              showErrorSnackBar(context, context.tr('savedToDownload', args: [path]));
                                            },
                                          );
                                        },
                                        child: _isDownloading[medicalRecord.id] == true
                                            ? Row(
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    child: LinearProgressIndicator(
                                                      value: _downloadProgress[medicalRecord.id] ?? 0.0,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${((_downloadProgress[medicalRecord.id] ?? 0.0) * 100).toStringAsFixed(0)}%',
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              )
                                            : Icon(
                                                Icons.download,
                                                color: theme.primaryColor,
                                                size: 16,
                                              ),
                                      )
                              ],
                            ),
                          ),
                          SortIconWidget(
                            columnName: 'documentLink',
                            getDataOnUpdate: widget.getDataOnUpdate,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //Divider
              MyDivider(theme: theme),
              // buttons
              ButtonsRow(widget: widget, medicalRecord: medicalRecord, textColor: textColor)
            ],
          ),
        ),
      ),
    );
  }
}

class SymptomRow extends StatelessWidget {
  const SymptomRow({
    super.key,
    required this.textColor,
    required this.medicalRecord,
    required this.theme,
    required this.widget,
  });

  final Color textColor;
  final MedicalRecords medicalRecord;
  final ThemeData theme;
  final MedicalRecordShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Symptom
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12), // Common style
                      children: [
                        TextSpan(
                          text: '${context.tr("symptoms")}: ',
                          style: TextStyle(color: theme.primaryColorLight),
                        ),
                        TextSpan(
                          text: medicalRecord.symptoms,
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SortIconWidget(
                  columnName: 'symptoms',
                  getDataOnUpdate: widget.getDataOnUpdate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonsRow extends StatelessWidget {
  const ButtonsRow({
    super.key,
    required this.widget,
    required this.medicalRecord,
    required this.textColor,
  });

  final MedicalRecordShowBox widget;
  final MedicalRecords medicalRecord;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: SizedBox(
            height: 35,
            child: GradientButton(
              onPressed: () {
                widget.openViewEditForm(context, medicalRecord, 'view');
              },
              colors: [
                Theme.of(context).primaryColorLight,
                Theme.of(context).primaryColor,
              ],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.eye, size: 13, color: textColor),
                  const SizedBox(width: 5),
                  Text(
                    context.tr("view"),
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
                onPressed: () {
                  widget.tougleRecordIdTodeleteRecordsId(medicalRecord.id!);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, size: 13, color: textColor),
                    const SizedBox(width: 5),
                    Text(
                      context.tr("delete"),
                      style: TextStyle(fontSize: 12, color: textColor),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Hospital extends StatelessWidget {
  const Hospital({
    super.key,
    required this.textColor,
    required this.medicalRecord,
    required this.theme,
    required this.widget,
  });

  final Color textColor;
  final MedicalRecords medicalRecord;
  final ThemeData theme;
  final MedicalRecordShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12), // Common style
                children: [
                  TextSpan(
                    text: '${context.tr("hospitalName")}: ',
                    style: TextStyle(color: theme.primaryColorLight),
                  ),
                  TextSpan(
                    text: medicalRecord.hospitalName,
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SortIconWidget(
            columnName: 'hospitalName',
            getDataOnUpdate: widget.getDataOnUpdate,
          ),
        ],
      ),
    );
  }
}

class DescriptionRow extends StatelessWidget {
  const DescriptionRow({
    super.key,
    required this.textColor,
    required this.medicalRecord,
    required this.theme,
    required this.widget,
  });

  final Color textColor;
  final MedicalRecords medicalRecord;
  final ThemeData theme;
  final MedicalRecordShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          //  Description view
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12), // Common style
                      children: [
                        TextSpan(
                          text: '${context.tr("description")}: ',
                          style: TextStyle(color: theme.primaryColorLight),
                        ),
                        TextSpan(
                          text: medicalRecord.description,
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SortIconWidget(
                  columnName: 'description',
                  getDataOnUpdate: widget.getDataOnUpdate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreatedRow extends StatelessWidget {
  const CreatedRow({
    super.key,
    required this.textColor,
    required this.medicalRecord,
    required this.bangkok,
    required this.theme,
    required this.widget,
  });

  final Color textColor;
  final MedicalRecords medicalRecord;
  final tz.Location bangkok;
  final ThemeData theme;
  final MedicalRecordShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // createdAt
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '${context.tr("createdAt")}: ',
                              style: TextStyle(color: theme.primaryColorLight, fontSize: 12),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy HH:mm').format(tz.TZDateTime.from(medicalRecord.createdAt, bangkok)),
                              style: TextStyle(color: textColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                  child: SortIconWidget(
                    columnName: 'createdAt',
                    getDataOnUpdate: widget.getDataOnUpdate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateRow extends StatelessWidget {
  const UpdateRow({
    super.key,
    required this.textColor,
    required this.medicalRecord,
    required this.bangkok,
    required this.theme,
    required this.widget,
  });

  final Color textColor;
  final MedicalRecords medicalRecord;
  final tz.Location bangkok;
  final ThemeData theme;
  final MedicalRecordShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // createdAt
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '${context.tr("updateAt")}: ',
                              style: TextStyle(color: theme.primaryColorLight, fontSize: 12),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy HH:mm').format(tz.TZDateTime.from(medicalRecord.updateAt, bangkok)),
                              style: TextStyle(color: textColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 2.0, left: 12.0),
                  child: SortIconWidget(
                    columnName: 'updateAt',
                    getDataOnUpdate: widget.getDataOnUpdate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyDivider extends StatelessWidget {
  const MyDivider({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 1,
        color: theme.primaryColorLight,
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.theme,
    required this.finalImage,
    required this.isForDependent,
    required this.widget,
    required this.medicalRecord,
    required this.bangkok,
    required this.textColor,
  });

  final ThemeData theme;
  final ImageProvider<Object> finalImage;
  final bool isForDependent;
  final MedicalRecordShowBox widget;
  final MedicalRecords medicalRecord;
  final tz.Location bangkok;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
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
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isForDependent ? Icons.done : Icons.close,
                          color: isForDependent ? Colors.greenAccent : Colors.pink,
                          size: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Text(context.tr('isForDependent')),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: SortIconWidget(columnName: 'isForDependent', getDataOnUpdate: widget.getDataOnUpdate),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      medicalRecord.fullName,
                      style: TextStyle(
                        color: theme.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SortIconWidget(
                    columnName: 'fullName',
                    getDataOnUpdate: widget.getDataOnUpdate,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '#${medicalRecord.medicalId}',
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
    );
  }
}
