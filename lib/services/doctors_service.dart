import 'package:flutter/material.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class DoctorsService {
  Future<void> getDoctorsData(BuildContext context) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    var doctorsProvider = Provider.of<DoctorsProvider>(context, listen: false);
    void doctorWithUpdate() {
      socket.emit('doctorSearch', {
        "keyWord": null,
        "specialities": null,
        "gender": null,
        "country": null,
        "state": null,
        "city": null,
        "sortBy": 'profile.userName',
        "limit": 10,
        "skip": 0,
      });
      socket.once('doctorSearchReturn', (data) {
        // print(data['doctors'][0]['status']);
        if (data['status'] == 200) {
          doctorsProvider.setDoctors(data['doctors']);
        }
      });
    }

    doctorWithUpdate();

    socket.once('updateDoctorSearch', (data) {
      print(data);
      doctorWithUpdate();
      // doctorsProvider.setDoctors(data);
    });
  }
}
