import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/constants.dart';

class ScoreCircle extends StatelessWidget {
  final int score;
  final double radius;

  const ScoreCircle({
    super.key,
    required this.score,
    this.radius = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on score
    Color progressColor;
    if (score >= 80) {
      progressColor = AppConstants.kSafeColor;
    } else if (score >= 50) {
      progressColor = AppConstants.kWarningColor;
    } else {
      progressColor = AppConstants.kDangerColor;
    }

    // DYNAMIC TEXT COLOR FIX
    // If the theme is light, use black text. If dark, use white.
    final textColor = Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black87;
        
    final subTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.grey[700];

    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Add a subtle background so the circle stands out in both modes
        color: Theme.of(context).cardColor.withOpacity(0.3), 
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: progressColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _ScorePainter(
          score: score,
          color: progressColor,
          backgroundColor: Theme.of(context).dividerColor.withOpacity(0.2), // Dynamic track color
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$score",
              style: TextStyle(
                fontSize: radius * 0.35, // Responsive font size
                fontWeight: FontWeight.bold,
                color: textColor, // <--- FIX APPLIED HERE
              ),
            ),
            Text(
              "Hygiene Score",
              style: TextStyle(
                fontSize: radius * 0.1,
                color: subTextColor, // <--- FIX APPLIED HERE
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScorePainter extends CustomPainter {
  final int score;
  final Color color;
  final Color backgroundColor;

  _ScorePainter({
    required this.score, 
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    
    // Draw Background Circle (The grey track)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Draw Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // -90 degrees (start at top)
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * (score / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}