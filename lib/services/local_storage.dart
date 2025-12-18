import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefsLastScore, score);
  }

  Future<int> getLastScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.prefsLastScore) ?? 0;
  }

  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirst = prefs.getBool(AppConstants.prefsFirstRun) ?? true;
    if (isFirst) {
      await prefs.setBool(AppConstants.prefsFirstRun, false);
    }
    return isFirst;
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}