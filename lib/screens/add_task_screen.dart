import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../util/format.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _controller = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(minutes: 1));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setIn(Duration d) =>
      setState(() => _due = DateTime.now().add(d));

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null) return;
    setState(() => _due =
        DateTime(d.year, d.month, d.day, _due.hour, _due.minute));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_due),
    );
    if (t == null) return;
    setState(() => _due =
        DateTime(_due.year, _due.month, _due.day, t.hour, t.minute));
  }

  Future<void> _save() async {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タスク名を入れてください')),
      );
      return;
    }
    await appState.addTask(title, _due);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タスク追加')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'タスク名',
              hintText: '例：請求書を送る',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 28),
          const Text('期限', style: TextStyle(fontSize: 13, color: Colors.white54)),
          const SizedBox(height: 8),
          Text(fmtDateTime(_due),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(fmtRelative(_due),
              style: const TextStyle(color: Colors.white38)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _quick('1分後', const Duration(minutes: 1)),
              _quick('5分後', const Duration(minutes: 5)),
              _quick('10分後', const Duration(minutes: 10)),
              _quick('1時間後', const Duration(hours: 1)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('日付'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time, size: 18),
                  label: const Text('時刻'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('登録する'),
          ),
        ],
      ),
    );
  }

  Widget _quick(String label, Duration d) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _setIn(d),
    );
  }
}
