import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppMark extends StatelessWidget {
  final double size;

  const AppMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.primary.withOpacity(0.16);
    final stroke = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AppMarkPainter(background: bg, stroke: stroke),
      ),
    );
  }
}

class _AppMarkPainter extends CustomPainter {
  final Color background;
  final Color stroke;

  const _AppMarkPainter({
    required this.background,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(size.width * 0.28));

    final backgroundPaint = Paint()..color = background;
    canvas.drawRRect(rrect, backgroundPaint);

    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, size.shortestSide * 0.07)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = stroke;
    canvas.drawRRect(rrect.deflate(size.shortestSide * 0.14), framePaint);

    canvas.save();
    canvas.translate(size.width * 0.52, size.height * 0.5);
    canvas.rotate(-0.1);
    canvas.translate(-size.width * 0.52, -size.height * 0.5);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.6, size.shortestSide * 0.11)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = stroke;

    final stemX = size.width * 0.34;
    final topY = size.height * 0.28;
    final bottomY = size.height * 0.72;
    canvas.drawLine(Offset(stemX, topY), Offset(stemX, bottomY), innerPaint);

    final arcRect = Rect.fromLTWH(
      size.width * 0.34,
      size.height * 0.28,
      size.width * 0.30,
      size.height * 0.44,
    );
    canvas.drawArc(arcRect, -math.pi / 2, math.pi, false, innerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AppMarkPainter oldDelegate) {
    return oldDelegate.background != background || oldDelegate.stroke != stroke;
  }
}
