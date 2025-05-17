import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/status_badge_avatar.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:timezone/timezone.dart' as tz;

class AppointmentDataSource extends DataGridSource {
  List<DataGridRow> _appointments = [];
  final BuildContext context;
  AppointmentDataSource({
    required this.context,
    required List<AppointmentReservation> appointments,
  }) {
    _appointments = appointments
        .map<DataGridRow>((appointment) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'appointmentId', value: appointment.appointmentId),
              DataGridCell<DateTime>(columnName: 'createdDate', value: appointment.createdDate),
              DataGridCell<String>(columnName: 'dayPeriod', value: appointment.dayPeriod),
              DataGridCell(columnName: 'invoiceId', value: {'id': appointment.id, 'invoiceId': appointment.invoiceId}),
              DataGridCell<Map<String, dynamic>>(
                columnName: 'selectedDate',
                value: {
                  'date': appointment.selectedDate,
                  'period': appointment.timeSlot.period,
                },
              ),
              DataGridCell<PatientUserProfile>(columnName: 'patientProfile', value: appointment.patientProfile),
              DataGridCell<String>(columnName: 'doctorPaymentStatus', value: appointment.doctorPaymentStatus),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _appointments;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
    final dateFormat = DateFormat('dd MMM yyyy');
    final bangkok = tz.getLocation('Asia/Bangkok');

    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        final columnName = cell.columnName;
        final value = cell.value;

        String displayValue;
        Widget cellWidget;
        if (columnName == 'createdDate' && value is DateTime) {
          displayValue = dateTimeFormat.format(tz.TZDateTime.from(value, bangkok));
          cellWidget = Text(
            displayValue,
            style: TextStyle(color: textColor),
          );
        } else if (columnName == 'dayPeriod' && value is String && value.isNotEmpty) {
          displayValue = value[0].toUpperCase() + value.substring(1).toLowerCase();
          cellWidget = Text(
            displayValue,
            style: TextStyle(color: textColor),
          );
        } else if (columnName == 'selectedDate' && value is Map<String, dynamic>) {
          final DateTime date = value['date'];
          final String period = value['period'];
          final formattedDate = dateFormat.format(tz.TZDateTime.from(date, bangkok));
          cellWidget = SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 15),
                Text(
                  period,
                  style: TextStyle(color: theme.primaryColor),
                ),
              ],
            ),
          );
        } else if (columnName == 'invoiceId' && value is Map<String, dynamic>) {
          final String rowId = value['id'];
          final String invoiceId = value['invoiceId'];
          final encodedId = base64.encode(utf8.encode(rowId.toString()));

          cellWidget = GestureDetector(
            onTap: () {
              context.push(
                Uri(path: '/doctors/dashboard/invoice-view/$encodedId').toString(),
              );
            },
            child: Text(
              invoiceId.toString(),
              style: TextStyle(
                color: theme.primaryColorLight,
                decoration: TextDecoration.underline,
              ),
            ),
          );
        } else if (columnName == 'patientProfile' && value is PatientUserProfile) {
          final String patientName = "${value.gender.isEmpty ? '' : '${value.gender}.'}${value.fullName}";
          late String profileImage = "";
          final encodedId = base64.encode(utf8.encode(value.patientsId.toString()));
          if (value.profileImage.isNotEmpty) {
            profileImage = value.profileImage;
          } else {
            profileImage = 'assets/images/default-avatar.png';
          }
          cellWidget = Row(
            children: [
              StatusBadgeAvatar(
                imageUrl: profileImage,
                online: value.online,
                idle: value.idle ?? false,
                userType: 'patient',
                onTap: () {
                  context.push(
                    Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                  );
                },
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 150, // Constrain this
                child: GestureDetector(
                  onTap: () {
                    context.push(
                      Uri(path: '/doctors/dashboard/patient-profile/$encodedId').toString(),
                    );
                  },
                  child: Text(
                    patientName.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.primaryColorLight,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          );
        } else if (columnName == "doctorPaymentStatus" && value is String && value.isNotEmpty) {
          cellWidget = Chip(
            label: Text(
              value,
              style: TextStyle(color: textColor),
            ),
            backgroundColor: value == "Paid" ? Colors.green : value == "Awaiting Request" ? hexToColor('#f44336') : theme.primaryColor, // Chip background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners
              side: BorderSide.none, // optional: border color/width
            ),
            padding: const EdgeInsets.all(3),
          );
        } else {
          displayValue = value.toString();
          cellWidget = Text(
            displayValue,
            style: TextStyle(color: textColor),
          );
        }

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: cellWidget,
        );
      }).toList(),
    );
  }
}
