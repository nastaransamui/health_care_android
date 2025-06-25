import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health_care/models/vital_signs.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/vital_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class VitalService {
  Future<void> getVitalSignsData(BuildContext context) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    var vitalSignsProvider = Provider.of<VitalProvider>(context, listen: false);
    late String userId = authProvider.patientProfile!.userId;
    socket.once(
      'getVitalSignFromAdmin',
      (data) {
        vitalSignsProvider.setVitalSigns(data['vitalSign']);
      },
    );
    socket.emit('getVitalSign', {
      "userId": userId,
      "limit": 5,
      "skip": 0,
      "sort": {"date": -1}
    });
    socket.on(
      'getVitalSignReturn',
      (data) {
        if (data['status'] == 200) {
          vitalSignsProvider.setVitalSigns(data['vitalSign']);
        }
      },
    );
  }

  Future<void> getVitalSignForMedicalRecords(BuildContext context, String vitalName) async {
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    VitalProvider vitalProvider = Provider.of<VitalProvider>(context, listen: false);
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    String userId = authProvider.patientProfile!.userId;
    vitalProvider.setLoading(true);

    void getVitalSignForMedicalRecordsWidthUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      socket.emit('getVitalSignForMedicalRecords', {
        "userId": userId,
        "vitalName": vitalName,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getVitalSignForMedicalRecordsReturn');
    socket.on('getVitalSignForMedicalRecordsReturn', (data) {
      vitalProvider.setLoading(false);
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message'] ?? data['reason']);
        }
        return;
      }
      if (data['status'] == 200) {
        final vitalRecords = data['vitalRecords'];
        final int totalRecords = data['totalRecords'];
        if (vitalRecords is List && vitalRecords.isNotEmpty) {
          final vitalRecordsList = vitalRecords.map((json) => VitalSignValues.fromMap(json['vitalData'])).toList();
          vitalProvider.setVitalSignValues(vitalRecordsList);
          vitalProvider.setTotal(totalRecords);
        } else {
          vitalProvider.setVitalSignValues([]);
          vitalProvider.setTotal(0);
        }
      }
    });
    socket.off('updateVitalSignForMedicalRecords');
    socket.on('updateVitalSignForMedicalRecords', (_) => getVitalSignForMedicalRecordsWidthUpdate());

    getVitalSignForMedicalRecordsWidthUpdate();
  }

  Future<bool> vitalSignDelete(BuildContext context, String name, List<int> deleteIds) async {
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    String userId = authProvider.patientProfile!.userId;
    final completer = Completer<bool>();

    void vitalSignDeleteWithUpdate() {
      socket.emit('vitalSignDelete', {
        'userId': userId,
        "name": name,
        'deleteId': deleteIds,
      });
    }

    socket.off('vitalSignDeleteReturn');
    socket.on('vitalSignDeleteReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      } else {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });

    vitalSignDeleteWithUpdate();
    return completer.future;
  }
}
