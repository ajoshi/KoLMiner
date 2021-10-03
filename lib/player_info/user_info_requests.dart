import 'dart:async';

import 'package:kol_miner/network/kol_network.dart';

class UserInfoRequest {
  final KolNetwork _network;
  late final String userName;
  late final String chatPwd;
  late final int currentMp;
  late final int currentHp;
  late final int maxMp;
  late final int maxHp;
  late final int advs;

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
