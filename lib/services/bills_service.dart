import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/billing_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/doctor_patient_profile_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class BillsService {
  Future<void> getBillingRecord(BuildContext context) async {
    final dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    final billingProvider = Provider.of<BillingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLogin = authProvider.isLogin;
    if (!isLogin) return;

    String? doctorId;
    String? patientId;

    final roleName = authProvider.roleName;

    if (roleName == 'doctors') {
      doctorId = authProvider.doctorsProfile?.userId;
      patientId = null;
    } else if (roleName == 'patient') {
      patientId = authProvider.patientProfile?.userId;
      doctorId = null;
    }

    void getBillingRecordWithUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      final payload = {
        if (doctorId != null) 'doctorId': doctorId,
        if (patientId != null) 'patientId': patientId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      };
      socket.emit('getBillingRecord', payload);
    }

    socket.off('getBillingRecordReturn');
    socket.on('getBillingRecordReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (context.mounted && isLogin) {
        billingProvider.setLoading(false);
      }
      final billingRecords = data['billingRecords'];
      final totalBilling = data['totalBilling'];
      if (billingRecords is List && billingRecords.isNotEmpty) {
        try {
          final billingList = (billingRecords).map((json) => Bills.fromMap(json)).toList();
          billingProvider.setDoctorsBills(billingList);

          // ignore: empty_catches
        } catch (e) {}
        final int finalTotal = totalBilling;
        billingProvider.setTotal(finalTotal);
      } else {
        billingProvider.setDoctorsBills([]);
        billingProvider.setTotal(0);
      }
    });

    socket.off('updateGetBillingRecord');
    socket.on('updateGetBillingRecord', (_) => getBillingRecordWithUpdate());
    getBillingRecordWithUpdate();
  }

  Future<void> getPatientBillingRecord(BuildContext context, String patientId) async {
    final dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    final billingProvider = Provider.of<BillingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLogin = authProvider.isLogin;
    if (!isLogin) return;
    void getBillingRecordWithUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      final payload = {
        'patientId': patientId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      };
      socket.emit('getBillingRecord', payload);
    }

    socket.off('getBillingRecordReturn');
    socket.on('getBillingRecordReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (context.mounted && isLogin) {
        billingProvider.setLoading(false);
      }
      final billingRecords = data['billingRecords'];
      final totalBilling = data['totalBilling'];
      if (billingRecords is List && billingRecords.isNotEmpty) {
        try {
          final billingList = (billingRecords).map((json) => Bills.fromMap(json)).toList();
          billingProvider.setDoctorsBills(billingList);

          // ignore: empty_catches
        } catch (e) {}
        final int finalTotal = totalBilling;
        billingProvider.setTotal(finalTotal);
      } else {
        billingProvider.setDoctorsBills([]);
        billingProvider.setTotal(0);
      }
    });

    socket.off('updateGetBillingRecord');
    socket.on('updateGetBillingRecord', (_) => getBillingRecordWithUpdate());
    getBillingRecordWithUpdate();
  }

  Future<bool> deleteBillingRecord(BuildContext context, List<String> deleteId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    String? doctorId;
    String? patientId;

    final roleName = authProvider.roleName;

    if (roleName == 'doctors') {
      doctorId = authProvider.doctorsProfile?.userId;
      patientId = null;
    } else if (roleName == 'patient') {
      patientId = authProvider.patientProfile?.userId;
      doctorId = null;
    }

    final completer = Completer<bool>();

    void deleteBillingRecordWithUpdate() {
      final payload = {
        if (doctorId != null) 'doctorId': doctorId,
        if (patientId != null) 'patientId': patientId,
        "deleteId": deleteId,
      };
      socket.emit('deleteBillingRecord', payload);
    }

    socket.off('deleteBillingRecordReturn');
    socket.on('deleteBillingRecordReturn', (data) {
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

    deleteBillingRecordWithUpdate();

    return completer.future;
  }

  Future<String?> updateBilling(BuildContext context, Map<String, dynamic> payload) async {
    final completer = Completer<String?>();

    socket.emit('updateBilling', payload);

    socket.once('updateBillingReturn', (data) {
      if (data['status'] == 200) {
        // success
        final newBilling = data['newBilling'];
        final billId = newBilling?['_id'];

        if (!completer.isCompleted) {
          completer.complete(billId);
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

  Future<void> findBillingForDoctorProfileById(BuildContext context, String billMongoId) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return;
    if (!context.mounted) return;
    final DoctorPatientProfileProvider doctorPatientProfileProvider = Provider.of<DoctorPatientProfileProvider>(context, listen: false);

    void findBillingForDoctorProfileByIdWithUpdate() {
      socket.emit('findBillingForDoctorProfileById', {"_id": billMongoId});
    }

    socket.off('findBillingForDoctorProfileByIdReturn');
    socket.on('findBillingForDoctorProfileByIdReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      final Map<String, dynamic> rawDoctorPatientProfile = data['user'];
      doctorPatientProfileProvider.setPatientProfile(rawDoctorPatientProfile);
    });

    socket.off('updatefindBillingForDoctorProfileById');
    if (isLogin && context.mounted) {
      socket.on('updatefindBillingForDoctorProfileById', (_) => findBillingForDoctorProfileByIdWithUpdate());
    }

    findBillingForDoctorProfileByIdWithUpdate();
  }
}
