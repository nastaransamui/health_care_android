
import 'package:flutter/material.dart';
import 'package:health_care/providers/device_provider.dart';
import 'package:provider/provider.dart';

class DeviceService{
  Future<void> getDeviceService(BuildContext context) async {
    var deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

    deviceProvider.initPlatformState();
  }
}