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
  Future<bool> getPlayerData() async {
    var playerData = await _network.getPlayerData();
    if (playerData != null) {
      // get the user info
      userName = _asString(playerData["name"]);
      currentHp = _asInt(playerData["hp"]);
      currentMp = _asInt(playerData["mp"]);
      maxMp = _asInt(playerData["maxmp"]);
      maxHp = _asInt(playerData["maxhp"]);
      advs = _asInt(playerData["adventures"]);
      drunk = _asInt(playerData["drunk"]);
      full = _asInt(playerData["full"]);
      meat = _asInt(playerData["meat"]);

      return true;
    }
    return false;
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
