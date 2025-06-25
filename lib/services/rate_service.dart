
import 'package:flutter/material.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart' show DataGridProvider;
import 'package:health_care/providers/rate_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class RateService {
  Future<void> getAuthorRates(BuildContext context) async {
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    RateProvider rateProvider = Provider.of<RateProvider>(context, listen: false);
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    String authorId = authProvider.patientProfile!.userId;
    rateProvider.setLoading(true);

    void getAuthorRatesWidthUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      socket.emit('getAuthorRates', {
        "authorId": authorId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getAuthorRatesReturn');
    socket.on('getAuthorRatesReturn', (data) {
      rateProvider.setLoading(false);
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message'] ?? data['reason']);
        }
        return;
      }
      if (data['status'] == 200) {
        final rateArray = data['rateArray'];
        final totalReviews = data['totalReviews'];
        if (rateArray is List && rateArray.isNotEmpty) {
          final List<double> ratesList = rateArray.map((e) => (e as num).toDouble()).toList();
          rateProvider.setRateArray(ratesList);
          rateProvider.setTotal(totalReviews);
        } else {
          rateProvider.setRateArray([]);
          rateProvider.setTotal(0);
        }
      }
    });
    socket.off('updateGetAuthorRates');
    socket.on('updateGetAuthorRates', (_) => getAuthorRatesWidthUpdate());

    getAuthorRatesWidthUpdate();
  }
}
