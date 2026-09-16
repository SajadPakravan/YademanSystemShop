import 'package:shared_preferences/shared_preferences.dart';

class AppCache {
  Future<void> setString(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, value);
  }

  Future<void> setInt(String key, int value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setInt(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setDouble(key, value);
  }

  Future<dynamic>? getString(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }

  Future<int?>? getInt(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getInt(key);
  }

  Future<dynamic>? getBool(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(key);
  }

  Future<double?>? getDouble(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getDouble(key);
  }
  
  Future<Future<bool>> removeKey(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.remove(key);
  }

  Future clearCache() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }
}