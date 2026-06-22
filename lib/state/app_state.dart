import 'package:flutter/widgets.dart';

import '../models/task.dart';
import '../services/storage.dart';
import '../services/notifications.dart';

/// 通知タップ → 画面遷移に使う共有の navigator key
final navigatorKey = GlobalKey<NavigatorState>();

/// 外部状態管理ライブラリは使わない方針。
/// ChangeNotifier の単一グローバルインスタンスを各画面が ListenableBuilder で購読する。
final appState = AppState();

class AppState extends ChangeNotifier {
  AppState({Store? store}) : _store = store ?? PrefsStore();

  final Store _store;

  List<Task> tasks = [];
  List<Voicemail> voicemails = [];

  Future<void> load() async {
    final savedTasks = await _store.loadTasks();
    tasks = savedTasks.where((task) => !task.done).toList();
    if (tasks.length != savedTasks.length) {
      await _store.saveTasks(tasks);
    }
    voicemails = await _store.loadVoicemails();
    notifyListeners();
  }

  Task? taskById(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  int get unheardVoicemailCount => voicemails.where((v) => !v.heard).length;

  Future<void> addTask(String title, DateTime due) async {
    final t = Task.create(title.trim(), due);
    tasks.add(t);
    _sortTasks();
    await _store.saveTasks(tasks);
    // 未来の期限なら通知を予約（②方式：期限切れで通知 → タップで着信）
    if (due.isAfter(DateTime.now())) {
      await Notifications.scheduleForTask(t);
    }
    notifyListeners();
  }

  Future<void> toggleDone(String id) async {
    final t = taskById(id);
    if (t == null) return;
    tasks.remove(t);
    notifyListeners();
    await Notifications.cancelForTask(t);
    await _store.saveTasks(tasks);
  }

  /// 通知とアプリ内タイマーが同時に発火しても、着信は片方だけにする。
  Future<bool> claimCall(String id) async {
    final t = taskById(id);
    if (t == null || t.done || t.hasCalled) return false;

    // 保存完了を待たずに立てて、同一プロセス内の二重着信を防ぐ。
    t.hasCalled = true;
    notifyListeners();
    await Notifications.cancelForTask(t);
    await _store.saveTasks(tasks);
    return true;
  }

  Future<void> deleteTask(String id) async {
    final t = taskById(id);
    if (t != null) await Notifications.cancelForTask(t);
    tasks.removeWhere((t) => t.id == id);
    await _store.saveTasks(tasks);
    notifyListeners();
  }

  Future<void> addVoicemail(String taskTitle, String characterId) async {
    voicemails.insert(0, Voicemail.create(taskTitle, characterId));
    await _store.saveVoicemails(voicemails);
    notifyListeners();
  }

  Future<void> markVoicemailHeard(String id) async {
    for (final v in voicemails) {
      if (v.id == id) v.heard = true;
    }
    await _store.saveVoicemails(voicemails);
    notifyListeners();
  }

  Future<void> deleteVoicemail(String id) async {
    voicemails.removeWhere((v) => v.id == id);
    await _store.saveVoicemails(voicemails);
    notifyListeners();
  }

  void _sortTasks() {
    tasks.sort((a, b) => a.due.compareTo(b.due));
  }
}
