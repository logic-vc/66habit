import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  CircularGaugePainter({
    required this.progress,
    this.backgroundColor = AppColors.gaugeEmpty,
    this.progressColor = AppColors.gaugeFilling,
    this.strokeWidth = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progress >= 1.0 ? AppColors.gaugeFilled : progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // Draw inner circle when complete
    if (progress >= 1.0) {
      final fillPaint = Paint()
        ..color = AppColors.gaugeFilled.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius - strokeWidth, fillPaint);
    }
  }

  @override
  bool shouldRepaint(CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
