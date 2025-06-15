import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/billing_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class BillsService {
  Future<void> getBillingRecord(BuildContext context) async {
    final dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    final billingProvider = Provider.of<BillingProvider>(context, listen: false);
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
    billingProvider.setLoading(true);
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
      if (context.mounted) {
        billingProvider.setLoading(false);
      }
      final billingRecords = data['billingRecords'];
      final totalBilling = data['totalBilling'];
      if (billingRecords is List && billingRecords.isNotEmpty) {
        try {
          final billingList = (billingRecords).map((json) => Bills.fromMap(json)).toList();
          billingProvider.setDoctorsBills(billingList);

          // ignore: empty_catches
        } catch (e) {
          log('$e');
          // showErrorSnackBar(context, '$e');
          // billingProvider.setDoctorsBills([]);
          // billingProvider.setTotal(0);
        }
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

    billingProvider.setLoading(true);
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
      if (context.mounted) {
        billingProvider.setLoading(false);
      }
      final billingRecords = data['billingRecords'];
      final totalBilling = data['totalBilling'];
      if (billingRecords is List && billingRecords.isNotEmpty) {
        try {
          final billingList = (billingRecords).map((json) => Bills.fromMap(json)).toList();
          billingProvider.setDoctorsBills(billingList);

          // ignore: empty_catches
        } catch (e) {
          log('$e');
          // showErrorSnackBar(context, '$e');
          // billingProvider.setDoctorsBills([]);
          // billingProvider.setTotal(0);
        }
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
}
