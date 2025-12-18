import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  // -- Branding --
  static const String appName = "Cyber Hygiene";
  static const String companyName = "Chiza Labs";
  static const String copyright = "© 2025 Chiza Labs";

  // -- Colors --
  static const Color kPrimaryColor = Color(0xFF2979FF); // Blue Accent
  static const Color kBackgroundColor = Color(0xFF121212); // Deep Dark
  static const Color kCardColor = Color(0xFF1E1E1E); // Slightly lighter for cards
  
  // Status Colors
  static const Color kSafeColor = Color(0xFF00E676); // Bright Green
  static const Color kWarningColor = Color(0xFFFFAB00); // Amber
  static const Color kDangerColor = Color(0xFFFF1744); // Red

  // -- Text Styles --
  static TextStyle get headerStyle => GoogleFonts.robotoMono(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get subHeaderStyle => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.grey[400],
  );

  static TextStyle get bodyStyle => GoogleFonts.roboto(
    fontSize: 14,
    color: Colors.grey[300],
  );

  static TextStyle get brandingStyle => GoogleFonts.robotoMono(
    fontSize: 12,
    color: Colors.grey[600],
    letterSpacing: 1.2,
  );

  // -- Storage Keys --
  static const String prefsLastScore = 'last_hygiene_score';
  static const String prefsScanHistory = 'scan_history';
  static const String prefsFirstRun = 'is_first_run';
}