import 'dart:async';

import 'package:kol_miner/network/kol_network.dart';

import '../utils.dart';

class UserInfoRequest {


  static const _MILK_EFFECT_HASH = "225aa10e75476b0ad5fa576c89df3901";
  static const _ODE_EFFECT_HASH = "626c8ef76cfc003c6ac2e65e9af5fd7a";

  final KolNetwork _network;
  late String userName;
  late String chatPwd;
  late int currentMp;
  late int currentHp;
  late int maxMp;
  late int maxHp;
  late int advs;
  late int drunk;
  late int full;
  late int meat;
  late int currentMilkTurns;
  late int odeTurns;

  UserInfoRequest(this._network);

  /// Update the hp/mp/advs info text
  /// advs left, hp, mp
  /// advs spent, gold found, meat
  Stream<bool> getPlayerData() {
    var playerData = _network.getPlayerData();

    return playerData.map((map) {
      if (map != null) {
        // get the user info
        userName = _asString(map["name"]);
        currentHp = _asInt(map["hp"]);
        currentMp = _asInt(map["mp"]);
        maxMp = _asInt(map["maxmp"]);
        maxHp = _asInt(map["maxhp"]);
        advs = _asInt(map["adventures"]);
        drunk = _asInt(map["drunk"]);
        full = _asInt(map["full"]);
        meat = _asInt(map["meat"]);
        if (map.containsKey("effects")) {
          // someone could have 0 effects so we put in a guard
          var effects = map["effects"];
          // lool milk turns don't even matter anymore
          currentMilkTurns = getEffectTurns(effects, _MILK_EFFECT_HASH);
          odeTurns = getEffectTurns(effects, _ODE_EFFECT_HASH);
        }
        return true;
      }
      return false;
    });
  }

  /// Given an effect Id (or is it some secret hash?), returns how many turns
  /// of this effect are left
  int getEffectTurns(dynamic effects, String effectId) {
    if (effects.containsKey(effectId)) {
      var desiredEffect = effects[effectId];
      return _asInt(desiredEffect[1]);
    }
    return 0;
  }

  int _asInt(dynamic potentialInt) {
    if (potentialInt.runtimeType == "".runtimeType) {
      aj_print("effect was a string");
      return int.parse(potentialInt);
    }
    // this is insane- the type changes. WHY????
    aj_print("effect was an int");
    return potentialInt;
  }

  String _asString(dynamic potentialString) {
    return "$potentialString";
  }
}
