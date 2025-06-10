import 'dart:math';

import 'package:flutter/material.dart';

class RatingGauge extends StatelessWidget {
  final double rating; // 0 to 10
  final int totalVotes;

  const RatingGauge({
    super.key,
    required this.rating,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 100),
      painter: _GaugePainter(rating / 10),
      child: SizedBox(
        width: 200,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple)),
                Text(' |  10', style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Average User Rating', style: TextStyle(color: Colors.black)),
            const SizedBox(height: 2),
            Text('${_formatVotes(totalVotes)} Rated',
                style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  String _formatVotes(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toString();
  }
}

class _GaugePainter extends CustomPainter {
  final double progress; // from 0.0 to 1.0

  _GaugePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height);

    final startAngle = pi;
    final sweepAngle = pi;

    final backgroundPaint = Paint()
      ..color = Colors.deepPurple.shade100
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gradient = SweepGradient(
      startAngle: pi,
      endAngle: pi * (1 + progress),
      colors: [Colors.deepPurple.shade200, Colors.deepPurple],
    );

    final progressPaint = Paint()
      ..shader =
          gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle, false, backgroundPaint);

    // Draw progress arc
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle * progress, false, progressPaint);

    // Thumb
    final thumbAngle = startAngle + sweepAngle * progress;
    final thumbOffset = Offset(center.dx + radius * cos(thumbAngle),
        center.dy + radius * sin(thumbAngle));
    canvas.drawCircle(thumbOffset, 12, Paint()..color = Colors.deepPurple);
    canvas.drawCircle(thumbOffset, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
