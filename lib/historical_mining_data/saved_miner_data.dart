import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

const String PREF_AVG_GOLD_COUNT = "avg_gold_count";
const String PREF_AVG_ADVS_SPENT = "avg_advs_spent";
const String PREF_TOTAL_TIME_SPENT = "total_time_spent";

void saveNewMiningData(MiningSessionData data) async {
  aj_print("time per mine = ${data.timeTaken / data.advCount}");

  final prefs = await SharedPreferences.getInstance();
  final oldGold = prefs.getInt(PREF_AVG_GOLD_COUNT) ?? 0;
  final oldAdvs = prefs.getInt(PREF_AVG_ADVS_SPENT) ?? 0;
  final oldTime = prefs.getInt(PREF_TOTAL_TIME_SPENT) ?? 0;

  prefs.setInt(PREF_AVG_GOLD_COUNT, oldGold + data.goldcount);
  prefs.setInt(PREF_AVG_ADVS_SPENT, oldAdvs + data.advCount);
  prefs.setInt(PREF_TOTAL_TIME_SPENT, oldTime + data.timeTaken);
}

/// Wipes all mining data. Be vewy vewy caweful
clearMiningData() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt(PREF_AVG_GOLD_COUNT, 0);
  prefs.setInt(PREF_AVG_ADVS_SPENT, 0);
  prefs.setInt(PREF_TOTAL_TIME_SPENT, 0);
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

  final americanNumberFormatWithDecimals =
      new NumberFormat("#,##0.00", "en_US");
  final americanNumberFormat = new NumberFormat("#,##0", "en_US");

  // gold mined
  final int goldcount;
  // advs taken
  final int advCount;
  // time taken in ms
  final int timeTaken;

  MiningSessionData(this.goldcount, this.advCount, this.timeTaken);

  String toString() {
    return "$goldcount gold in $advCount advs. Took ${_getTimeTakeAsString()}s/Adv. MPA = ${getMpaAsString()}";
  }

  String _getTimeTakeAsString() {
    var time = (timeTaken / advCount) / 1000;
    return "${time.toStringAsFixed(2)}";
  }

  String getAdvCountAsString() {
    if (advCount == 0) {
      return "";
    }
    return americanNumberFormat.format(advCount);
  }

  String getMeatAsString() {
    if (goldcount == 0) {
      return "";
    }
    return americanNumberFormat.format(goldcount * GOLD_AUTOSELL_VALUE);
  }

  /// Calculates the MPA of this session
  String getMpaAsString() {
    if (advCount == 0) {
      return "";
    }
    var value = goldcount * GOLD_AUTOSELL_VALUE / advCount;
    return americanNumberFormatWithDecimals.format(value);
  }
}
