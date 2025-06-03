
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:health_care/models/bank.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/bank_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class BankService {
  Future<BankWithReservations?> getUserBankDataWithReservation(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bankProvider = Provider.of<BankProvider>(context, listen: false);
    final String userId = authProvider.doctorsProfile!.userId;

    final completer = Completer<BankWithReservations?>();

    void getUserBankDataWithReservationWithUpdate() {
      socket.emit("getUserBankDataWithReservation", {"userId": userId});
    }

    socket.off('getUserBankDataWithReservationReturn');
    socket.on('getUserBankDataWithReservationReturn', (data) {
  if (completer.isCompleted) return;

  if (data['status'] != 200) {
    if (context.mounted) {
      showErrorSnackBar(context, data['message']);
    }
    completer.complete(null);
    return;
  }

  final bankWithReservations = BankWithReservations.fromMap(data['bankWithReservations']);
  bankProvider.setBankWithReservations(bankWithReservations);
  completer.complete(bankWithReservations);
});

    socket.off('updateGetUserBankDataWithReservation');
    socket.on('updateGetUserBankDataWithReservation', (_) => getUserBankDataWithReservationWithUpdate());

    getUserBankDataWithReservationWithUpdate();

    return completer.future;
  }
}