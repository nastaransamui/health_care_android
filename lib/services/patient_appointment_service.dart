import 'package:flutter/widgets.dart';
import 'package:health_care/models/patient_appointment_reservation.dart';
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
}
