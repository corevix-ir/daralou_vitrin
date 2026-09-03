import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for light/dark mode, read synchronously by
/// [AppColors] on every build and toggled from the floating assistive
/// ball's menu. Persisted so a kiosk reboot wakes up in whichever theme
/// the operator last picked instead of always resetting to the default.
class ThemeController extends ChangeNotifier {
  ThemeController._internal();
  static final ThemeController instance = ThemeController._internal();

  static const _prefsKey = 'kiosk_theme_is_dark';

  bool isDark = true;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool(_prefsKey) ?? true;
    notifyListeners();
  }

  Future<void> toggle() async {
    isDark = !isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, isDark);
  }
}
