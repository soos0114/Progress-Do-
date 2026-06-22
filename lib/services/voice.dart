import 'package:audioplayers/audioplayers.dart';

import '../data/script.dart';

/// Handles the looping ringtone and scripted voice clips.
class Voice {
  static final AudioPlayer _ring = AudioPlayer();
  static final AudioPlayer _speech = AudioPlayer();

  static Future<void> startRing() async {
    try {
      await _ring.setReleaseMode(ReleaseMode.loop);
      await _ring.play(AssetSource('audio/${CallScript.ringtoneFile}'));
    } catch (_) {}
  }

  static Future<void> stopRing() async {
    try {
      await _ring.stop();
    } catch (_) {}
  }

  static Future<void> speak(String fileName) async {
    try {
      await _speech.stop();
      await _speech.setReleaseMode(ReleaseMode.loop);
      await _speech.play(AssetSource('audio/$fileName'));
    } catch (_) {}
  }

  static Future<void> stopAll() async {
    await stopRing();
    try {
      await _speech.stop();
    } catch (_) {}
  }
}
