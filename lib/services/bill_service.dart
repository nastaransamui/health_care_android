import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health_care/models/bills.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/bill_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class BillService {
  Future<void> getSingleBillingForPatient(
    BuildContext context,
    String billId,
    String patientId,
    VoidCallback onDone,
  ) async {
    BillProvider billProvider = Provider.of<BillProvider>(context, listen: false);
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isLogin = authProvider.isLogin;
    if (!isLogin) return;
    void getSingleBillingForPatientWithUpdate() {
      socket.emit('getSingleBillingForPatient', {
        "billing_id": billId,
        "patientId": patientId,
      });
    }

    socket.off('getSingleBillingForPatientReturn');
    socket.on('getSingleBillingForPatientReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      final singleBill = data['singleBill'];
      if (singleBill is List && singleBill.isNotEmpty) {
        try {
          final singleBillData = Bills.fromMap(singleBill.first);
          billProvider.setBill(singleBillData);
          onDone();
          // ignore: empty_catches
        } catch (e) {}
      }
    });

    socket.off('updateGetSingleBillingForPatientReturn');
    socket.on('updateGetSingleBillingForPatientReturn', (_) => getSingleBillingForPatientWithUpdate());

    getSingleBillingForPatientWithUpdate();
  }

  Future<String> updateBillingPayment(
    BuildContext context,
    Map<String, dynamic> serverParams,
    bool updateMyInfo,
    Map<String, dynamic> newProfileInfo,
  ) async {
    bool isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return '';

    final completer = Completer<String>();

    socket.emit('updateBillingPayment', {"serverParams": serverParams, "updateMyInfo": updateMyInfo, "newProfileInfo": newProfileInfo});

    socket.once('updateBillingPaymentReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, '${data['reason']}');
        }
        if (!completer.isCompleted) {
          completer.complete('');
        }
      } else {
        final newBilling = data["newBilling"];
        final String billId = newBilling['_id'];
        completer.complete(billId);
      }
    });

    return completer.future;
  }
}
