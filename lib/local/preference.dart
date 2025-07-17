// ignore_for_file: constant_identifier_names

import 'package:aiims_heartcare/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  // Constants

  static const USERNAME = "USERNAME";
  static const FIREBASE_TOKEN = "FIREBASE_TOKEN";
  static const USER_TOKEN = "USER_TOKEN";
  static const USER_EMAIL = "USER_EMAIL";
  static const PHONE = "phonenumber";
  static const USER_ID = "USER_ID";
  static const FIRST_NAME = "FIRST_NAME";
  static const LAST_NAME = "LAST_NAME";
  static const LANGUAGE = "LANGUAGE";
  static const PASSWORD = "PASSWORD";
  static const REMEMBER_ME = "REMEMBER_ME";
  static const isLoggedIn = 'isLoggedIn';
  static const USER_PROFILE = "USER_PROFILE";
  static const INTAKE_LIMIT = "daily_liquid_intake_limit";
  static const INTAKE_LIMIT_MEASUREMENT = "liquid_intake_limit_measurement";
  static const USER_PROFILE_IMAGE = "USER_PROFILE_IMAGE"; 


  // Singleton instance
  static final Preference _instance = Preference._internal();
  factory Preference() => _instance;
  Preference._internal();

  static SharedPreferences? _prefs;
  static final Map<String, dynamic> _memoryPrefs = {};

  // Initialize the preferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Helper method to log calls
  static void _logCall(String key, dynamic value) {
    final stackTrace = StackTrace.current;
    final callerInfo = _getCallerInfo(stackTrace);
    Log.v('Preference set - key: $key, value: $value, caller: $callerInfo');
  }

  static String _getCallerInfo(StackTrace stackTrace) {
    final traceString = stackTrace.toString().split('\n');
    if (traceString.length > 1) {
      final callerLine = traceString[1];
      final regex = RegExp(r'#\d+\s+(.+):(\d+):\d+');
      final match = regex.firstMatch(callerLine);
      if (match != null) {
        return '${match.group(1)}:${match.group(2)}';
      }
    }
    return 'Unknown';
  }

  // Set methods
  static Future<void> setString(String key, String value) async {
    _logCall(key, value);
    await _prefs?.setString(key, value);
    _memoryPrefs[key] = value;
  }

  static Future<void> setListString(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
    _memoryPrefs[key] = value;
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
    _memoryPrefs[key] = value;
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
    _memoryPrefs[key] = value;
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
    _memoryPrefs[key] = value;
  }

  // Get methods
  static String? getString(String key, {String? defaultValue}) {
    if (_memoryPrefs.containsKey(key)) {
      return _memoryPrefs[key] as String?;
    }
    return _prefs?.getString(key) ?? defaultValue;
  }

  static List<String>? getListString(String key, {List<String>? defaultValue}) {
    if (_memoryPrefs.containsKey(key)) {
      return _memoryPrefs[key] as List<String>?;
    }
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  static int? getInt(String key, {int? defaultValue}) {
    if (_memoryPrefs.containsKey(key)) {
      return _memoryPrefs[key] as int?;
    }
    return _prefs?.getInt(key) ?? defaultValue;
  }

  static double? getDouble(String key, {double? defaultValue}) {
    if (_memoryPrefs.containsKey(key)) {
      return _memoryPrefs[key] as double?;
    }
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    if (_memoryPrefs.containsKey(key)) {
      return _memoryPrefs[key] as bool? ?? defaultValue;
    }
    return _prefs?.getBool(key) ?? defaultValue;
  }

  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
    _memoryPrefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
    _memoryPrefs.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userToken');
    await prefs.remove('email');
    await prefs.remove('userName');
 
  }
}
