import 'package:permission_handler/permission_handler.dart';

Future<bool> checkMicrophonePermission() async {
  final status = await Permission.microphone.request();
  return status.isGranted;
}
