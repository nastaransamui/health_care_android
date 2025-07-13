import 'package:flutter/widgets.dart';
import 'package:health_care/models/patient_appointment_reservation.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/patient_appointment_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class PatientAppointmentService {
  Future<void> getPatAppointmentRecord(BuildContext context, String patientId) async {
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    PatientAppointmentProvider patientAppointmentProvider = Provider.of<PatientAppointmentProvider>(context, listen: false);

    void getAppointmentRecordWithUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      socket.emit('getAppointmentRecord', {
        'patientId': patientId,
        'paginationModel': paginationModel,
        'sortModel': sortModel,
        'mongoFilterModel': mongoFilterModel,
      });
    }

    socket.off('getAppointmentRecordReturn');
    socket.on('getAppointmentRecordReturn', (data) {
      patientAppointmentProvider.setLoading(false);
      if (data['status'] != 200 && data['status'] != 400) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      final appointmentRecords = data['appointmentRecords'];
      final totalAppointment = data['totalAppointment'];
      if (appointmentRecords is List && appointmentRecords.isNotEmpty) {
        try {
          final reservationList = (appointmentRecords).map((json) => PatientAppointmentReservation.fromJson(json)).toList();
          patientAppointmentProvider.setPatientAppointmentReservations(reservationList);
          patientAppointmentProvider.setTotal(totalAppointment);
          // ignore: empty_catches
        } catch (e) {}
      } else {
        patientAppointmentProvider.setTotal(0);
        patientAppointmentProvider.setPatientAppointmentReservations([]);
      }
    });
    socket.off('updateGetAppointmentRecord');
    socket.on('updateGetAppointmentRecord', (_) => getAppointmentRecordWithUpdate());
    getAppointmentRecordWithUpdate();
  }

  Future<void> getPatientInvoices(BuildContext context) async {
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    PatientAppointmentProvider patientAppointmentProvider = Provider.of<PatientAppointmentProvider>(context, listen: false);
    bool isLogin = authProvider.isLogin;
    if (!isLogin) return;
    String userId = authProvider.patientProfile!.userId;
    void getPatientInvoicesWithUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      socket.emit('getPatientInvoices', {
        "userId": userId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getPatientInvoicesReturn');
    socket.on('getPatientInvoicesReturn', (data) {
      if (data['status'] != 200) {
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
              final patientProfile = json['doctorProfile'] ?? {};
              final patientStatus = json['patientStatus'] ?? {};

              // Inject `online` and `lastLogin` into patientProfile
              patientProfile['online'] = patientStatus['online'];
              patientProfile['lastLogin'] = patientStatus['lastLogin'];

              // Update json map before passing to fromJson
              json['patientProfile'] = patientProfile;

              return PatientAppointmentReservation.fromJson(json);
            }).toList();

            patientAppointmentProvider.setPatientAppointmentReservations(reservationList);
            patientAppointmentProvider.setTotal(totalCount);
            // ignore: empty_catches
          } catch (e) {}
        } else {
          patientAppointmentProvider.setPatientAppointmentReservations([]);
          patientAppointmentProvider.setTotal(0);
        }
      }
    });

    socket.off('updateGetPatientInvoices');
    socket.on('updateGetPatientInvoices', (_) => getPatientInvoicesWithUpdate());
    getPatientInvoicesWithUpdate();
  }
}
