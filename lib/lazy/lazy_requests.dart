import 'dart:async';

import 'package:kol_miner/network/kol_network.dart';

class LazyRequest {
  static const MILK_EFFECT_HASH = "225aa10e75476b0ad5fa576c89df3901";
  static const ODE_EFFECT_HASH = "626c8ef76cfc003c6ac2e65e9af5fd7a";

  final KolNetwork network;
  String currentMp;
  int currentMilkTurns;
  int odeTurns;

  LazyRequest(this.network);

  /// Given an effect Id (or is it some secret hash?), returns how many turns
  /// of this effect are left
  int getEffectTurns(dynamic effects, String effectId) {
    if (effects.containsKey(effectId)) {
      var desiredEffect = effects[effectId];
      if (desiredEffect[1].runtimeType == "".runtimeType) {
        print("milk was a string");
        return int.parse(desiredEffect[1]);
      }
      // this is insane- the type changes. WHY????
      print("milk was an int");
      return desiredEffect[1];
    }
    return 0;
  }

  /// Update the hp/mp/advs info text
  Future<bool> getPlayerData() async {
    var playerData = await network.getPlayerData();
    if (playerData != null) {
      currentMp = playerData["mp"];
      // go through effects to find how many turns of milk we have
      if (playerData.containsKey("effects")) {
        // someone could have 0 effects so we put in a guard
        var effects = playerData["effects"];
        currentMilkTurns = getEffectTurns(effects, MILK_EFFECT_HASH);
        odeTurns = getEffectTurns(effects, ODE_EFFECT_HASH);
      }
      return true;
    }
    return false;
  }

  Future<NetworkResponseCode> requestNunHealing() async {
    return (await network.makeRequestWithQueryParams(
            "postwarisland.php", "action=nuns&place=nunnery"))
        .responseCode;
  }

  Future<NetworkResponseCode> requestResolutionSummon() async {
    var response = await network.makeRequestWithQueryParams(
        "runskillz.php", "targetplayer=0&whichskill=7224&quantity=1");
    return response.responseCode;
  }

  /// Drink perfect mimosa
  requestPerfectDrink() async {
    await network.makeRequestWithQueryParams(
        "inv_booze.php", "which=1&whichitem=8740");
  }

  /// Eat sleazy hi mein
  requestEatSleazyHimein() async {
    print("eating");
    await network.makeRequestWithQueryParams(
        "inv_eat.php", "which=1&whichitem=1596");
  }

  /// Visit the disco for free coin
  visitDisco() async {
    print("I'm a disco dancer");
    await network.makeRequestWithQueryParams(
        "place.php", "whichplace=airport_hot&action=airport4_zone1");
    await network.makeRequestWithQueryParams(
        "choice.php", "whichchoice=1090&option=7");
  }

  /// Use a milk of mag
  requestMilkUse() async {
    await network.makeRequestWithQueryParams(
        "inv_use.php", "which=3&whichitem=1650");
  }
}
