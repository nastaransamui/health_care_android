import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/shared/status_badge_avatar.dart';
import 'package:health_care/src/features/doctors/invoice/build_doctor_invoice_pdf.dart';
import 'package:health_care/src/features/doctors/invoice/doctor_invoice_preview_screen.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:timezone/timezone.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class InvoiceDataSort extends DataGridSource {
  List<DataGridRow> _appointments = [];
  final BuildContext context;
  final List<String> selectedIds;
  final ValueNotifier<List<String>> selectedIdsNotifier;
  final Future<void> Function(BuildContext, List<String>) updateAppointmentRequestSubmit;
  InvoiceDataSort({
    required this.context,
    required List<AppointmentReservation> appointments,
    required this.selectedIds,
    required this.selectedIdsNotifier,
    required this.updateAppointmentRequestSubmit,
  }) {
    _appointments = appointments
        .map<DataGridRow>(
          (appointment) => DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'select', value: appointment.id),
              DataGridCell<int>(columnName: 'id', value: appointment.appointmentId),
              DataGridCell<DateTime>(columnName: 'createdDate', value: appointment.createdDate),
              DataGridCell<String>(columnName: 'dayPeriod', value: appointment.dayPeriod),
              DataGridCell<Map<String, dynamic>>(
                columnName: 'selectedDate',
                value: {
                  'date': appointment.selectedDate,
                  'period': appointment.timeSlot.period,
                },
              ),
              DataGridCell(columnName: 'invoiceId', value: {'id': appointment.id, 'invoiceId': appointment.invoiceId}),
              DataGridCell<Map<String, dynamic>>(
                columnName: 'timeSlot.price',
                value: {
                  'price': appointment.timeSlot.price,
                  'currencySymbol': appointment.timeSlot.currencySymbol,
                },
              ),
              DataGridCell<double>(columnName: 'timeSlot.bookingsFee', value: appointment.timeSlot.bookingsFee),
              DataGridCell<Map<String, dynamic>>(
                columnName: 'timeSlot.bookingsFeePrice',
                value: {
                  'bookingsFeePrice': appointment.timeSlot.bookingsFeePrice,
                  'currencySymbol': appointment.timeSlot.currencySymbol,
                },
              ),
              DataGridCell<Map<String, dynamic>>(
                columnName: 'timeSlot.total',
                value: {
                  'total': appointment.timeSlot.total,
                  'currencySymbol': appointment.timeSlot.currencySymbol,
                },
              ),
              DataGridCell<String>(columnName: 'paymentType', value: appointment.paymentType),
              DataGridCell<String>(columnName: 'paymentToken', value: appointment.paymentToken),
              DataGridCell<dynamic>(columnName: 'paymentDate', value: appointment.paymentDate),
              DataGridCell<PatientUserProfile>(columnName: 'patientProfile.fullName', value: appointment.patientProfile),
              DataGridCell<String>(columnName: 'doctorPaymentStatus', value: appointment.doctorPaymentStatus),
              const DataGridCell<String>(columnName: 'actions', value: ''),
            ],
          ),
        )
        .toList();
  }
  @override
  List<DataGridRow> get rows => _appointments;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final String appointmentId = row.getCells().firstWhere((cell) => cell.columnName == 'select').value;
    final bool isSelected = selectedIds.contains(appointmentId);
    final String doctorPaymentStatus = row.getCells().firstWhere((cell) => cell.columnName == 'doctorPaymentStatus').value;
    final selectedDateMap = row.getCells().firstWhere((cell) => cell.columnName == 'selectedDate').value;
    final selectedDate = selectedDateMap["date"];
    final String period = selectedDateMap["period"];
    bool isSelectable = doctorPaymentStatus == 'Awaiting Request' && !disablePastTime(selectedDate, period);
    final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
    final dateFormat = DateFormat('dd MMM yyyy');
    final bangkok = tz.getLocation(dotenv.env['TZ']!);

    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        final columnName = cell.columnName;
        final value = cell.value;

        String displayValue;
        Widget cellWidget;
        if (columnName == 'select') {
          cellWidget = Checkbox(
            value: isSelected,
            onChanged: !isSelectable
                ? null
                : (bool? value) {
                    if (value == true) {
                      selectedIds.add(appointmentId);
                    } else {
                      selectedIds.remove(appointmentId);
                    }
                    selectedIdsNotifier.value = List.from(selectedIds);
                    notifyListeners();
                  },
          );
        } else if (columnName == 'createdDate' && value is DateTime) {
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
        } else if (columnName == 'timeSlot.price' && value is Map<String, dynamic>) {
          final double price = value['price'];
          final String currencySymbol = value['currencySymbol'];
          final formattedPrice = NumberFormat("#,##0.00", "en_US").format(price);
          cellWidget = SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formattedPrice,
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 15),
                Text(
                  currencySymbol,
                  style: TextStyle(color: theme.primaryColor),
                ),
              ],
            ),
          );
        } else if (columnName == 'timeSlot.bookingsFee' && value is double) {
          cellWidget = SizedBox(
            child: Text(
              '$value %',
              style: TextStyle(color: textColor),
            ),
          );
        } else if (columnName == 'timeSlot.bookingsFeePrice' && value is Map<String, dynamic>) {
          final double bookingsFeePrice = value['bookingsFeePrice'];
          final String currencySymbol = value['currencySymbol'];
          final formattedBookingsFeePrice = NumberFormat("#,##0.00", "en_US").format(bookingsFeePrice);
          cellWidget = SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formattedBookingsFeePrice,
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 15),
                Text(
                  currencySymbol,
                  style: TextStyle(color: theme.primaryColor),
                ),
              ],
            ),
          );
        } else if (columnName == 'timeSlot.total' && value is Map<String, dynamic>) {
          final double total = value['total'];
          final String currencySymbol = value['currencySymbol'];
          final formattedTotal = NumberFormat("#,##0.00", "en_US").format(total);
          cellWidget = SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formattedTotal,
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 15),
                Text(
                  currencySymbol,
                  style: TextStyle(color: theme.primaryColor),
                ),
              ],
            ),
          );
        } else if (columnName == 'paymentType' || columnName == 'paymentToken' && value is String && value.isNotEmpty) {
          cellWidget = Text(
            value,
            style: TextStyle(color: textColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        } else if (columnName == 'paymentDate') {
          if (value is DateTime) {
            displayValue = dateTimeFormat.format(tz.TZDateTime.from(value, bangkok));
          } else {
            displayValue = '===';
          }

          cellWidget = Text(
            displayValue,
            style: TextStyle(color: textColor),
          );
        } else if (columnName == 'patientProfile.fullName' && value is PatientUserProfile) {
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
          Widget chip = Chip(
            label: Text(
              value,
              style: TextStyle(color: textColor),
            ),
            backgroundColor: value == "Paid"
                ? hexToColor('#5BC236')
                : value == "Awaiting Request"
                    ? hexToColor('#f44336')
                    : hexToColor('#ffa500'), // Chip background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners
              side: BorderSide.none, // optional: border color/width
            ),
            padding: const EdgeInsets.all(3),
          );
          cellWidget = isSelectable
              ? GestureDetector(
                  onTap: () {
                    updateAppointmentRequestSubmit(context, [appointmentId]);
                  },
                  child: chip,
                )
              : chip;
        } else if (columnName == 'actions') {
          cellWidget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.print,
                  color: theme.primaryColor,
                ),
                tooltip: 'Print',
                onPressed: () {
                  // Show loading dialog
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
                      final appointment = convertRowToAppointment(row);
                      final pdf = await buildDoctorInvoicePdf(context, appointment);
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
                            title: Text(context.tr('invoicePreview')),
                          ),
                        ),
                      );
                      // });
                    } catch (e) {
                      debugPrint('PDF Error: $e');
                    }
                  });
                },
              ),
              // You can add more buttons here
            ],
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

  @override
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    if (sortColumn.name == 'invoiceId') {
      final String? valueA = a?.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'invoiceId')?.value['invoiceId'];
      final String? valueB = b?.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'invoiceId')?.value['invoiceId'];
      if (valueA == null || valueB == null) {
        return 0;
      }

      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return valueA.toLowerCase().compareTo(valueB.toLowerCase());
      } else {
        return valueB.toLowerCase().compareTo(valueA.toLowerCase());
      }
    }

    if (sortColumn.name == 'selectedDate') {
      final DateTime? valueA = a?.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'selectedDate')?.value['date'];
      final DateTime? valueB = b?.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'selectedDate')?.value['date'];
      if (valueA == null || valueB == null) {
        return 0;
      }

      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return valueA.compareTo(valueB);
      } else {
        return valueB.compareTo(valueA);
      }
    }

    if (sortColumn.name == 'patientProfile.fullName') {
      final DataGridCell<PatientUserProfile>? cellA =
          a!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'patientProfile.fullName') as DataGridCell<PatientUserProfile>?;

      final String valueA = "${cellA?.value?.fullName}";

      final DataGridCell<PatientUserProfile>? cellB =
          b!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'patientProfile.fullName') as DataGridCell<PatientUserProfile>?;

      final String valueB = "${cellB?.value?.fullName}";

      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return valueA.toLowerCase().compareTo(valueB.toLowerCase());
      } else {
        return valueB.toLowerCase().compareTo(valueA.toLowerCase());
      }
    }
    if (sortColumn.name == 'timeSlot.price') {
      final DataGridCell<Map<String, dynamic>>? cellA =
          a!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'timeSlot.price') as DataGridCell<Map<String, dynamic>>?;

      final DataGridCell<Map<String, dynamic>>? cellB =
          b!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'timeSlot.price') as DataGridCell<Map<String, dynamic>>?;

      final double? valueA = cellA!.value?['price'];
      final double? valueB = cellB!.value?['price'];

      if (valueA == null || valueB == null) return 0;

      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return valueA.compareTo(valueB);
      } else {
        return valueB.compareTo(valueA);
      }
    }

    if (sortColumn.name == 'timeSlot.bookingsFee') {
      final DataGridCell<double>? cellA =
          a!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'timeSlot.bookingsFee') as DataGridCell<double>?;

      final DataGridCell<double>? cellB =
          b!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'timeSlot.bookingsFee') as DataGridCell<double>?;

      final double? valueA = cellA!.value;
      final double? valueB = cellB!.value;

      if (valueA == null || valueB == null) return 0;

      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return valueA.compareTo(valueB);
      } else {
        return valueB.compareTo(valueA);
      }
    }

    if (sortColumn.name == 'timeSlot.bookingsFeePrice') {
      final DataGridCell<Map<String, dynamic>>? cellA =
          a!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'timeSlot.bookingsFeePrice') as DataGridCell<Map<String, dynamic>>?;

      final DataGridCell<Map<String, dynamic>>? cellB =
          b!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'timeSlot.bookingsFeePrice') as DataGridCell<Map<String, dynamic>>?;

      final double? valueA = cellA!.value?['bookingsFeePrice'];
      final double? valueB = cellB!.value?['bookingsFeePrice'];

      if (valueA == null || valueB == null) return 0;

      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return valueA.compareTo(valueB);
      } else {
        return valueB.compareTo(valueA);
      }
    }

    if (sortColumn.name == 'timeSlot.total') {
      final DataGridCell<Map<String, dynamic>>? cellA =
          a!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'timeSlot.total') as DataGridCell<Map<String, dynamic>>?;

      final DataGridCell<Map<String, dynamic>>? cellB =
          b!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'timeSlot.total') as DataGridCell<Map<String, dynamic>>?;

      final double? valueA = cellA!.value?['total'];
      final double? valueB = cellB!.value?['total'];

      if (valueA == null || valueB == null) return 0;

      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return valueA.compareTo(valueB);
      } else {
        return valueB.compareTo(valueA);
      }
    }

    if (sortColumn.name == 'patientProfile.fullName') {
      final DataGridCell<PatientUserProfile>? cellA =
          a!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'patientProfile.fullName') as DataGridCell<PatientUserProfile>?;

      final String valueA = "${cellA?.value?.fullName}";

      final DataGridCell<PatientUserProfile>? cellB =
          b!.getCells().firstWhereOrNull((dataCell) => dataCell.columnName == 'patientProfile.fullName') as DataGridCell<PatientUserProfile>?;

      final String valueB = "${cellB?.value?.fullName}";

      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return valueA.toLowerCase().compareTo(valueB.toLowerCase());
      } else {
        return valueB.toLowerCase().compareTo(valueA.toLowerCase());
      }
    }

    return super.compare(a, b, sortColumn);
  }
}

bool disablePastTime(DateTime date, String period) {
  // Extract the start time (e.g., "17:00" from "17:00 - 18:00")
  final startTime = period.split(' - ')[0];

  final timeParts = startTime.split(':');
  final hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);

  // Combine the date and time
  final dateTime = DateTime(
    date.year,
    date.month,
    date.day,
    hour,
    minute,
  );

  final now = DateTime.now();

  return dateTime.isAfter(now);
}
