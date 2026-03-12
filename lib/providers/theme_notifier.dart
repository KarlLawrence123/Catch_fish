import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // This is the method your dashboard_screen.dart is looking for
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners(); // This tells the app to refresh the colors
  }

  // Keep this as well in case you want to set it specifically
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}