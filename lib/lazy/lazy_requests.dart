import 'dart:async';

import 'package:kol_miner/network/kol_network.dart';

import '../utils.dart';

class LazyRequest {
  static const MILK_EFFECT_HASH = "225aa10e75476b0ad5fa576c89df3901";
  static const ODE_EFFECT_HASH = "626c8ef76cfc003c6ac2e65e9af5fd7a";

  final KolNetwork network;
  late String currentMp;
  late int currentMilkTurns;
  late int odeTurns;

  LazyRequest(this.network);

  /// Given an effect Id (or is it some secret hash?), returns how many turns
  /// of this effect are left
  int getEffectTurns(dynamic effects, String effectId) {
    if (effects.containsKey(effectId)) {
      var desiredEffect = effects[effectId];
      if (desiredEffect[1].runtimeType == "".runtimeType) {
        aj_print("milk was a string");
        return int.parse(desiredEffect[1]);
      }
      // this is insane- the type changes. WHY????
      aj_print("milk was an int");
      return desiredEffect[1];
    }
    return 0;
  }

  /// Update the hp/mp/advs info text
  Stream<bool> getPlayerData() {
    var playerData = network.getPlayerData();
    return playerData.map((map) {
      if (map != null) {
        currentMp = map["mp"];
        // go through effects to find how many turns of milk we have
        if (map.containsKey("effects")) {
          // someone could have 0 effects so we put in a guard
          var effects = map["effects"];
          currentMilkTurns = getEffectTurns(effects, MILK_EFFECT_HASH);
          odeTurns = getEffectTurns(effects, ODE_EFFECT_HASH);
        }
        return true;
      }
      return false;
    });
  }

  /// nun your business
  Future<NetworkResponseCode> requestNunHealing() async {
    return (await network.makeRequestWithQueryParams(
            "postwarisland.php", "action=nuns&place=nunnery"))
        .responseCode;
  }

  /// skill a skill
  Future<NetworkResponseCode> requestSkill(String id) async {
    var response = await network.makeRequestWithQueryParams(
        "runskillz.php", "targetplayer=0&whichskill=$id&quantity=1",
        expectRedirects: true);
    return response.responseCode;
  }

  /// drink a booze
  Future<NetworkResponseCode> requestDrink(String id) async {
    return (await network.makeRequestWithQueryParams(
            "inv_booze.php", "which=1&whichitem=$id"))
        .responseCode;
  }

  /// Eat a food
  Future<NetworkResponseCode> requestFood(String id) async {
    aj_print("eating");
    return (await network.makeRequestWithQueryParams(
        "inv_eat.php", "which=1&whichitem=$id"))
        .responseCode;
  }

  /// Go to the disco... but also return a value
  Future<NetworkResponse> visitDiscoFuture() async {
    aj_print("I'm a disco dancer");
    await network.makeRequestWithQueryParams(
        "place.php", "whichplace=airport_hot&action=airport4_zone1");
    aj_print("disco 1");
   var result =  network.makeRequestWithQueryParams(
        "choice.php", "whichchoice=1090&option=7");
    aj_print("disco 2");
    return result;
  }

  /// Visit the disco for free coin
  visitDisco() async {
    aj_print("I'm a disco dancer");
    await network.makeRequestWithQueryParams(
        "place.php", "whichplace=airport_hot&action=airport4_zone1");
    aj_print("disco 1");
    await network.makeRequestWithQueryParams(
        "choice.php", "whichchoice=1090&option=7");
    aj_print("disco 2");
    aj_print("Disco danced");
  }

  /// Use a milk of mag
  requestMilkUse() async {
    await network.makeRequestWithQueryParams(
        "inv_use.php", "which=3&whichitem=1650");
  }
}
