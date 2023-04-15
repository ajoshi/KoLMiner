import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

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

const String PREF_AUTOSELL_GOLD = PREF_SETTINGS_PREFIX + "AUTOSELL_GOLD";
const String PREF_USE_NEUMORPHISM = PREF_SETTINGS_PREFIX + "USE_NEUMORPHISM";
const String PREF_AUTOCONSUME_LIST = PREF_SETTINGS_PREFIX + "AUTOCONSUME";

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
  data.food?.save(prefs);
  data.booze?.save(prefs);
  data.skill?.save(prefs);
  data.volcOutfitName?.save(prefs);
  data.roOutfitName?.save(prefs);
  data.autohealMinHp?.save(prefs);
  data.autocastMaxMp?.save(prefs);

  data.chatCommands?.forEach((cmd) => cmd.save(prefs));

  data.shouldAutosellGold.save(prefs);
  data.shouldUseNeumorphism.save(prefs);
  data.autoconsumeList.save(prefs);
}

Future<Settings> getSettings() async {
  final prefs = await SharedPreferences.getInstance();
  var settings = settingsOf();
  settings.food?.update(prefs);
  settings.booze?.update(prefs);
  settings.skill?.update(prefs);
  settings.volcOutfitName?.update(prefs);
  settings.roOutfitName?.update(prefs);
  settings.autocastMaxMp?.update(prefs);
  settings.autohealMinHp?.update(prefs);
  settings.chatCommands?.forEach((cmd) => cmd.update(prefs));

  settings.shouldAutosellGold.update(prefs);
  settings.shouldUseNeumorphism.update(prefs);

  settings.autoconsumeList.update(prefs);
  return settings;
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
    BooleanSetting(false, ""),
    BooleanSetting(false, PREF_USE_NEUMORPHISM),
    BooleanSetting(true, PREF_AUTOSELL_GOLD),
    TextboxSetting([], PREF_AUTOCONSUME_LIST),
  );
}

class Settings {
  final Setting? food;
  final Setting? booze;
  final Setting? skill;

  final List<Setting>? chatCommands;

  final Setting? volcOutfitName;
  final Setting? roOutfitName;
  final Setting? autohealMinHp;
  final Setting? autocastMaxMp;

  final BooleanSetting shouldAutoEquip;
  final BooleanSetting shouldUseNeumorphism;
  final BooleanSetting shouldAutosellGold;

  final TextboxSetting autoconsumeList;

  Settings(
    this.food,
    this.booze,
    this.skill,
    this.chatCommands,
    this.volcOutfitName,
    this.roOutfitName,
    this.autohealMinHp,
    this.autocastMaxMp,
    this.shouldAutoEquip,
    this.shouldUseNeumorphism,
    this.shouldAutosellGold,
    this.autoconsumeList,
  );

  @override
  String toString() {
    return "$food\n$booze\n$skill\n$volcOutfitName\n$roOutfitName\n$autohealMinHp\n$autocastMaxMp\n$chatCommands"
        "\n$shouldAutoEquip"
        "\n$shouldAutosellGold"
        "\n$shouldUseNeumorphism"
        "\n$autoconsumeList";
  }
}

abstract class AbstractSetting {
  void save(SharedPreferences prefs);

  void update(SharedPreferences prefs);
}

class BooleanSetting implements AbstractSetting {
  bool data;
  final String sharedprefKey;

  @override
  String toString() {
    return "$sharedprefKey: $data";
  }

  BooleanSetting(this.data, this.sharedprefKey);

  @override
  void save(SharedPreferences prefs) {
    prefs.setBool(sharedprefKey + PREF_SETTINGS_SUFFIX_VAL, data);
  }

  @override
  void update(SharedPreferences prefs) {
    // only update data if there is a value in shareprefs
    data = prefs.getBool(sharedprefKey + PREF_SETTINGS_SUFFIX_VAL) ?? data;
  }
}

class TextboxSetting implements AbstractSetting {
  List<String> data;
  final String sharedprefKey;
  String? asSingle;

  @override
  String toString() {
    return "$sharedprefKey: $data";
  }

  TextboxSetting(this.data, this.sharedprefKey);

  String getAsString() {
    if(asSingle != null) return asSingle!;

    return _computeString();
  }

  String _computeString() {
    asSingle = data.join("\n");
    return asSingle!;
  }

  @override
  void save(SharedPreferences prefs) {
    prefs.setStringList(sharedprefKey + PREF_SETTINGS_SUFFIX_VAL, data);
    print(data.toString());
  }

  @override
  void update(SharedPreferences prefs) {
    // only update data if there is a value in shareprefs
    data = prefs.getStringList(sharedprefKey + PREF_SETTINGS_SUFFIX_VAL) ?? data;
    print(data.toString());
  }

  void saveData(String input) {
    var split = input.split("\n");
    data = split;
  }
}

class StringSetting implements AbstractSetting {
  String data;
  String name;
  final String sharedprefKey;

  @override
  String toString() {
    return "$name: $data";
  }

  StringSetting(this.name, this.data, this.sharedprefKey);

  @override
  void save(SharedPreferences prefs) {
    prefs.setString(sharedprefKey + PREF_SETTINGS_SUFFIX_VAL, data);
    prefs.setString(sharedprefKey + PREF_SETTINGS_SUFFIX_NAME, name);
  }

  @override
  void update(SharedPreferences prefs) {
    data = prefs.getString(sharedprefKey + PREF_SETTINGS_SUFFIX_VAL) ?? "";
    name = prefs.getString(sharedprefKey + PREF_SETTINGS_SUFFIX_NAME) ?? "";
  }
}

/// VERY poorly named. Setting can only be a String setting now- something explodes when refactoring
class Setting extends StringSetting {
  String data;
  String name;
  final String sharedprefKey;

  @override
  String toString() {
    return "$name: $data";
  }

  Setting(this.name, this.data, this.sharedprefKey)
      : super(name, data, sharedprefKey);
}
