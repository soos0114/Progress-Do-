import 'dart:math';

/// タスクの状態
enum TaskStatus { pending, overdue, done }

/// ToDo 1件。鬼詰めToDoでは「期限切れ後」が本編なので、
/// 持つ情報は名前・期限・完了フラグだけに絞っている。
class Task {
  final String id;
  String title;
  DateTime due;
  bool done;

  Task({
    required this.id,
    required this.title,
    required this.due,
    this.done = false,
  });

  factory Task.create(String title, DateTime due) =>
      Task(id: _genId(), title: title, due: due);

  TaskStatus get status {
    if (done) return TaskStatus.done;
    if (DateTime.now().isAfter(due)) return TaskStatus.overdue;
    return TaskStatus.pending;
  }

  bool get isOverdue => status == TaskStatus.overdue;

  /// 通知ID（32bit int に収める）。idから決定的に作る。
  int get notificationId => id.hashCode & 0x7fffffff;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'due': due.toIso8601String(),
        'done': done,
      };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as String,
        title: j['title'] as String,
        due: DateTime.parse(j['due'] as String),
        done: (j['done'] as bool?) ?? false,
      );
}

/// 留守電1件（無視したときに残る）
class Voicemail {
  final String id;
  final String taskTitle;
  final DateTime receivedAt;
  bool heard;

  Voicemail({
    required this.id,
    required this.taskTitle,
    required this.receivedAt,
    this.heard = false,
  });

  factory Voicemail.create(String taskTitle) => Voicemail(
        id: _genId(),
        taskTitle: taskTitle,
        receivedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskTitle': taskTitle,
        'receivedAt': receivedAt.toIso8601String(),
        'heard': heard,
      };

  factory Voicemail.fromJson(Map<String, dynamic> j) => Voicemail(
        id: j['id'] as String,
        taskTitle: j['taskTitle'] as String,
        receivedAt: DateTime.parse(j['receivedAt'] as String),
        heard: (j['heard'] as bool?) ?? false,
      );
}

String _genId() {
  final r = Random();
  return '${DateTime.now().microsecondsSinceEpoch}_${r.nextInt(1 << 32)}';
}
