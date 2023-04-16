import 'dart:async';

import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/player_info/user_info_requests.dart';

import '../utils.dart';

abstract class ArbitraryRequestsChatHost {
  void onPreConfiguredActionsWidgetRequestsStatusUpdate();

  void onPreConfiguredActionsWidgetError();

  void onPreConfiguredActionsWidgetChatRequest(String chat);

  Future<String?> onPreConfiguredActionsWidgetChatRequestForResponse(
      String text);

  UserInfoRequest? getCurrentUserInfo();
}

class ArbitraryRequests {
  static const MILK_EFFECT_HASH = "225aa10e75476b0ad5fa576c89df3901";
  static const ODE_EFFECT_HASH = "626c8ef76cfc003c6ac2e65e9af5fd7a";

  /*
  Supported commands:
  all? normal chat will be failed by the chatparser anywho

  w/msg
  eat
  drink
  use
  cast

   */

  /*
w buffy ode
1 chug elemental caip
5 eat 3 hot hi mein
use tofu
use chocolate stolen saucep
 */

  final KolNetwork network;
  final ArbitraryRequestsChatHost host;
  late String currentMp;
  late int currentMilkTurns;
  late int odeTurns;

  ArbitraryRequests(this.network, this.host);

  bool runRequests(List<String>? requests, {bool abortIfDrunk: true}) {
    if (requests == null) {
      return false;
    }
    if (abortIfDrunk) {
      host.onPreConfiguredActionsWidgetChatRequest("w buffy ode");
      int? currentDrunk = host.getCurrentUserInfo()?.drunk;
      if (currentDrunk == null || currentDrunk > 0) {
        return false;
      }
      // check current drunkness, return if over 0
      //this will be false when this is explicitly user requested
    }
    // check current drunkenness
    for (String req in requests) {
      host.onPreConfiguredActionsWidgetChatRequest(req);
    }

    return true;
  }

  Future<bool> runRequestsWithATeensyWait(List<String>? requests,
      {bool abortIfDrunk: true}) {
    bool rvalue = runRequests(requests, abortIfDrunk: abortIfDrunk);
    if (rvalue == false) {
      return Future.value(false);
    }
    return Future.delayed(Duration(seconds: 10), () => rvalue);
  }

  Future<bool> doStandardStuff() async {
    int? currentDrunk = host.getCurrentUserInfo()?.drunk;
    if (currentDrunk == null || currentDrunk == 0) {
      host.onPreConfiguredActionsWidgetChatRequest("buy 3 chew && /use 3 chew");
      // get free hippy meat
      network.makeRequestWithQueryParams(
          "shop.php", "whichshop=hippy");
      // check mario
      network.makeRequestWithQueryParams(
          "place.php", "whichplace=arcade&action=arcade_plumber");
      // genie?
      network.makeRequestWithQueryParams(
          "choice.php", "whichchoice=1267&option=1&wish=I%20wish%20I%20had%20more%20wishes").then((value) =>
          network.makeRequestWithQueryParams(
              "choice.php", "whichchoice=1267&option=1&wish=I%20wish%20I%20had%20more%20wishes")
      ).then((value) => network.makeRequestWithQueryParams(
          "choice.php", "whichchoice=1267&option=1&wish=I%20wish%20I%20had%20more%20wishes"));
      // buy clovers
      network.makeRequestWithQueryParams(
          "hermit.php", "action=trade&whichitem=10881&quantity=2");
    }

    return visitDiscoFuture().then((value) => runRequests([
          "w buffy 600 jalapeno",
          "w buffy 600 elemental",
          "w buffy 600 astral shell"
        ], abortIfDrunk: false));
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
    // unconditional milk use before every eat :(
    requestMilkUse();
    return (await network.makeRequestWithQueryParams(
            "inv_eat.php", "which=1&whichitem=$id"))
        .responseCode;
  }

  /// Go to the disco... but also return a value
  Future<NetworkResponse> visitDiscoFuture() async {
    aj_print("I'm a disco dancer");
    var r2 = await network.makeRequestWithQueryParams(
        "place.php", "whichplace=airport_hot&action=airport4_zone1",
        expectRedirects: true);
    aj_print("\ndisco 1");
    aj_print(r2.response);
    var result = network.makeRequestWithQueryParams(
        "choice.php", "whichchoice=1090&option=7");
    aj_print("\ndisco 2");
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
