import 'package:flutter/material.dart';

import '../data/script.dart';
import '../models/task.dart';
import '../state/app_state.dart';
import '../util/format.dart';
import 'add_task_screen.dart';
import 'incoming_call_screen.dart';
import 'voicemail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('鬼詰めToDo'),
        actions: [_voicemailAction(context)],
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final tasks = appState.tasks;
          return Column(
            children: [
              const _Banner(),
              Expanded(
                child: tasks.isEmpty
                    ? const _Empty()
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: tasks.length,
                        itemBuilder: (_, i) => _TaskTile(task: tasks[i]),
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('タスク追加'),
      ),
    );
  }

  Widget _voicemailAction(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) => Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.voicemail),
            tooltip: '留守電',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VoicemailScreen()),
            ),
          ),
          if (appState.unheardVoicemailCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Color(0xFFE5484D), shape: BoxShape.circle),
                constraints:
                    const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '${appState.unheardVoicemailCount}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final overdue = task.status == TaskStatus.overdue;
    final done = task.status == TaskStatus.done;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color(0xFFE5484D),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => appState.deleteTask(task.id),
      child: ListTile(
        leading: Checkbox(
          value: done,
          onChanged: (_) => appState.toggleDone(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? Colors.white38 : null,
          ),
        ),
        subtitle: Row(
          children: [
            Text(fmtDateTime(task.due)),
            const SizedBox(width: 8),
            _statusChip(overdue, done),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone_in_talk),
          color: overdue ? const Color(0xFFE5484D) : Colors.white38,
          tooltip: '今すぐ着信（デバッグ）',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => IncomingCallScreen(task: task)),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(bool overdue, bool done) {
    late final String text;
    late final Color color;
    if (done) {
      text = '完了';
      color = Colors.white24;
    } else if (overdue) {
      text = fmtRelative(task.due);
      color = const Color(0xFFE5484D);
    } else {
      text = fmtRelative(task.due);
      color = const Color(0xFF4C6EF5);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1F29),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Text(
        '期限を過ぎると${CallScript.callerName}から着信があります。'
        '📞アイコンで今すぐ試せます。',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'タスクがありません。\n右下から追加して、期限を過ぎてみてください。',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white38),
      ),
    );
  }
}
