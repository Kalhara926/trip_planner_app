// lib/services/preferences_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Setting එකක් save කිරීම
  Future<void> saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Save කරපු setting එකක් නැවත ලබා ගැනීම
  // අගයක් save කරලා නැත්නම්, default අගය 'true' ලෙස දීම
  Future<bool> getBoolSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true;
  }
}
