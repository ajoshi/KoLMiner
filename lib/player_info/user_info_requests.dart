import 'dart:async';

import 'package:kol_miner/network/kol_network.dart';

class UserInfoRequest {
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
        return true;
      }
      return false;
    });
  }

  int _asInt(dynamic potentialInt) {
    if (potentialInt.runtimeType == "".runtimeType) {
      return int.parse(potentialInt);
    }
    return potentialInt;
  }

  String _asString(dynamic potentialString) {
    return "$potentialString";
  }
}
