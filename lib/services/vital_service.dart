import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/models/users.dart';
import 'package:health_care/providers/vital_provider.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VitalService {
  Future<void> getVitalSignsData(BuildContext context) async {
    var vitalSignsProvider = Provider.of<VitalProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    late String userId = '';
    final String? profile = prefs.getString('profile');

    final parsedPatient = PatientsProfile.fromJson(
      jsonEncode(
        jsonDecode(profile!),
      ),
    );
    userId = parsedPatient.userId;
    socket.on(
      'getVitalSignFromAdmin',
      (data) {
        vitalSignsProvider.setVitalSigns(data);
      },
    );
    socket.emit('getVitalSign', {"userId": userId, "limit": 5, "skip": 0, "sort": { "date": -1 } });
    socket.on(
      'getVitalSignReturn',
      (data) {
          if (data['status'] == 200) {
          vitalSignsProvider.setVitalSigns(data['vitalSign']);
        }
      },
    );
  }
}
