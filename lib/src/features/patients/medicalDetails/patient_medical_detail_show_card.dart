import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/vital_signs.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:health_care/shared/vital_image.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';
import 'package:timezone/timezone.dart' as tz;

class PatientMedicalDetailShowCard extends StatefulWidget {
  final String title;
  final VitalSignValues vitalSignValue;
  final VoidCallback getDataOnUpdate;
  final Future<void> Function(BuildContext, List<int>) getConfirmationForDeleteMedicalDetail;
  const PatientMedicalDetailShowCard({
    super.key,
    required this.title,
    required this.vitalSignValue,
    required this.getDataOnUpdate,
    required this.getConfirmationForDeleteMedicalDetail,
  });

  @override
  State<PatientMedicalDetailShowCard> createState() => _PatientMedicalDetailShowCardState();
}

class _PatientMedicalDetailShowCardState extends State<PatientMedicalDetailShowCard> {
  @override
  Widget build(BuildContext context) {
    final String title = widget.title;
    final VitalSignValues vitalSignValue = widget.vitalSignValue;
    final ThemeData theme = Theme.of(context);

    var brightness = theme.brightness;
    // Filter the list to find the item with matching title
    final matchedVital = vitalBoxList.firstWhere(
      (element) => element['title'] == title,
      orElse: () => {},
    );
    final bangkok = tz.getLocation('Asia/Bangkok');
    // Extract image and icon safely with fallback empty string
    final String image = matchedVital['image'] ?? '';
    final String icon = matchedVital['icon'] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.primaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: VitalImage(
                      image: image,
                      icon: icon,
                      brightness: brightness,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text('${context.tr(title)}/${matchedVital['unit']}: '),
                                  Text(
                                    '${vitalSignValue.value} ${matchedVital['unit']}',
                                    style: TextStyle(color: theme.primaryColorLight),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(columnName: 'id', getDataOnUpdate: widget.getDataOnUpdate),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text('${context.tr('id')}: '),
                                  Text(
                                    '#${vitalSignValue.id}',
                                    style: TextStyle(color: theme.primaryColorLight),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(columnName: 'id', getDataOnUpdate: widget.getDataOnUpdate),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text('${context.tr('submitDate')}: '),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${DateFormat('dd MMM yyyy').format(tz.TZDateTime.from(vitalSignValue.date, bangkok))} ',
                                          style: TextStyle(color: theme.primaryColorLight),
                                        ),
                                        TextSpan(
                                          text: DateFormat('HH:mm:ss').format(tz.TZDateTime.from(vitalSignValue.date, bangkok)),
                                          style: TextStyle(color: theme.primaryColorLight),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            SortIconWidget(columnName: 'date', getDataOnUpdate: widget.getDataOnUpdate),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  )
                ],
              ),
              MyDivider(theme: theme),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  child: GradientButton(
                    onPressed: () async {
                      widget.getConfirmationForDeleteMedicalDetail(context, [vitalSignValue.id]);
                    },
                    colors: const [
                      Colors.pink,
                      Colors.red,
                    ],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_forever),
                        Text(context.tr('deleteMedicalRecord')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
