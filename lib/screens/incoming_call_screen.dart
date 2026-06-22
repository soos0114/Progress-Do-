import 'package:flutter/material.dart';

import '../data/script.dart';
import '../models/task.dart';
import '../services/voice.dart';
import '../state/app_state.dart';

enum _Phase { ringing, talking, closing }

class IncomingCallScreen extends StatefulWidget {
  final Task task;
  const IncomingCallScreen({super.key, required this.task});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final CallCharacter _character;
  _Phase _phase = _Phase.ringing;
  String _closingText = '';

  @override
  void initState() {
    super.initState();
    _character = CallScript.randomCharacter();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    Voice.startRing();
  }

  @override
  void dispose() {
    _pulse.dispose();
    Voice.stopAll();
    super.dispose();
  }

  Future<void> _answer() async {
    setState(() => _phase = _Phase.talking);
    await Voice.stopRing();
    await Voice.speak(_character.answerAudioFile);
  }

  Future<void> _ignore() async {
    await Voice.stopAll();
    await appState.addVoicemail(
      widget.task.id,
      widget.task.title,
      _character.id,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📨 留守電が1件 残りました')),
    );
  }

  void _reply(Reply r) {
    Voice.speak(r.audioFile);
    setState(() {
      _phase = _Phase.closing;
      _closingText = r.closing;
    });
  }

  void _hangUp() {
    Voice.stopAll();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // 着信中は端末の戻るで逃げられない（出る/無視を必ず選ばせる＝ネタ）。
    return PopScope(
      canPop: _phase != _Phase.ringing,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1116),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _caller(),
                const SizedBox(height: 28),
                Expanded(child: _middle()),
                _bottom(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 上部：発信者
  Widget _caller() {
    final label = switch (_phase) {
      _Phase.ringing => '着信中…',
      _Phase.talking => '通話中',
      _Phase.closing => '通話中',
    };
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 14, letterSpacing: 2)),
        const SizedBox(height: 18),
        _avatar(),
        const SizedBox(height: 20),
        Text(_character.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600)),
        if (_character.org.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(_character.org,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ],
    );
  }

  Widget _avatar() {
    return SizedBox(
      width: 160,
      height: 160,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) {
          final ringing = _phase == _Phase.ringing;
          final t = _pulse.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (ringing) ..._waves(t),
              Opacity(
                opacity: _character.id == 'entity'
                    ? 0.4 + ((_pulse.value * 10) % 1) * 0.6
                    : 1,
                child: child,
              ),
            ],
          );
        },
        child: Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: _character.id == 'entity'
                  ? const [Color(0xFF8AFF80), Color(0xFF5B21B6)]
                  : const [Color(0xFF3A4A63), Color(0xFF222B3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            switch (_character.id) {
              'entity' => Icons.blur_circular,
              'mother' => Icons.face_3,
              _ => Icons.support_agent,
            },
            size: 56,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  List<Widget> _waves(double t) {
    // 着信中の波紋（3枚を位相ずらしで）
    return List.generate(3, (i) {
      final p = (t + i / 3) % 1.0;
      return Container(
        width: 108 + p * 80,
        height: 108 + p * 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity((1 - p) * 0.35),
            width: 2,
          ),
        ),
      );
    });
  }

  // 中段：通話のセリフ
  Widget _middle() {
    if (_phase == _Phase.ringing) {
      return Center(
        child: Text(
          '「${widget.task.title}」',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white30, fontSize: 16),
        ),
      );
    }
    final text = _phase == _Phase.talking
        ? _character.answerLine(widget.task.title)
        : _closingText;
    return Center(
      child: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey(text),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 17, height: 1.6),
            ),
          ),
        ),
      ),
    );
  }

  // 下段：操作ボタン（フェーズで切替）
  Widget _bottom() {
    switch (_phase) {
      case _Phase.ringing:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _callButton(
              icon: Icons.call_end,
              color: const Color(0xFFE5484D),
              label: '無視',
              onTap: _ignore,
            ),
            _callButton(
              icon: Icons.call,
              color: const Color(0xFF30A46C),
              label: '出る',
              onTap: _answer,
            ),
          ],
        );
      case _Phase.talking:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in _character.replies) ...[
              _replyButton(r),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            _hangUpBar(),
          ],
        );
      case _Phase.closing:
        return _hangUpBar();
    }
  }

  Widget _hangUpBar() {
    return _callButton(
      icon: Icons.call_end,
      color: const Color(0xFFE5484D),
      label: '終了',
      onTap: _hangUp,
    );
  }

  Widget _replyButton(Reply r) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _reply(r),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(r.label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _callButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
