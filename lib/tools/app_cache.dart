import 'package:shared_preferences/shared_preferences.dart';

class AppCache {
  static Future<bool> setString(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setInt(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setBool(key, value);
  }

  static Future<bool> setDouble(String key, double value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setDouble(key, value);
  }

  static Future<String> getString(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(key) ?? '';
  }

  static Future<int> getInt(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getInt(key) ?? 0;
  }

  static Future<bool> getBool(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(key) ?? false;
  }

  static Future<double> getDouble(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getDouble(key) ?? 0;
  }

  static Future<bool> remove(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.remove(key);
  }

  static Future<bool> clear() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.clear();
  }
}
