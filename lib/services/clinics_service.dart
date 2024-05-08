import 'package:flutter/material.dart';
import 'package:health_care/providers/clinics_provider.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';


class ClinicsService {


  Future<void> getClinicData(BuildContext context) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    var clinicsProvider = Provider.of<ClinicsProvider>(context, listen: false);
    socket.on('getClinicStatusFromAdmin', (data) {
      
      clinicsProvider.setClinics(data);
    });
  }
}
