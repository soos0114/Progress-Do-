import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// 保存層の口。UIはこの口だけを見るので、後でHive等に差し替えても影響が局所。
abstract class Store {
  Future<List<Task>> loadTasks();
  Future<void> saveTasks(List<Task> tasks);
  Future<List<Voicemail>> loadVoicemails();
  Future<void> saveVoicemails(List<Voicemail> vms);
}

/// shared_preferences 実装
class PrefsStore implements Store {
  static const _kTasks = 'tasks';
  static const _kVoicemails = 'voicemails';

  @override
  Future<List<Task>> loadTasks() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kTasks);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _kTasks, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  @override
  Future<List<Voicemail>> loadVoicemails() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kVoicemails);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Voicemail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveVoicemails(List<Voicemail> vms) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _kVoicemails, jsonEncode(vms.map((v) => v.toJson()).toList()));
  }
}
