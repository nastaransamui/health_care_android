import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> showUpdateNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'update_channel',
    'App Updates',
    icon: 'ic_stat_notify',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  enableLights: true,
  );

  const NotificationDetails details = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'App Updated!',
    'Thanks for updating to the latest version.',
    details,
    payload: 'open_play_store',
  );
}
