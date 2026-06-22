import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart';
import '../state/app_state.dart';
import '../screens/incoming_call_screen.dart';

/// 期限切れ → 通知 → タップで着信画面、を担当（企画書8章の②方式）。
///
/// ①（アプリ外で勝手にフルスクリーン着信が鳴る）に昇格したくなったら、
/// 下の AndroidNotificationDetails で fullScreenIntent: true にして
/// マニフェストに USE_FULL_SCREEN_INTENT を足す（SETUP.md 参照）。
class Notifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'kizume_call';
  static const String _channelName = '進捗確認の着信';

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    // tz.local は既定でUTCだが、zonedScheduleは「絶対時刻」で発火するため
    // ローカルタイムゾーン名を厳密に設定しなくても、期限の実時刻どおりに鳴る。

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
    );

    // Android 13+ の通知許可をお願いする
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestFullScreenIntentPermission();
    // Android 12+ の正確なアラーム許可（時刻ピッタリで鳴らすため）
    await androidImpl?.requestExactAlarmsPermission();
  }

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: '期限を過ぎたタスクの進捗確認',
    importance: Importance.max,
    priority: Priority.high,
    category: AndroidNotificationCategory.call,
    // ① に昇格するときは true（＋ USE_FULL_SCREEN_INTENT 権限）
    fullScreenIntent: true,
    ongoing: false,
  );

  static Future<void> scheduleForTask(Task task) async {
    final when = tz.TZDateTime.from(task.due, tz.local);
    await _plugin.zonedSchedule(
      task.notificationId,
      '📞 進捗確認担当',
      '「${task.title}」の件で着信があります',
      when,
      const NotificationDetails(android: _androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );
  }

  static Future<void> cancelForTask(Task task) =>
      _plugin.cancel(task.notificationId);

  /// 通知タップ時（フォアグラウンド/復帰）
  static void _onTap(NotificationResponse res) {
    final id = res.payload;
    if (id != null) _routeToCall(id);
  }

  /// 通知から起動された場合（コールドスタート）に main から呼ぶ
  static Future<void> handleLaunch() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      final id = details!.notificationResponse?.payload;
      if (id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _routeToCall(id));
      }
    }
  }

  static void _routeToCall(String taskId) {
    final task = appState.taskById(taskId);
    if (task == null) return;
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => IncomingCallScreen(task: task)),
    );
  }
}
