import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:health_care/models/dependents.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/dependents_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class DependentsService {
  Future<void> getPatientDependent(BuildContext context) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return;
    DataGridProvider dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    DependentsProvider dependentsProvider = Provider.of<DependentsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String userId = authProvider.patientProfile!.userId;
    void getPatientDependentWithUpdate() {
      final paginationModel = dataGridProvider.paginationModel;
      final sortModel = dataGridProvider.sortModel;
      final mongoFilterModel = dataGridProvider.mongoFilterModel;
      socket.emit('getPatientDependent', {
        "userId": userId,
        "paginationModel": paginationModel,
        "sortModel": sortModel,
        "mongoFilterModel": mongoFilterModel,
      });
    }

    socket.off('getPatientDependentReturn');
    socket.on('getPatientDependentReturn', (data) {
      dependentsProvider.setLoading(false);
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }

      if (data['status'] == 200) {
        final dependents = data['dependents'];
        final totalDepends = data['totalDepends'];
        if (dependents is List && dependents.isNotEmpty) {
          final dependentsList = dependents.map((json) => Dependents.fromMap(json)).toList();
          dependentsProvider.setDependents(dependentsList);
          dependentsProvider.setTotal(totalDepends);
        } else {
          dependentsProvider.setTotal(0);
          dependentsProvider.setDependents([]);
        }
      }
    });

    socket.off('updateGetPatientDependent');
    socket.on('updateGetPatientDependent', (_) => getPatientDependentWithUpdate());

    getPatientDependentWithUpdate();
  }

  Future<bool> deleteDependent(BuildContext context, List<String> deleteId) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return false;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String userId = authProvider.patientProfile!.userId;

    final completer = Completer<bool>();
    void deleteDependentWithUpdate() {
      socket.emit('deleteDependent', {"userId": userId, "deleteId": deleteId});
    }

    socket.off('deleteDependentReturn');
    socket.on('deleteDependentReturn', (data) {
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

    deleteDependentWithUpdate();

    return completer.future;
  }

  Future<bool> updateDependent(BuildContext context, Map<String, dynamic> payload) async {
    var isLogin = Provider.of<AuthProvider>(context, listen: false).isLogin;
    if (!isLogin) return false;

    final completer = Completer<bool>();
    void updateDependentWithUpdate() {
      socket.emit('updateDependent', payload);
    }

    socket.off('updateDependentReturn');
    socket.on('updateDependentReturn', (data) {
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

    updateDependentWithUpdate();

    return completer.future;
  }
}
