
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isAppUpdated() async {
  final prefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();

  final currentVersion = packageInfo.version;
  final lastKnownVersion = prefs.getString('last_known_version');

 if (lastKnownVersion != currentVersion) {
    await prefs.setString('last_known_version', currentVersion);
    return true;
  }

  return false;
}