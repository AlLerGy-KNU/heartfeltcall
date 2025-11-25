import 'package:shared_preferences/shared_preferences.dart';

class LocalDataManager {
  static late SharedPreferences prefs;

  /// Initialize SharedPreferences and default values.
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    // final nowKeys = prefs.getKeys();
    // final keys = <String>{
    //   ValueName.userName,
    //   ValueName.isConnection,
    //   ValueName.guardianName,
    //   ValueName.callTime,
    //   ValueName.callTry,
    //   ValueName.dark,
    //   ValueName.language,
    //   ValueName.languageList,
    //   ValueName.version,
    //   ValueName.fontSize,
    // };

    // Initialize only when keys are missing
    // if (!nowKeys.containsAll(keys)) {      
    //   await _initDefaultsV1();
    //   print("[DEBUG] init all data!!");
    // }
  }


  /// Initialize all stored fields with default values.
  // static Future<void> _initDefaultsV1() async {
  //   final defaults = AppSettings.settingv1;

  //   for (final entry in defaults.entries) {
  //     final key = entry.key;
  //     final value = entry.value;

  //     if (!prefs.containsKey(key)) {
  //       if (value is String) {
  //         await prefs.setString(key, value);
  //       } else if (value is bool) {
  //         await prefs.setBool(key, value);
  //       } else if (value is int) {
  //         await prefs.setInt(key, value);
  //       } else if (value is List<String>) {
  //         await prefs.setStringList(key, value);
  //       }
  //     }
  //   }
  // }


  // --------- Getters ---------

  static bool? getBoolData(String key) {
    return prefs.getBool(key);
  }

  static int? getIntData(String key) {
    return prefs.getInt(key);
  }

  static String? getStringData(String key) {
    return prefs.getString(key);
  }

  static List<String>? getStringListData(String key) {
    return prefs.getStringList(key);
  }

  // --------- Setters ---------

  static Future<void> setBoolData(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  static Future<void> setIntData(String key, int value) async {
    await prefs.setInt(key, value);
  }

  static Future<void> setStringData(String key, String value) async {
    await prefs.setString(key, value);
  }

  static Future<void> setStringListData(String key, List<String> value) async {
    await prefs.setStringList(key, value);
  }

  // --------- Token Handling ---------

  static String? getAccessToken() {
    return prefs.getString('access_token');
  }

  static Future<void> setAccessToken(String accessToken) async {
    await prefs.setString('access_token', accessToken);
  }

  static Future<void> clearAccessToken() async {
    await prefs.remove('access_token');
  }
}
