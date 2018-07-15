import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const String PREF_AVG_GOLD_COUNT = "avg_gold_count";
const String PREF_AVG_ADVS_SPENT = "avg_advs_spent";
const String PREF_TOTAL_TIME_SPENT = "total_time_spent";

void saveNewMiningData(MiningSessionData data) async {
  final prefs = await SharedPreferences.getInstance();
  final oldGold = prefs.getInt(PREF_AVG_GOLD_COUNT) ?? 0;
  final oldAdvs = prefs.getInt(PREF_AVG_ADVS_SPENT) ?? 0;
  final oldTime = prefs.getInt(PREF_TOTAL_TIME_SPENT) ?? 0;

  prefs.setInt(PREF_AVG_GOLD_COUNT, oldGold + data.goldcount);
  prefs.setInt(PREF_AVG_ADVS_SPENT, oldAdvs + data.advCount);
  prefs.setInt(PREF_TOTAL_TIME_SPENT, oldTime + data.timeTaken);
}

Future<MiningSessionData> getMiningData() async {
  final prefs = await SharedPreferences.getInstance();
  final oldGold = prefs.getInt(PREF_AVG_GOLD_COUNT) ?? 0;
  final oldAdvs = prefs.getInt(PREF_AVG_ADVS_SPENT) ?? 0;
  final oldTime = prefs.getInt(PREF_TOTAL_TIME_SPENT) ?? 0;
  return new MiningSessionData(oldGold, oldAdvs, oldTime);
}

class MiningSessionData {
  static const int GOLD_AUTOSELL_VALUE = 19700;

  // gold mined
  final int goldcount;
  // advs taken
  final int advCount;
  // time taken in ms
  final int timeTaken;

  MiningSessionData(this.goldcount, this.advCount, this.timeTaken);

  String toString() {
    return "$goldcount gold in $advCount advs. Took ${timeTaken~/1000} secs. MPA = ${getMpaAsString()}";
  }

  /// Calculates the MPA of this session
  String getMpaAsString() {
    if (advCount == 0) {
      return "";
    }
    var value = goldcount * GOLD_AUTOSELL_VALUE / advCount;
    return value.toStringAsFixed(2);
  }
}
