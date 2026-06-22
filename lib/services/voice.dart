import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../data/script.dart';

/// Handles the looping ringtone and scripted voice clips.
class Voice {
  // Ringtone and speech never need to overlap. Keeping them on one native
  // player avoids audio-focus contention while answering a call.
  static final AudioPlayer _player = AudioPlayer();
  static int _requestId = 0;
  static bool _preloaded = false;

  /// 着信音を起動時にキャッシュへ展開しておく。
  /// 初回再生時のディスク読み込み遅延（＝鳴り出しの取りこぼし）を抑える。
  /// 失敗してもオンデマンド読み込みにフォールバックするため致命的ではない。
  static Future<void> preload() async {
    if (_preloaded) return;
    _preloaded = true;
    try {
      await AudioCache.instance.loadAll(['audio/${CallScript.ringtoneFile}']);
    } catch (error) {
      _preloaded = false;
      debugPrint('Failed to preload audio: $error');
    }
  }

  static Future<void> startRing() async {
    final requestId = ++_requestId;
    // ループ再生は「実際に鳴り始めたか」を確認してリトライする。
    // 通知音とのフォーカス争奪で無音のまま start することがあるため。
    await _playWithRetry(
      requestId,
      AssetSource('audio/${CallScript.ringtoneFile}'),
      ReleaseMode.loop,
      label: 'ringtone',
      verify: true,
    );
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
    // 一回再生は二重再生を避けたいので、例外時のみ再試行（鳴り確認はしない）。
    await _playWithRetry(
      requestId,
      AssetSource('audio/$fileName'),
      ReleaseMode.release,
      label: fileName,
      verify: false,
    );
  }

  static Future<void> stopAll() async {
    ++_requestId;
    try {
      await _player.stop();
    } catch (error) {
      debugPrint('Failed to stop audio: $error');
    }
  }

  /// 再生開始を最大3回試みる。新しい要求が来たら（_requestId が変われば）即中断。
  /// [verify] が true のときは再生状態を確認し、鳴っていなければ再試行する。
  static Future<void> _playWithRetry(
    int requestId,
    Source source,
    ReleaseMode mode, {
    required String label,
    required bool verify,
  }) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      if (requestId != _requestId) return;
      try {
        await _player.stop();
        if (requestId != _requestId) return;
        await _player.setReleaseMode(mode);
        if (requestId != _requestId) return;
        await _player.play(source);

        if (!verify) return;
        // フォーカス争奪・背景再生ミュート等で無音のまま start することがあるので、
        // 少し待って本当に再生中か確認する（着信音のみ）。
        await Future<void>.delayed(const Duration(milliseconds: 150));
        if (requestId != _requestId) return;
        if (_player.state == PlayerState.playing) return;
        debugPrint('Ringtone did not start (state=${_player.state}); retrying');
      } catch (error) {
        debugPrint('Failed to play "$label" (attempt ${attempt + 1}): $error');
      }
      // 取りこぼしに備えて少し待ってから再試行。
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
  }
}
