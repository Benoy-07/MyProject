import 'package:shared_preferences/shared_preferences.dart';

/// Small wrapper around SharedPreferences that catches platform plugin errors
/// so the app doesn't crash during hot-reload or when plugin isn't registered.
class PrefsService {
  static Future<void> setBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      // ignore plugin errors at runtime (MissingPluginException)
    }
  }

  static Future<bool> getBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      // ignore
    }
  }
}
