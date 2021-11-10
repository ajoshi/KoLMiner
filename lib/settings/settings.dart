import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

const String PREF_SETTINGS_PREFIX = "PREF_SETTINGS_";

const String PREF_SETTINGS_FOOD = PREF_SETTINGS_PREFIX + "FOOD";
const String PREF_SETTINGS_BOOZE = PREF_SETTINGS_PREFIX + "BOOZE";
const String PREF_SETTINGS_SKILL = PREF_SETTINGS_PREFIX + "SKILL";
const String PREF_SETTINGS_CHAT1 = PREF_SETTINGS_PREFIX + "CHAT1";
const String PREF_SETTINGS_CHAT2 = PREF_SETTINGS_PREFIX + "CHAT2";
const String PREF_SETTINGS_CHAT3 = PREF_SETTINGS_PREFIX + "CHAT3";
const String PREF_SETTINGS_CHAT4 = PREF_SETTINGS_PREFIX + "CHAT4";

const String PREF_SETTINGS_SUFFIX_VAL = "_VAL";
const String PREF_SETTINGS_SUFFIX_NAME = "_NAME";


void saveNewSettings(Settings? data) async {
  if(data == null) { return; }
  final prefs = await SharedPreferences.getInstance();

  _save(prefs, data.food);
  _save(prefs, data.booze);
  _save(prefs, data.skill);
  _save(prefs, data.chat1);
  _save(prefs, data.chat2);
  _save(prefs, data.chat3);
  _save(prefs, data.chat4);
}

void _save(SharedPreferences prefs, Setting? setting) {
  if(setting != null) {
    prefs.setString(setting.sharedprefKey + PREF_SETTINGS_SUFFIX_VAL, setting.data);
    prefs.setString(setting.sharedprefKey + PREF_SETTINGS_SUFFIX_NAME, setting.name);
  }
}

Future<Settings> getSettings() async {
  final prefs = await SharedPreferences.getInstance();

  var settings = settingsOf();
  _updateSetting(prefs, settings.food);
  _updateSetting(prefs, settings.booze);
  _updateSetting(prefs, settings.skill);
  _updateSetting(prefs, settings.chat1);
  _updateSetting(prefs, settings.chat2);
  _updateSetting(prefs, settings.chat3);
  _updateSetting(prefs, settings.chat4);
  return settings;
}

void _updateSetting(SharedPreferences prefs, Setting? setting) {
  if(setting != null) {
    setting.data = prefs.getString(setting.sharedprefKey + PREF_SETTINGS_SUFFIX_VAL) ?? "";
    setting.name = prefs.getString(setting.sharedprefKey + PREF_SETTINGS_SUFFIX_NAME) ?? "";
  }
}

Settings settingsOf() {
  return Settings(
    Setting("", "", PREF_SETTINGS_FOOD),
      Setting("", "", PREF_SETTINGS_BOOZE),
      Setting("", "", PREF_SETTINGS_SKILL),
      Setting("", "", PREF_SETTINGS_CHAT1),
      Setting("", "", PREF_SETTINGS_CHAT2),
      Setting("", "", PREF_SETTINGS_CHAT3),
      Setting("", "", PREF_SETTINGS_CHAT4),
      );
}

class Setting {
  String data;
  String name;
  final String sharedprefKey;

  @override
  String toString() {
    return "$name: $data";
  }

  Setting(this.name, this.data, this.sharedprefKey);
}

class Settings {
  final Setting? food;
  final Setting? booze;
  final Setting? skill;

  final Setting? chat1;
  final Setting? chat2;
  final Setting? chat3;
  final Setting? chat4;

  Settings(this.food, this.booze, this.skill,this.chat1, this.chat2, this.chat3,this.chat4);

  @override
  String toString() {
    return "$food\n$booze\n$skill\n$chat1\n$chat2\n$chat3\n$chat4";
  }
}
