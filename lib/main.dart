import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'utils/theme_manager.dart'; // Import the manager we just made

void main() {
  runApp(const CyberHygieneApp());
}

class CyberHygieneApp extends StatefulWidget {
  const CyberHygieneApp({super.key});

  @override
  State<CyberHygieneApp> createState() => _CyberHygieneAppState();
}

class _CyberHygieneAppState extends State<CyberHygieneApp> {
  @override
  void initState() {
    super.initState();
    // Listen to theme changes
    themeManager.addListener(themeListener);
  }

  @override
  void dispose() {
    themeManager.removeListener(themeListener);
    super.dispose();
  }

  void themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Hygiene',
      debugShowCheckedModeBanner: false,
      
      // 1. Tell the app which mode to use
      themeMode: themeManager.themeMode,

      // 2. Define the DARK Theme (Your original look)
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E2C), // Your AppConstants.kBackgroundColor
        cardColor: const Color(0xFF2D2D44),
        primaryColor: const Color(0xFF6C63FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF6C63FF),
          surface: Color(0xFF2D2D44),
        ),
      ),

      // 3. Define the LIGHT Theme (New clean look)
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardColor: Colors.white,
        primaryColor: const Color(0xFF6C63FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6C63FF), // Purple header in light mode
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF6C63FF),
          surface: Colors.white,
        ),
      ),

      home: const DashboardScreen(),
    );
  }
}