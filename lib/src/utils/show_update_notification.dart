
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> showUpdateDialog(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text("Update Available"),
      content: const Text("Please update to the latest version for best experience."),
      actions: [
        TextButton(
          onPressed: () async {
            final url = Uri.parse(
                "https://play.google.com/store/apps/details?id=com.healthCareApp&pli=1");
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
           if(context.mounted) Navigator.of(context).pop(); // close dialog after pressing
          },
          child: const Text("Update"),
        ),
      ],
    ),
  );
}

Future<void> showChatNotification(RemoteMessage message) async {
  final data = message.data;
  final roomId = data['roomId'];
  final type = data['type'];
  // final attachment = data['attachment'];
  // final clickAction = data['click_action'];
  final notification = message.notification;
  final android = message.notification?.android;

  final title = notification?.title ?? 'New Message';
  final body = notification?.body ?? '';
  final imageUrl = android?.imageUrl;
  if(type != 'endVoiceCall'){

  BigPictureStyleInformation? styleInfo;
  Map<String, String> payload = {
    "roomId": roomId,
  };

  try {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;

        styleInfo = BigPictureStyleInformation(
          ByteArrayAndroidBitmap(imageBytes),
          largeIcon: ByteArrayAndroidBitmap(imageBytes),
          contentTitle: title,
          summaryText: body,
        );
      }
    }
  } catch (e) {
    log("❌ Failed to load image: $e");
  }

  final androidDetails = AndroidNotificationDetails(
    'chat_channel_v3',
    'Chat Notifications',
    channelDescription: 'Notifications for new chat messages',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    sound: const RawResourceAndroidNotificationSound('recive_message'),
    icon: 'ic_stat_notify', // must be a valid PNG in drawable folder
    styleInformation: styleInfo ?? BigTextStyleInformation(body),
    color: const Color(0xFF2196F3),
    ledColor: const Color(0xFF2196F3),
    ledOffMs: 12,
    ledOnMs: 12,
    colorized: true,
  );

  final notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
    payload: jsonEncode(payload),
  );
  }
}
