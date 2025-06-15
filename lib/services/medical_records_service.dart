import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:health_care/models/medical_records.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/medical_records_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class MedicalRecordsService {
  Future<void> getMedicalRecordWithDependent(BuildContext context, String userId) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return;
    final DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    final MedicalRecordsProvider medicalRecordsProvider = Provider.of<MedicalRecordsProvider>(context, listen: false);

    void getMedicalRecordWithDependentWithUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;

      socket.emit('getMedicalRecordWithDependent', {
        "userId": userId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getMedicalRecordWithDependentReturn');
    socket.on('getMedicalRecordWithDependentReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      final medicalRecords = data['medicalRecords'];
      final totalMedical = data['totalMedical'];

      if (medicalRecords is List) {
        medicalRecordsProvider.setLoading(false);
        final medicalList = medicalRecords.map((json) => MedicalRecords.fromMap(json)).toList();
        medicalRecordsProvider.setMedicalRecords(medicalList);
        medicalRecordsProvider.setTotal(totalMedical);
      }
    });

    socket.off('updateGetMedicalRecordWithDependent');
    socket.on('updateGetMedicalRecordWithDependent', (_) => getMedicalRecordWithDependentWithUpdate());
    getMedicalRecordWithDependentWithUpdate();
  }

  Future<bool> deleteMedicalRecord(BuildContext context, String userId, List<String> deleteIds) async {
    final completer = Completer<bool>();

    void deleteMedicalRecordWithUpdate() {
      socket.emit('deleteMedicalRecord', {'userId': userId, 'deleteIds': deleteIds});
    }

    socket.off('deleteMedicalRecordReturn');
    socket.on('deleteMedicalRecordReturn', (data) {
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

    deleteMedicalRecordWithUpdate();
    return completer.future;
  }

  Future<bool> updateMedicalRecord(BuildContext context, Map<String, dynamic> payload) async {
    final completer = Completer<bool>();
    socket.emit('updateMedicalRecord', payload);
    socket.once('updateMedicalRecordReturn', (data) {
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
    return completer.future;
  }
}
