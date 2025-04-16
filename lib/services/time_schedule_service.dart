import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/doctors_time_slot.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/data_grid_provider.dart';
import 'package:health_care/providers/time_schedule_provider.dart';
import 'package:provider/provider.dart';
import 'package:health_care/stream_socket.dart';

class TimeScheduleService {
  Future<void> getDoctorTimeSlots(BuildContext context, DoctorsProfile doctorProfile) async {
    var dataGridProvider = Provider.of<DataGridProvider>(context, listen: false);
    final String userId = doctorProfile.userId;
    final Map<String, int> paginationModel = dataGridProvider.paginationModel;
    final List<Map<String, dynamic>> sortModel = dataGridProvider.sortModel;
    Map<String, Map<String, dynamic>> mongoFilterModel = dataGridProvider.mongoFilterModel;
    var timeScheduleProvider = Provider.of<TimeScheduleProvider>(context, listen: false);
    timeScheduleProvider.setLoading(true);

    void getScheduleWithUpdate() {
      socket.emit(
          'getDoctorTimeSlots', {"userId": userId, "paginationModel": paginationModel, "sortModel": sortModel, "mongoFilterModel": mongoFilterModel});
    }

// 🔐 Attach socket listener ONCE
    socket.off('getDoctorTimeSlotsReturn'); // remove previous to avoid stacking
    socket.on('getDoctorTimeSlotsReturn', (data) {

      if (data['status'] != 200 && data['status'] != 400) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (data['status'] == 400) {
        timeScheduleProvider.setDoctorsTimeSlot(null);
      }
      if (data['status'] == 200) {
        timeScheduleProvider.setDoctorsTimeSlot(
          DoctorsTimeSlot.fromJson(data['timeSlots'][0]),
        );
      }
    });

    // 🔁 Listen to update and re-fetch if needed
    socket.off('updateGetDoctorTimeSlots');
    socket.on('updateGetDoctorTimeSlots', (_) => getScheduleWithUpdate());
      getScheduleWithUpdate();

  }

  Future<void> createDoctorsTimeslots(
    BuildContext context,
    Map<String, dynamic> doctorsTimeSlot,
  ) async {
    var timeScheduleProvider = Provider.of<TimeScheduleProvider>(context, listen: false);
    timeScheduleProvider.setLoading(true);
    socket.emit('createDoctorsTimeslots', doctorsTimeSlot);
    socket.on('createDoctorsTimeslotsReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          timeScheduleProvider.setLoading(false);
          showErrorSnackBar(context, data['message']);
        }
      }
      if (data['status'] == 200) {
        timeScheduleProvider.setDoctorsTimeSlot(
          DoctorsTimeSlot.fromJson(data['doctorAvailableTimeSlot']),
        );
      }
    });
  }

  Future<bool> deleteDoctorsTimeslots(
    BuildContext context,
    DoctorsTimeSlot doctorAvailableTimes,
  ) async {
    var timeScheduleProvider = Provider.of<TimeScheduleProvider>(context, listen: false);
    timeScheduleProvider.setLoading(true);
    Map<String, dynamic> doctorsTimeSlot = DoctorsTimeSlot.cleanDoctorsTimeSlotJson(doctorAvailableTimes);

    final completer = Completer<bool>();

    socket.emit('deleteDoctorsTimeslots', doctorsTimeSlot);

    void socketListener(dynamic data) {
      socket.off('deleteDoctorsTimeslotsReturn', socketListener); // Clean up listener

      if (data['status'] != 200) {
        if (context.mounted) {
          timeScheduleProvider.setLoading(false);
          showErrorSnackBar(context, data['message']);
        }
        completer.complete(false);
      } else {
        timeScheduleProvider.setLoading(false);
        timeScheduleProvider.setDoctorsTimeSlot(null);
        showErrorSnackBar(context, data['message']); // Optional: success snackbar
        completer.complete(true);
      }
    }

    socket.on('deleteDoctorsTimeslotsReturn', socketListener);

    return completer.future;
  }

    Future<void> updateDoctorsTimeslots(
    BuildContext context,
    Map<String, dynamic> doctorsTimeSlot,
  ) async {
    var timeScheduleProvider = Provider.of<TimeScheduleProvider>(context, listen: false);
    timeScheduleProvider.setLoading(true);
    socket.emit('updateDoctorsTimeslots', doctorsTimeSlot);
    socket.on('updateDoctorsTimeslotsReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          timeScheduleProvider.setLoading(false);
          showErrorSnackBar(context, data['message']);
        }
      }
      if (data['status'] == 200) {
        timeScheduleProvider.setDoctorsTimeSlot(
          DoctorsTimeSlot.fromJson(data['doctorAvailableTimeSlot']),
        );
      }
    });
  }

}

void showErrorSnackBar(BuildContext context, String message) {
  if (!context.mounted) return; // Prevent using context after dispose
  final snackBar = SnackBar(
    backgroundColor: Theme.of(context).primaryColorLight,
    content: Text(
      message,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    duration: const Duration(seconds: 3),
  );

  if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
