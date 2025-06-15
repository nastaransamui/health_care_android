import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:health_care/models/prescriptions.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/doctor_patient_profile_provider.dart';
import 'package:health_care/providers/prescription_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class PrescriptionService {
  Future<void> getPrescriptionRecord(BuildContext context, String userId) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return;
    if (!context.mounted) return;
    final DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    final PrescriptionProvider prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);

    void getPrescriptionRecordWithUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;

      socket.emit('getPrescriptionRecord', {
        "userId": userId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getPrescriptionRecordReturn');
    socket.on('getPrescriptionRecordReturn', (data) {
      if (!isLogin) return;
      if (!context.mounted) return;
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      final priscriptionRecords = data['priscriptionRecords'];
      final totalPrescriptions = data['totalPrescriptions'];

      if (priscriptionRecords is List) {
        prescriptionProvider.setLoading(false, notify: false);
        final prescriptionList = priscriptionRecords.map((json) => Prescriptions.fromMap(json)).toList();
        prescriptionProvider.setPrescriptions(prescriptionList);
        prescriptionProvider.setTotal(totalPrescriptions);
      }
    });

    socket.off('updateGetPrescriptionRecord');
    if (isLogin && context.mounted) {
      socket.on('updateGetPrescriptionRecord', (_) => getPrescriptionRecordWithUpdate());
    }

    getPrescriptionRecordWithUpdate();
  }

  Future<bool> deletePriscriptionRecord(BuildContext context, String doctorId, String deleteId) async {
    final completer = Completer<bool>();
    socket.emit('deletePriscriptionRecord', {
      "doctorId": doctorId,
      "deleteId": deleteId,
    });
    socket.once('deletePriscriptionRecordReturn', (data) {
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

  Future<String?> addPrescription(BuildContext context, Map<String, dynamic> payload) async {
    final completer = Completer<String?>();

    socket.emit('addPrescription', payload);

    socket.once('addPrescriptionReturn', (data) {
      if (data['status'] == 200) {
        // success
        final newPrescription = data['newPrescription'];
        final prescriptionId = newPrescription?['_id'];

        if (!completer.isCompleted) {
          completer.complete(prescriptionId); // return the _id or id
        }
      } else {
        // failure
        if (context.mounted) {
          showErrorSnackBar(context, data['message'] ?? 'Unknown error');
        }

        if (!completer.isCompleted) {
          completer.complete(null); // return null on error
        }
      }
    });

    return completer.future;
  }

  Future<void> findPrescriptionForDoctorProfileById(BuildContext context, String prescriptionMongoId) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return;
    if (!context.mounted) return;
     final DoctorPatientProfileProvider doctorPatientProfileProvider = Provider.of<DoctorPatientProfileProvider>(context, listen: false);

    void findPrescriptionForDoctorProfileByIdWithUpdate() {
      socket.emit('findPrescriptionForDoctorProfileById', {"_id": prescriptionMongoId});
    }

    socket.off('findPrescriptionForDoctorProfileByIdReturn');
    socket.on('findPrescriptionForDoctorProfileByIdReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      final Map<String, dynamic> rawDoctorPatientProfile = data['user'];
      doctorPatientProfileProvider.setPatientProfile(rawDoctorPatientProfile);
    });

    socket.off('updatefindPrescriptionForDoctorProfileById');
    if (isLogin && context.mounted) {
      socket.on('updatefindPrescriptionForDoctorProfileById', (_) => findPrescriptionForDoctorProfileByIdWithUpdate());
    }

    findPrescriptionForDoctorProfileByIdWithUpdate();
  }

  Future<bool> editPrescription(BuildContext context, Map<String,dynamic> payload) async{
        final completer = Completer<bool>();
    socket.emit('editPrescription', payload);
    socket.once('editPrescriptionReturn', (data) {
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
