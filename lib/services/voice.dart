import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../data/script.dart';

/// Handles the looping ringtone and scripted voice clips.
class Voice {
  // Ringtone and speech never need to overlap. Keeping them on one native
  // player avoids audio-focus contention while answering a call.
  static final AudioPlayer _player = AudioPlayer();
  static int _requestId = 0;

  static Future<void> startRing() async {
    final requestId = ++_requestId;
    try {
      await _player.stop();
      if (requestId != _requestId) return;
      await _player.setReleaseMode(ReleaseMode.loop);
      if (requestId != _requestId) return;
      await _player.play(AssetSource('audio/${CallScript.ringtoneFile}'));
    } catch (error) {
      debugPrint('Failed to play ringtone: $error');
    }
  }

  static Future<void> stopRing() async {
    ++_requestId;
    try {
      await _player.stop();
    } catch (error) {
      debugPrint('Failed to stop ringtone: $error');
    }
  }

  static Future<void> speak(String fileName) async {
    final requestId = ++_requestId;
    try {
      await _player.stop();
      if (requestId != _requestId) return;
      await _player.setReleaseMode(ReleaseMode.release);
      if (requestId != _requestId) return;
      await _player.play(AssetSource('audio/$fileName'));
    } catch (error) {
      debugPrint('Failed to play voice clip "$fileName": $error');
    }
  }

  static Future<void> stopAll() async {
    ++_requestId;
    try {
      await _player.stop();
    } catch (error) {
      debugPrint('Failed to stop audio: $error');
    }
  }
}
