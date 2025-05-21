import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:health_care/models/appointment_reservation.dart';
import 'package:health_care/providers/appointment_provider.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class AppointmentService {
  Future<void> getDocDashAppointments(BuildContext context, bool isToday) async {
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    AppointmentProvider appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String userId = "";
    if (roleName == 'doctors') {
      userId = authProvider.doctorsProfile!.userId;
    } else if (roleName == 'patient') {
      userId = authProvider.patientProfile!.userId;
    }
    appointmentProvider.setLoading(true);
    void getDocDashWithUpdate() {
      final freshPagination = dataGridProvider.paginationModel;
      final freshSort = dataGridProvider.sortModel;
      final freshFilter = dataGridProvider.mongoFilterModel;
      appointmentProvider.setLoading(false);
      socket.emit('getDocDashAppointments', {
        "userId": userId,
        "paginationModel": freshPagination,
        "sortModel": freshSort,
        "mongoFilterModel": freshFilter,
        "isToday": isToday,
      });
    }

    // 🔐 Attach socket listener ONCE
    socket.off('getDocDashAppointmentsReturn'); // remove previous to avoid stacking
    socket.on('getDocDashAppointmentsReturn', (data) {
      appointmentProvider.setLoading(false);
      if (data['status'] != 200 && data['status'] != 400) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        final appointments = data['docDashAppointments'];
        if (appointments is List && appointments.isNotEmpty) {
          final reservations = appointments[0]['reservations'];
          final totalCount = appointments[0]['totalCount'];
          try {
            final reservationList = (reservations as List).map((json) => AppointmentReservation.fromJson(json)).toList();
            appointmentProvider.setAppointmentReservations(reservationList);
          } catch (e, stack) {
            log('Failed to parse reservations: $e');
            log(stack.toString());
          }
          if (totalCount is List && totalCount.isNotEmpty) {
            final int finalTotal = totalCount.first["count"];
            appointmentProvider.setTotal(finalTotal);
          }
        }
      }
    });

    socket.off('updateGetDocDashAppointments');
    socket.on('updateGetDocDashAppointments', (_) => getDocDashWithUpdate());
    getDocDashWithUpdate();
  }

  Future<void> getDoctorAppointments(BuildContext context, int limit) async {
    AppointmentProvider appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    var roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String userId = "";
    List<String> reservationsIdArray = [];
    if (roleName == 'doctors') {
      userId = authProvider.doctorsProfile!.userId;
      reservationsIdArray = authProvider.doctorsProfile!.userProfile.reservationsId;
    } else if (roleName == 'patient') {
      userId = authProvider.patientProfile!.userId;
      reservationsIdArray = authProvider.patientProfile!.userProfile.reservationsId;
    }
    appointmentProvider.setLoading(true);
    void getDoctorAppointmentsWithUpdate() {
      const  skip = 0;
      log('limit: $limit loading: ${appointmentProvider.isLoading}');
      appointmentProvider.setLoading(false);
      socket.emit("getDoctorAppointments", {
        "userId": userId,
        "reservationsIdArray": reservationsIdArray,
        "limit": limit,
        "skip": skip,
      });
    }

    socket.off('getDoctorAppointmentsReturn');
    socket.on('getDoctorAppointmentsReturn', (data) {
      appointmentProvider.setLoading(false);
      if (data['status'] != 200 && data['status'] != 400) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        final appointments = data['myAppointment'];
        if (appointments is List && appointments.isNotEmpty) {
           try {
            final reservationList = (appointments).map((json) => AppointmentReservation.fromJson(json)).toList();
            appointmentProvider.setAppointmentReservations(reservationList);
          } catch (e, stack) {
            log('Failed to parse reservations: $e');
            log(stack.toString());
          }
        }
      }
    });

    socket.off('updateGetDoctorAppointments');
    socket.on('updateGetDoctorAppointments', (_) => getDoctorAppointmentsWithUpdate());
    getDoctorAppointmentsWithUpdate();
  }
}
