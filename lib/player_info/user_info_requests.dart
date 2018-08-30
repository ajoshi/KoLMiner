import 'dart:async';

import 'package:kol_miner/network/kol_network.dart';

class UserInfoRequest {
  final KolNetwork _network;
  String userName;
  String chatPwd;
  int currentMp;
  int currentHp;
  int maxMp;
  int maxHp;
  int advs;

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
