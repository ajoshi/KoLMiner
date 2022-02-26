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
const String PREF_SETTINGS_CHAT5 = PREF_SETTINGS_PREFIX + "CHAT5";
const String PREF_SETTINGS_CHAT6 = PREF_SETTINGS_PREFIX + "CHAT6";

const String PREF_SETTINGS_VOLC_OUTFIT_NAME =
    PREF_SETTINGS_PREFIX + "VOLC_OUTFIT";
const String PREF_SETTINGS_RO_OUTFIT_NAME = PREF_SETTINGS_PREFIX + "RO_OUTFIT";
const String PREF_SETTINGS_AUTOHEAL_MIN_HP =
    PREF_SETTINGS_PREFIX + "AUTOHEAL_MIN_HP";
const String PREF_SETTINGS_AUTOCAST_MAX_MP =
    PREF_SETTINGS_PREFIX + "AUTOCAST_MAX_MP";

const String PREF_SETTINGS_SUFFIX_VAL = "_VAL";
const String PREF_SETTINGS_SUFFIX_NAME = "_NAME";

void saveNewSettings(Settings? data) async {
  if (data == null) {
    return;
  }
  final prefs = await SharedPreferences.getInstance();

  _save(prefs, data.food);
  _save(prefs, data.booze);
  _save(prefs, data.skill);
  _save(prefs, data.volcOutfitName);
  _save(prefs, data.roOutfitName);
  _save(prefs, data.autohealMinHp);
  _save(prefs, data.autocastMaxMp);
  data.chatCommands?.forEach((cmd) => _save(prefs, cmd));
}

void _save(SharedPreferences prefs, Setting? setting) {
  if (setting != null) {
    prefs.setString(
        setting.sharedprefKey + PREF_SETTINGS_SUFFIX_VAL, setting.data);
    prefs.setString(
        setting.sharedprefKey + PREF_SETTINGS_SUFFIX_NAME, setting.name);
  }
}

Future<Settings> getSettings() async {
  final prefs = await SharedPreferences.getInstance();

  var settings = settingsOf();
  _updateSetting(prefs, settings.food);
  _updateSetting(prefs, settings.booze);
  _updateSetting(prefs, settings.skill);
  _updateSetting(prefs, settings.volcOutfitName);
  _updateSetting(prefs, settings.roOutfitName);
  _updateSetting(prefs, settings.autocastMaxMp);
  _updateSetting(prefs, settings.autohealMinHp);
  settings.chatCommands?.forEach((cmd) => _updateSetting(prefs, cmd));
  return settings;
}

void _updateSetting(SharedPreferences prefs, Setting? setting) {
  if (setting != null) {
    setting.data =
        prefs.getString(setting.sharedprefKey + PREF_SETTINGS_SUFFIX_VAL) ?? "";
    setting.name =
        prefs.getString(setting.sharedprefKey + PREF_SETTINGS_SUFFIX_NAME) ??
            "";
  }
}

Settings settingsOf() {
  return Settings(
      Setting("", "", PREF_SETTINGS_FOOD),
      Setting("", "", PREF_SETTINGS_BOOZE),
      Setting("", "", PREF_SETTINGS_SKILL),
      [
        Setting("", "", PREF_SETTINGS_CHAT1),
        Setting("", "", PREF_SETTINGS_CHAT2),
        Setting("", "", PREF_SETTINGS_CHAT3),
        Setting("", "", PREF_SETTINGS_CHAT4),
        Setting("", "", PREF_SETTINGS_CHAT5),
        Setting("", "", PREF_SETTINGS_CHAT6),
      ],
      // the following settings don't actually have a value- just a name
      Setting("", "", PREF_SETTINGS_VOLC_OUTFIT_NAME),
      Setting("", "", PREF_SETTINGS_RO_OUTFIT_NAME),
      Setting("", "", PREF_SETTINGS_AUTOHEAL_MIN_HP),
      Setting("", "", PREF_SETTINGS_AUTOCAST_MAX_MP),
      false);
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

  final List<Setting>? chatCommands;

  final bool shouldAutoEquip;
  final Setting? volcOutfitName;
  final Setting? roOutfitName;
  final Setting? autohealMinHp;
  final Setting? autocastMaxMp;

  Settings(
      this.food,
      this.booze,
      this.skill,
      this.chatCommands,
      this.volcOutfitName,
      this.roOutfitName,
      this.autohealMinHp,
      this.autocastMaxMp,
      this.shouldAutoEquip);

  @override
  String toString() {
    return "$food\n$booze\n$skill\n$volcOutfitName\n$roOutfitName\n$shouldAutoEquip\n$autohealMinHp\n$autocastMaxMp\n$chatCommands";
  }
}
