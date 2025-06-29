
import 'package:flutter/material.dart';
import 'package:health_care/models/doctors.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class DoctorsService {
  Future<void> getDoctorsData(BuildContext context, Map<String, dynamic> queryParameters) async {
    var doctorsProvider = Provider.of<DoctorsProvider>(context, listen: false);
    void doctorWithUpdate() {
      socket.emit('doctorSearch', queryParameters);
      socket.on('doctorSearchReturn', (data) {
        if (data['status'] == 200) {
          doctorsProvider.setDoctors(data['doctors']);
        }
      });
    }

    doctorWithUpdate();
  }

  Future<void> doctorSearch(BuildContext context, Map<String, dynamic> payload, VoidCallback onDone) async {
    DoctorsProvider doctorsProvider = Provider.of<DoctorsProvider>(context, listen: false);

    void doctorSearchWithUpdate(payload) {
      socket.emit('doctorSearch', payload);
    }

    socket.off('doctorSearchReturn');
    socket.on('doctorSearchReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      final doctors = data['doctors'];
      final total = data['total'];

      if (doctors is List) {
        final doctorsList = doctors.map((json) => Doctors.fromJson(json)).toList();
        doctorsProvider.setDoctorsSearch(doctorsList);
        if (total != null) {
          doctorsProvider.setTotal(total);
        } else {
          doctorsProvider.setTotal(0);
          onDone();
        }
        // onDone();
      } else {
        doctorsProvider.setDoctorsSearch([]);
        doctorsProvider.setTotal(0);
        onDone();
      }
    });

    socket.off('updateDoctorSearch');
    socket.on('updateDoctorSearch', (_) => doctorSearchWithUpdate(payload));
    doctorSearchWithUpdate(payload);
  }

  Future<void> findUserById(BuildContext context, String id, VoidCallback onDone) async {
    var doctorsProvider = Provider.of<DoctorsProvider>(context, listen: false);
    void findUserByIdWithUpdate() {
      socket.emit('findUserById', {"_id": id});
    }

    socket.off('findUserByIdReturn');
    socket.on('findUserByIdReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      final singleDoctor = DoctorUserProfile.fromMap(data['user']);
      doctorsProvider.setSingleDoctor(singleDoctor);
      onDone();
    });
    socket.off('updateFindUserById');
    socket.on('updateFindUserById', (data) => findUserByIdWithUpdate());
    findUserByIdWithUpdate();
  }
}
