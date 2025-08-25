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
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return;
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
      socket.emit('getDocDashAppointments', {
        "userId": userId,
        "paginationModel": freshPagination,
        "sortModel": freshSort,
        "mongoFilterModel": freshFilter,
        "isToday": isToday,
      });
    }

    socket.off('getDocDashAppointmentsReturn'); // remove previous to avoid stacking
    socket.on('getDocDashAppointmentsReturn', (data) {
      if (data['status'] != 200 && data['status'] != 400) {
        log(' appointmentProvider.setLoading 1');
        appointmentProvider.setLoading(false);
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        log(' appointmentProvider.setLoading 2');
        appointmentProvider.setLoading(false);
        final appointments = data['docDashAppointments'];
        if (appointments is List && appointments.isNotEmpty) {
          final reservations = appointments[0]['reservations'];
          final totalCount = appointments[0]['totalCount'];
          try {
            final reservationList = (reservations as List).map((json) => AppointmentReservation.fromJson(json)).toList();
            appointmentProvider.setAppointmentReservations(reservationList);
            // ignore: empty_catches
          } catch (e) {}
          if (totalCount is List && totalCount.isNotEmpty) {
            final int finalTotal = totalCount.first["count"];
            appointmentProvider.setTotal(finalTotal);
          }
        } else {
          appointmentProvider.setAppointmentReservations([]);
          appointmentProvider.setTotal(0);
        }
      }
    });

    socket.off('updateGetDocDashAppointments');
    socket.on('updateGetDocDashAppointments', (_) => getDocDashWithUpdate());
    getDocDashWithUpdate();
  }

  Future<void> getDoctorAppointments(BuildContext context) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return;
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
    void getDoctorAppointmentsWithUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      socket.emit("getDoctorAppointments", {
        "userId": userId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getDoctorAppointmentsReturn');
    socket.on('getDoctorAppointmentsReturn', (data) {
      if (data['status'] != 200 && data['status'] != 400) {
        log(' appointmentProvider.setLoading 3');
        appointmentProvider.setLoading(false);
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        log(' appointmentProvider.setLoading 4');
        appointmentProvider.setLoading(false);
        final appointments = data['myAppointment'];
        final totalAppointment = data['totalAppointment'];
        if (appointments is List && appointments.isNotEmpty) {
          final reservationList = (appointments).map((json) => AppointmentReservation.fromJson(json)).toList();
          appointmentProvider.setAppointmentReservations(reservationList);
          appointmentProvider.setTotal(totalAppointment);
        } else {
          appointmentProvider.setAppointmentReservations([]);
          appointmentProvider.setTotal(0);
        }
      }
    });

    socket.off('updateGetDoctorAppointments');
    socket.on('updateGetDoctorAppointments', (_) => getDoctorAppointmentsWithUpdate());
    getDoctorAppointmentsWithUpdate();
  }
}
