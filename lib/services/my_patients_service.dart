
import 'package:flutter/widgets.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/my_patients_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class MyPatientsService {
  Future<void> getMyPatientsProfile(BuildContext context, List<dynamic> patientsIdArray) async {
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    MyPatientsProvider myPatientsProvider = Provider.of<MyPatientsProvider>(context, listen: false);
    final String roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String userId = "";
    if (roleName == 'doctors') {
      userId = authProvider.doctorsProfile!.userId;
    } else if (roleName == 'patient') {
      userId = authProvider.patientProfile!.userId;
    }
    myPatientsProvider.setLoading(true);
    void getMyPatientsProfileWithUpdate(List<dynamic> patientsIdArray) {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      socket.emit('getMyPatientsProfile', {
        "userId": userId,
        "patientsIdArray": patientsIdArray,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getMyPatientsProfileReturn');
    socket.on('getMyPatientsProfileReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        final myPatientsProfile = data['myPatientsProfile'];
        if (myPatientsProfile is List && myPatientsProfile.isNotEmpty) {
          final patients = myPatientsProfile[0]['patients'];
          final totalCount = myPatientsProfile[0]['totalCount'];
          myPatientsProvider.setTotal(totalCount);
          try {
            myPatientsProvider.setMyPatientsProfile([]);
            final patientsList = (patients as List).map((json) => PatientUserProfile.fromMap(json)).toList();
            myPatientsProvider.setMyPatientsProfile(patientsList);
            myPatientsProvider.setLoading(false);
          // ignore: empty_catches
          } catch (e) {}
        }else{
          myPatientsProvider.setMyPatientsProfile([]);
          myPatientsProvider.setLoading(false);
        }
      }
    });

socket.off('updateGetMyPatientsProfile');
    socket.on('updateGetMyPatientsProfile', (data) {
      final AuthService authService = AuthService();
      authService.updateLiveAuth(context);
      Future.delayed(const Duration(milliseconds: 2000), () {
        final doctorProfile = authProvider.doctorsProfile;
        final patientsIdArray = doctorProfile?.userProfile.patientsId;
        getMyPatientsProfileWithUpdate(patientsIdArray!);
      });
    });
    getMyPatientsProfileWithUpdate(patientsIdArray);
  }
}
