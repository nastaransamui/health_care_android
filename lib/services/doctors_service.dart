
import 'package:flutter/material.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:session_storage/session_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class DoctorsService {
  Future<void> getDoctorsData(BuildContext context, Map<String, dynamic> queryParameters) async {
    var doctorsProvider = Provider.of<DoctorsProvider>(context, listen: false);
    void doctorWithUpdate() {
      socket.emit('doctorSearch', queryParameters );
      socket.on('doctorSearchReturn', (data) {
        if (data['status'] == 200) {
          doctorsProvider.setDoctors(data['doctors']);
        }
      });
    }

    doctorWithUpdate();

    // socket.on('updateDoctorSearch', (data) {
    //   doctorWithUpdate();
    // });
  }

   Future<void> searchDoctorsData(BuildContext context, Map<String, dynamic> queryParameters) async {
    var doctorsProvider = Provider.of<DoctorsProvider>(context, listen: false);
final session = SessionStorage();
    void searchWithUpdate() {
      socket.emit('doctorSearch', {...queryParameters, "limit": int.parse(session['limit']!)} );
      socket.on('doctorSearchReturn', (data) {
        if (data['status'] == 200) {
          doctorsProvider.setDoctorsSearch(data['doctors'],  data['total']?? 0);
        }
      });
    }

    searchWithUpdate();

    socket.on('updateDoctorSearch', (data) {
      searchWithUpdate();
    });
  }
}
