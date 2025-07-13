import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/models/dependents.dart';
import 'package:health_care/shared/gradient_button.dart';
import 'package:health_care/shared/sort_icon_widget.dart';
import 'package:timezone/timezone.dart' as tz;

class PatientsDependantsShowBox extends StatefulWidget {
  final Dependents dependent;
  final VoidCallback getDataOnUpdate;
  final Future<void> Function(BuildContext, List<String>) getConfirmationForDeleteDependent;
  final void Function(BuildContext, Dependents) openAddEditDependentForm;
  const PatientsDependantsShowBox({
    super.key,
    required this.dependent,
    required this.getDataOnUpdate,
    required this.getConfirmationForDeleteDependent,
    required this.openAddEditDependentForm,
  });

  @override
  State<PatientsDependantsShowBox> createState() => _PatientsDependantsShowBoxState();
}

class _PatientsDependantsShowBoxState extends State<PatientsDependantsShowBox> {
  @override
  Widget build(BuildContext context) {
    final Dependents dependent = widget.dependent;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final bangkok = tz.getLocation(dotenv.env['TZ']!);
    late String years = '--';
    late String months = '--';
    late String days = '--';
    if (dependent.dob is DateTime) {
      DateTime dob = dependent.dob;
      DateTime today = DateTime.now();
      DateTime b = DateTime(dob.year, dob.month, dob.day);
      int totalDays = today.difference(b).inDays;
      int y = totalDays ~/ 365;
      int m = (totalDays - y * 365) ~/ 30;
      int d = totalDays - y * 365 - m * 30;

      years = '$y';
      months = '$m';
      days = '$d';
    }
    final String gender = dependent.gender;
    final String dependentName = "$gender${gender != '' ? '. ' : ''}${dependent.fullName}";
    final String profileImage = dependent.profileImage;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.primaryColor),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Image
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: theme.primaryColorLight),
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: profileImage.isEmpty
                          ? const AssetImage(
                              'assets/images/default-avatar.png',
                            ) as ImageProvider
                          : CachedNetworkImageProvider(
                              profileImage,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // SideImage Columns
                SideImageColumns(dependent: dependent, widget: widget, dependentName: dependentName, theme: theme),
              ],
            ),
            //Divider
            MyDevider(theme: theme),
            //Relation
            RelationShip(dependent: dependent, widget: widget),
            // Divider
            MyDevider(theme: theme),
            // dob
            DateOfBirth(theme: theme, dependent: dependent, years: years, months: months, days: days, widget: widget),
            //Divider
            MyDevider(theme: theme),
            // BloodG
            DependentBloodG(dependent: dependent, widget: widget),
            //Divider
            MyDevider(theme: theme),
            // update
            DependentUpdate(theme: theme, textColor: textColor, dependent: dependent, bangkok: bangkok, widget: widget),
            // Divider
            MyDevider(theme: theme),
            // CreatedAt
            DependentCreate(theme: theme, textColor: textColor, dependent: dependent, bangkok: bangkok, widget: widget),
            //Divider
            MyDevider(theme: theme),
            // MedicalRecords
            DependentMedicalRecord(textColor: textColor, dependent: dependent, theme: theme),
            //Divider
            MyDevider(theme: theme),
            //EditButton
            EditButton(widget: widget, dependent: dependent, theme: theme, textColor: textColor),
            //Divider
            MyDevider(theme: theme),
            //DeleteButton
            DeleteButton(dependent: dependent, widget: widget, theme: theme, textColor: textColor),
          ],
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.dependent,
    required this.widget,
    required this.theme,
    required this.textColor,
  });

  final Dependents dependent;
  final PatientsDependantsShowBox widget;
  final ThemeData theme;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 35,
              child: GradientButton(
                onPressed: () {
                  if (dependent.medicalRecordsArray.isEmpty) {
                    widget.getConfirmationForDeleteDependent(context, [dependent.id ?? '']);
                  }
                },
                colors: dependent.medicalRecordsArray.isEmpty
                    ? const [
                        Colors.pink,
                        Colors.red,
                      ]
                    : [
                        theme.disabledColor,
                        theme.disabledColor,
                      ],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, size: 13, color: textColor),
                    const SizedBox(width: 5),
                    Text(
                      dependent.medicalRecordsArray.isEmpty ? context.tr("delete") : context.tr('cantDeleteDepenent'),
                      style: TextStyle(fontSize: 12, color: textColor),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  const EditButton({
    super.key,
    required this.widget,
    required this.dependent,
    required this.theme,
    required this.textColor,
  });

  final PatientsDependantsShowBox widget;
  final Dependents dependent;
  final ThemeData theme;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 35,
              child: GradientButton(
                onPressed: () {
                  widget.openAddEditDependentForm(context, dependent);
                },
                colors: [
                  theme.primaryColor,
                  theme.primaryColorLight,
                ],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 13, color: textColor),
                    const SizedBox(width: 5),
                    Text(
                      context.tr("edit"),
                      style: TextStyle(fontSize: 12, color: textColor),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DependentMedicalRecord extends StatelessWidget {
  const DependentMedicalRecord({
    super.key,
    required this.textColor,
    required this.dependent,
    required this.theme,
  });

  final Color textColor;
  final Dependents dependent;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          //  Items view
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
                          text: '${context.tr("medicalrecords")}: ',
                          style: TextStyle(color: textColor), // Normal colored text
                        ),
                        TextSpan(
                          text: "${dependent.medicalRecordsArray.length}",
                          style: TextStyle(
                            color: theme.primaryColorLight,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: InkWell(
                    onTap: dependent.medicalRecordsArray.isEmpty
                        ? null
                        : () {
                            context.push('/patient/dashboard/medicalrecords');
                          },
                    child: Icon(
                      Icons.visibility,
                      size: 16,
                      color: dependent.medicalRecordsArray.isEmpty ? theme.disabledColor : theme.primaryColorLight,
                    ),
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

class DependentCreate extends StatelessWidget {
  const DependentCreate({
    super.key,
    required this.theme,
    required this.textColor,
    required this.dependent,
    required this.bangkok,
    required this.widget,
  });

  final ThemeData theme;
  final Color textColor;
  final Dependents dependent;
  final tz.Location bangkok;
  final PatientsDependantsShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.clock, size: 13, color: theme.primaryColorLight),
                const SizedBox(width: 3),
                Text(
                  '${context.tr("createdAt")}: ',
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
                const SizedBox(width: 5),
                Text(
                  DateFormat('dd MMM yyyy').format(tz.TZDateTime.from(dependent.createdAt, bangkok)),
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
                const SizedBox(width: 3),
                Text(
                  DateFormat('HH:mm').format(tz.TZDateTime.from(dependent.createdAt, bangkok)),
                  style: TextStyle(color: theme.primaryColorLight, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SortIconWidget(columnName: 'createdAt', getDataOnUpdate: widget.getDataOnUpdate),
        ],
      ),
    );
  }
}

class DependentUpdate extends StatelessWidget {
  const DependentUpdate({
    super.key,
    required this.theme,
    required this.textColor,
    required this.dependent,
    required this.bangkok,
    required this.widget,
  });

  final ThemeData theme;
  final Color textColor;
  final Dependents dependent;
  final tz.Location bangkok;
  final PatientsDependantsShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.clock, size: 13, color: theme.primaryColorLight),
                const SizedBox(width: 3),
                Text(
                  '${context.tr("updateAt")}: ',
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
                const SizedBox(width: 5),
                Text(
                  DateFormat('dd MMM yyyy').format(tz.TZDateTime.from(dependent.updateAt, bangkok)),
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
                const SizedBox(width: 3),
                Text(
                  DateFormat('HH:mm').format(tz.TZDateTime.from(dependent.updateAt, bangkok)),
                  style: TextStyle(color: theme.primaryColorLight, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SortIconWidget(columnName: 'updateAt', getDataOnUpdate: widget.getDataOnUpdate),
        ],
      ),
    );
  }
}

class DependentBloodG extends StatelessWidget {
  const DependentBloodG({
    super.key,
    required this.dependent,
    required this.widget,
  });

  final Dependents dependent;
  final PatientsDependantsShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  bloodGValues.firstWhere(
                        (bg) => bg['title'] == dependent.bloodG,
                        orElse: () => {'icon': '❓'},
                      )['icon'] ??
                      '',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 5),
                Text('${context.tr('bloodG')}: '),
                Text(dependent.bloodG),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SortIconWidget(columnName: 'bloodG', getDataOnUpdate: widget.getDataOnUpdate),
        ],
      ),
    );
  }
}

class DateOfBirth extends StatelessWidget {
  const DateOfBirth({
    super.key,
    required this.theme,
    required this.dependent,
    required this.years,
    required this.months,
    required this.days,
    required this.widget,
  });

  final ThemeData theme;
  final Dependents dependent;
  final String years;
  final String months;
  final String days;
  final PatientsDependantsShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.cake,
                  size: 14,
                  color: theme.primaryColorLight,
                ),
                const SizedBox(width: 3),
                Text('${context.tr('dob')}: '),
                Text(
                  " ${dependent.dob is String ? '---- -- --' : '${DateFormat("dd MMM yyyy").format(dependent.dob.toLocal())} ,'}",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 5),
                Text(
                  "$years ${context.tr('years')}, $months ${context.tr('month')}, $days ${context.tr('days')}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SortIconWidget(columnName: 'dob', getDataOnUpdate: widget.getDataOnUpdate)
        ],
      ),
    );
  }
}

class RelationShip extends StatelessWidget {
  const RelationShip({
    super.key,
    required this.dependent,
    required this.widget,
  });

  final Dependents dependent;
  final PatientsDependantsShowBox widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 5),
                Text('${context.tr('relationShip')}: '),
                Text(
                  dependent.relationShip,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SortIconWidget(columnName: 'relationShip', getDataOnUpdate: widget.getDataOnUpdate)
        ],
      ),
    );
  }
}

class SideImageColumns extends StatelessWidget {
  const SideImageColumns({
    super.key,
    required this.dependent,
    required this.widget,
    required this.dependentName,
    required this.theme,
  });

  final Dependents dependent;
  final PatientsDependantsShowBox widget;
  final String dependentName;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                      dependent.isActive ? Icons.done : Icons.close,
                      color: dependent.isActive ? Colors.greenAccent : Colors.pink,
                      size: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Text(
                        dependent.isActive ? context.tr('isActive') : context.tr('notActive'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: SortIconWidget(columnName: 'isActive', getDataOnUpdate: widget.getDataOnUpdate),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dependentName,
                  style: TextStyle(
                    color: theme.primaryColorLight,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              const SizedBox(width: 6),
              SortIconWidget(columnName: 'fullName', getDataOnUpdate: widget.getDataOnUpdate)
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('#${dependent.dependentId}', style: TextStyle(color: theme.primaryColorLight))),
              const SizedBox(width: 6),
              SortIconWidget(columnName: 'id', getDataOnUpdate: widget.getDataOnUpdate)
            ],
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }
}

class MyDevider extends StatelessWidget {
  const MyDevider({
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
