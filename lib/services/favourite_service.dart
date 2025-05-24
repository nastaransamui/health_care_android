// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/favourites_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class FavouriteService {
  Future<void> getFavPatientsForDoctorProfile(BuildContext context, List<dynamic> favIds) async {
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    FavouritesProvider favouritesProvider = Provider.of<FavouritesProvider>(context, listen: false);
    
    final String roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String userId = "";
    if (roleName == 'doctors') {
      userId = authProvider.doctorsProfile!.userId;
    } else if (roleName == 'patient') {
      userId = authProvider.patientProfile!.userId;
    }
    favouritesProvider.setLoading(true);
    void getFavPatientsForDoctorProfileWithUpdate(List<dynamic> favIds) {
      final freshPagination = dataGridProvider.paginationModel;
      final freshSort = dataGridProvider.sortModel;
      final freshFilter = dataGridProvider.mongoFilterModel;
      socket.emit("getFavPatientsForDoctorProfile", {
        "userId": userId,
        "favIdArray": favIds,
        "paginationModel": freshPagination,
        "sortModel": freshSort,
        "mongoFilterModel": freshFilter,
      });
    }

    socket.off('getFavPatientsForDoctorProfileReturn'); // remove previous to avoid stacking
    socket.on('getFavPatientsForDoctorProfileReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 200) {
        final userFavProfile = data['userFavProfile'];
        if (userFavProfile is List && userFavProfile.isNotEmpty) {
          final patients = userFavProfile[0]['patients'];
          final totalCount = userFavProfile[0]['totalCount'];
          favouritesProvider.setTotal(totalCount);
          try {
            favouritesProvider.setUserFavProfile([]);
            final patientsList = (patients as List).map((json) => PatientUserProfile.fromMap(json)).toList();
            favouritesProvider.setUserFavProfile(patientsList);
            favouritesProvider.setLoading(false);
          } catch (e) {}
        }
      }
    });


    socket.off('updateGetFavPatientsForDoctorProfile');
    socket.on('updateGetFavPatientsForDoctorProfile', (data) {
      favouritesProvider.setLoading(true);
      getFavPatientsForDoctorProfileWithUpdate(data['doctor']);
    });
    socket.off('updateGetFavPatientsForDoctorProfilePatient');
    socket.on('updateGetFavPatientsForDoctorProfilePatient', (data) {
      final AuthService authService = AuthService();
      authService.updateLiveAuth(context);
      Future.delayed(const Duration(milliseconds: 2000), () {
        final doctorProfile = authProvider.doctorsProfile;
        final favIds = doctorProfile?.userProfile.favsId;
        getFavPatientsForDoctorProfileWithUpdate(favIds!);
      });
    });
    getFavPatientsForDoctorProfileWithUpdate(favIds);
  }
}
