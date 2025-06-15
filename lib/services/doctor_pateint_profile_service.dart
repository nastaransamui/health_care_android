
import 'package:flutter/widgets.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/providers/doctor_patient_profile_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class DoctorPateintProfileService {
  Future<void> findDocterPatientProfileById(BuildContext context, String mongoPatientUserId) async {
    final DoctorPatientProfileProvider doctorPatientProfileProvider = Provider.of<DoctorPatientProfileProvider>(context, listen: false);

    void findDocterPatientProfileByIdWithUpdate() {
      socket.emit('findDocterPatientProfileById', {
        "_id": mongoPatientUserId,
        ...doctorPatientInitialLimitsAndSkips,
      });
    }

    socket.off('findDocterPatientProfileByIdReturn');
    socket.on('findDocterPatientProfileByIdReturn', (data) {
      doctorPatientProfileProvider.setLoading(false);
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      final Map<String, dynamic> rawDoctorPatientProfile = data['user'];
      doctorPatientProfileProvider.setPatientProfile(rawDoctorPatientProfile);
    });

    socket.off('updatefindDocterPatientProfileById');
    socket.on('updatefindDocterPatientProfileById', (_) => findDocterPatientProfileByIdWithUpdate());
    findDocterPatientProfileByIdWithUpdate();
  }
}
