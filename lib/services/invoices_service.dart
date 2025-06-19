import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/invoice_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class InvoicesService {
  Future<void> getDoctorInvoices(BuildContext context) async {
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    InvoiceProvider invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String userId = "";
    if (roleName == 'doctors') {
      userId = authProvider.doctorsProfile!.userId;
    } else if (roleName == 'patient') {
      userId = authProvider.patientProfile!.userId;
    }
    invoiceProvider.setLoading(true);
    void getDoctorInvoicesWithUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      socket.emit('getDoctorInvoices', {
        "userId": userId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off("getDoctorInvoicesReturn");
    socket.on('getDoctorInvoicesReturn', (data) {
      if (context.mounted) {
        invoiceProvider.setLoading(false);
      }
      if (data['status'] != 200 && data['status'] != 400) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        final reservation = data['reservation'];
        final totalCount = data['totalCount'];

        if (reservation is List && reservation.isNotEmpty) {
          try {
            final reservationList = reservation.map((json) {
              // Safely extract patientProfile and patientStatus
              final patientProfile = json['patientProfile'] ?? {};
              final patientStatus = json['patientStatus'] ?? {};

              // Inject `online` and `lastLogin` into patientProfile
              patientProfile['online'] = patientStatus['online'];
              patientProfile['lastLogin'] = patientStatus['lastLogin'];

              // Update json map before passing to fromJson
              json['patientProfile'] = patientProfile;

              return AppointmentReservation.fromJson(json);
            }).toList();

            invoiceProvider.setAppointmentReservations(reservationList);
            invoiceProvider.setTotal(totalCount);
          } catch (e) {
            log('Error parsing reservation: $e');
          }
        } else {
          invoiceProvider.setAppointmentReservations([]);
          invoiceProvider.setTotal(0);
        }
      }
    });

    socket.off('updateGetDoctorInvoices');
    socket.on('updateGetDoctorInvoices', (_) => getDoctorInvoicesWithUpdate());
    getDoctorInvoicesWithUpdate();
  }

  Future<bool> updateAppointmentRequestSubmit(BuildContext context, List<String> updateStatusArray) async {
    final completer = Completer<bool>();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final roleName = authProvider.roleName;
    String userId = "";

    if (roleName == 'doctors') {
      userId = authProvider.doctorsProfile!.userId;
    } else if (roleName == 'patient') {
      userId = authProvider.patientProfile!.userId;
    }

    socket.off("updateReservationAndTimsSlotStatusReturn"); // ensure only one listener
    socket.on('updateReservationAndTimsSlotStatusReturn', (data) {
      if (!completer.isCompleted) {
        if (data['status'] == 200) {
          if (context.mounted) showErrorSnackBar(context, data['message']);
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        } else {
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        }
      }
    });

    socket.emit('updateReservationAndTimsSlotStatus', {
      "userId": userId,
      "updateStatusArray": updateStatusArray,
      "newStatus": 'Pending',
    });

    return completer.future;
  }
}
