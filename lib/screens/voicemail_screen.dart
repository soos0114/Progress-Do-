import 'package:flutter/material.dart';

import '../data/script.dart';
import '../models/task.dart';
import '../services/voice.dart';
import '../state/app_state.dart';
import '../util/format.dart';

class VoicemailScreen extends StatelessWidget {
  const VoicemailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('留守電')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final vms = appState.voicemails;
          if (vms.isEmpty) {
            return const Center(
              child:
                  Text('留守電はありません。', style: TextStyle(color: Colors.white38)),
            );
          }
          return ListView.separated(
            itemCount: vms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _VoicemailTile(vm: vms[i]),
          );
        },
      ),
    );
  }
}

class _VoicemailTile extends StatefulWidget {
  final Voicemail vm;
  const _VoicemailTile({required this.vm});

  @override
  State<_VoicemailTile> createState() => _VoicemailTileState();
}

class _VoicemailTileState extends State<_VoicemailTile> {
  bool _open = false;

  void _toggle() {
    final character = CallScript.characterById(widget.vm.characterId);
    setState(() => _open = !_open);
    if (_open) {
      appState.markVoicemailHeard(widget.vm.id);
      Voice.speak(character.voicemailAudioFile);
    } else {
      Voice.stopAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final character = CallScript.characterById(vm.characterId);
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: vm.heard
                ? Colors.white12
                : const Color(0xFFE5484D).withOpacity(0.25),
            child: Icon(
              character.id == 'entity'
                  ? Icons.blur_circular
                  : character.id == 'mother'
                      ? Icons.face_3
                      : Icons.support_agent,
              color: Colors.white70,
            ),
          ),
          title: Text(character.name,
              style: TextStyle(
                  fontWeight: vm.heard ? FontWeight.normal : FontWeight.bold)),
          subtitle: Text('「${vm.taskTitle}」  ・  ${fmtDateTime(vm.receivedAt)}'),
          trailing: Icon(_open ? Icons.stop_circle : Icons.play_circle_fill,
              color: Colors.white70),
          onTap: _toggle,
        ),
        if (_open)
          Container(
            width: double.infinity,
            color: Colors.white.withOpacity(0.04),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: Text(
              character.voicemailLine(vm.taskTitle),
              style: const TextStyle(height: 1.6, color: Colors.white70),
            ),
          ),
      ],
    );
  }
}
