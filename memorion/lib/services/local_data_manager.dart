import 'package:memorion/const/value_name.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDataManager {
  static late SharedPreferences prefs;

  /// prefs 인스턴스 생성
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    Set<String> nowKeys = prefs.getKeys();
    Set<String> keys = {
      ValueName.userName,
      ValueName.isConnection,
      ValueName.guardianName,
      ValueName.callTime,
      ValueName.callTry,
      ValueName.dark,
      ValueName.language,
      ValueName.languageList,
      ValueName.version
    };

    if (!nowKeys.containsAll(keys)) {
      print("[DEBUG] init all data!!");
      await initData();
    }
  }

  /// 데이터 필드 초기화
  static Future<void> initData() async {
    await prefs.clear();
    await prefs.setString(ValueName.userName, '홍길동'); // 로그인 시 값 갱신(예: gest1234)
    await prefs.setBool(ValueName.isConnection, false);
    await prefs.setBool(ValueName.dark, false);
    await prefs.setString(ValueName.guardianName, '임꺽정');
    await prefs.setString(ValueName.callTime, "09:30");
    await prefs.setInt(ValueName.callTry, 3);
    await prefs.setInt(ValueName.fontSize, 36);
    await prefs.setString(ValueName.language, "false");
    await prefs.setStringList(ValueName.languageList, ["kr", "en"]);
    await prefs.setInt(ValueName.version, 1);
  }  

  Future<bool?> getBoolData(String key) async {
    return prefs.getBool(key);
  }

  Future<int?> getIntData(String key) async {
    return prefs.getInt(key);
  }

  Future<String?> getStringData(String key) async {
    return prefs.getString(key);
  }

  Future<List<String>?> getStrinListgData(String key) async {
    return prefs.getStringList(key);
  }

  void setBoolData(String key, bool value) async {
    prefs.setBool(key, value);
  }

  void setIntData(String key, int value) async {
    prefs.setInt(key, value);
  }

  void setStringData(String key, String value) async {
    prefs.setString(key, value);
  }

}
