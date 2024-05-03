import 'package:flutter/material.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class SpecialitiesService {
  Future<void> getSpecialitiesData(BuildContext context) async {
    var specialitiesProvider =
        Provider.of<SpecialitiesProvider>(context, listen: false);

    socket.on('getSpecialitiesFromAdmin', (data) {
      specialitiesProvider.setSpecialities(data);
    });
  }
}
