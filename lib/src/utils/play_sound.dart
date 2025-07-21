import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';

Future<void> playSendMessageSound() async {
  final player = AudioPlayer();
  try {
    await player.play(AssetSource('sound/send-message.mp3'));
  } catch (e) {
    log("Error playing sound: $e");
  }
}

Future<void> playReciveMessageSound() async {
  final player = AudioPlayer();
  try {
    await player.play(AssetSource('sound/recive-message.mp3'));
  } catch (e) {
    log("Error playing sound: $e");
  }
}

Future<void> playIncomingCallSound() async {
  final player = AudioPlayer();
  try {
    await player.play(AssetSource('sound/incoming-call.mp3'));
  } catch (e) {
    log("Error playing sound: $e");
  }
}
