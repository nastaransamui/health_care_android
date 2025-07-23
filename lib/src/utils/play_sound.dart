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
AudioPlayer? incomingCallPlayer;
bool isPlaying = false;

Future<void> incomingCallSound(bool play) async {
  try {
    if (play) {
      if (isPlaying) return;

      // Always create a new instance to avoid disposed issues
      incomingCallPlayer = AudioPlayer();
      await incomingCallPlayer!.setReleaseMode(ReleaseMode.loop);
      await incomingCallPlayer!.play(
        AssetSource('sound/incoming-call.mp3'),
        volume: 1.0,
      );

      isPlaying = true;
    } else {
      if (!isPlaying) return;

      await incomingCallPlayer?.stop();
      await incomingCallPlayer?.dispose();
      incomingCallPlayer = null;

      isPlaying = false;
    }
  } catch (e) {
    log("Error handling incoming call sound: $e");
    isPlaying = false;
    incomingCallPlayer = null;
  }
}
