import 'package:audioplayers/audioplayers.dart';

import '../data/script.dart';

/// ElevenLabs等で生成した音声を鳴らす。
/// assets/audio/ にファイルが無い場合は例外を握りつぶし、無音で進行する
/// （＝テキスト字幕だけで体験が成立する設計）。
class Voice {
  static final AudioPlayer _ring = AudioPlayer();
  static final AudioPlayer _speech = AudioPlayer();

  static Future<void> startRing() async {
    try {
      await _ring.setReleaseMode(ReleaseMode.loop);
      await _ring.play(AssetSource('audio/${CallScript.ringtoneFile}'));
    } catch (_) {/* 着信音ファイル未配置：無音で着信 */}
  }

  static Future<void> stopRing() async {
    try {
      await _ring.stop();
    } catch (_) {}
  }

  static Future<void> speak(String fileName) async {
    try {
      await _speech.stop();
      await _speech.play(AssetSource('audio/$fileName'));
    } catch (_) {/* セリフ音声未配置：字幕のみ */}
  }

  static Future<void> stopAll() async {
    await stopRing();
    try {
      await _speech.stop();
    } catch (_) {}
  }
}
