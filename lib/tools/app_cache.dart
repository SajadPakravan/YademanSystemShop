import 'package:shared_preferences/shared_preferences.dart';

class AppCache {
  setString(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, value);
  }

  setInt(String key, int value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setInt(key, value);
  }

  setBool(String key, bool value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool(key, value);
  }

  setDouble(String key, double value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setDouble(key, value);
  }

  getString(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }

  getInt(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getInt(key);
  }

  getBool(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(key);
  }

  getDouble(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getDouble(key);
  }
  
  removeKey(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.remove(key);
  }

  Future clearCache() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }
}