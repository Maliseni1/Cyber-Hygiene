import 'package:flutter/material.dart';

// A global notifier so we can access it from anywhere
final themeManager = ThemeManager();

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  get themeMode => _themeMode;

  void toggleTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // Tells the app to rebuild with the new mode
  }
}