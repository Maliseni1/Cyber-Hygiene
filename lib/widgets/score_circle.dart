import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ScoreCircle extends StatelessWidget {
  final int score;
  final double radius;
  final double lineWidth;
  final bool animate;

  const ScoreCircle({
    super.key,
    required this.score,
    this.radius = 120.0,
    this.lineWidth = 15.0,
    this.animate = true,
  });

  Color _getColorForScore(int score) {
    if (score >= 80) return AppConstants.kSafeColor;
    if (score >= 50) return AppConstants.kWarningColor;
    return AppConstants.kDangerColor;
  }

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      percent: score / 100,
      animation: animate,
      animationDuration: 1500,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$score",
            style: GoogleFonts.robotoMono(
              fontSize: radius * 0.4, 
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "SCORE",
            style: GoogleFonts.roboto(
              fontSize: radius * 0.12,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      progressColor: _getColorForScore(score),
      backgroundColor: Colors.grey[800]!,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}