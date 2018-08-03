import 'dart:async';
import 'dart:convert';

import 'package:kol_miner/kol_network.dart';

class LazyRequest {
  static const MILK_EFFECT_HASH = "225aa10e75476b0ad5fa576c89df3901";
  static const ODE_EFFECT_HASH = "626c8ef76cfc003c6ac2e65e9af5fd7a";

  final KolNetwork network;
  String chatPwd;
  String currentMp;
  String currentHp;
  String advs;
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

  Future<bool> getPlayerData() async {
    var statusresponse =
        await network.makeRequestWithQueryParams("api.php", "what=status");
    //{"playerid":"2129446","name":"ajoshi","hardcore":"1","ascensions":"319",
    // "path":"22","sign":"Vole","roninleft":"308","casual":"0","drunk":"13",
    // "full":"4","turnsplayed":"760080","familiar":"213","hp":"359","mp":"54",
    // "meat":"95332","adventures":"42","level":"14","rawmuscle":"12920",

    // "rawmysticality":"13323","rawmoxie":"32584","basemuscle":"113",
    // "basemysticality":"115","basemoxie":"180","familiarexp":400,"class":"6",
    // "lastadv":{"id":"1026","name":"The Naughty Sorceress' Tower",
    // "link":"place.php?whichplace=nstower","container":"place.php?whichplace=nstower"},
    // "title":"14","pvpfights":"70","maxhp":394,"maxmp":446,"spleen":"0",
    // "muscle":223,"mysticality":225,"moxie":345,"famlevel":25,"locked":false,
    // "limitmode":0,"daysthisrun":"4","equipment":{"hat":"2069","shirt":"6719",
    // "pants":"9574","weapon":"6815","offhand":"9133","acc1":"5039","acc2":"7967",
    // "acc3":"9322","container":"9082","familiarequip":"2573","fakehands":0,"cardsleeve":0},
    // "stickers":[0,0,0],"soulsauce":0,"fury":0,"pastathrall":0,"pastathralllevel":1,
    // "folder_holder":["17","15","22","00","00"],"eleronkey":"<SOME HASH>",
    // "flag_config":{"noinvpops":0,"fastdecking":"1","devskills":0,"shortcharpane":0,
    // "lazyinventory":0,"compactfights":"1","poppvpsearch":0,"questtracker":0,
    // "charpanepvp":"1","australia":"1","fffights":"1","compactchar":0,"noframesize":0,
    // "fullnesscounter":"1","nodevdebug":0,"noquestnudge":0,"nocalendar":0,"alwaystag":0,
    // "clanlogins":"1","quickskills":"1","hprestorers":0,"hidejacko":0,"anchorshelf":0,
    // "showoutfit":0,"wowbar":"1","swapfam":0,"hidefamfilter":0,"invimages":0,
    // "showhandedness":0,"acclinks":"1","invadvancedsort":"1","powersort":0,
    // "autodiscard":0,"unfamequip":"1","invclose":0,"sellstuffugly":0,
    // "oneclickcraft":0,"dontscroll":0,"multisume":"1","threecolinv":"1","profanity":"1",
    // "tc_updatetitle":0,"tc_alwayswho":0,"tc_times":0,"tc_combineallpublic":0,
    // "tc_eventsactive":0,"tc_hidebadges":0,"tc_colortabs":0,"tc_modifierkey":0,
    // "tc_tabsonbottom":0,"chatversion":"1","aabosses":0,"compacteffects":0,
    // "slimhpmpdisplay":"1","ignorezonewarnings":"1","whichpenpal":"4",
    // "compactmanuel":"1","hideefarrows":0,"questtrackertiny":0,"questtrackerscroll":0,
    // "disablelovebugs":0,"eternalmrj":"1","autoattack":0,"topmenu":0},"recalledskills":0,
    // "freedralph":0,"mcd":0,"pwd":"a629273e74c4cef59001974fa47a8556",
    // "rollover":1533353398,"turnsthisrun":692,"familiar_wellfed":0,
    // "intrinsics":{"518f53443c261c2b61ea11fe8716a715":["Spirit of Peppermint",
    // "snowflake","518f53443c261c2b61ea11fe8716a715","168"]},"familiarpic":"xoskeleton",
    // "pathname":"Standard",
    // "effects":{"0bf172ccba65be4fdc4c0f908325b5c1":["Everything Looks Yellow",66,"eyes",null,790]}}
    if (statusresponse.responseCode == NetworkResponseCode.SUCCESS) {

      Map parsedResponse = JSON.decode(statusresponse.response);

      // get the hp and mp
      currentHp = parsedResponse["hp"];
      currentMp = parsedResponse["mp"];
      int maxMp = parsedResponse["maxmp"];
      advs = parsedResponse["adventures"];

      print("MP: $currentMp");
      print("advs: $advs");

      // go through effects to find how many turns of milk we have
      if (parsedResponse.containsKey("effects")) {
        // someone could have 0 effects so we put in a guard
        var effects = parsedResponse["effects"];
        currentMilkTurns = getEffectTurns(effects, MILK_EFFECT_HASH);
        odeTurns = getEffectTurns(effects, ODE_EFFECT_HASH);
      }
      print(currentMilkTurns);
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
    //&ajax=1&_=1532925498042
    //oneskillz

//    await network.makeRequest("skillz.php?pwd=$pwdHash&oneskillz=7224");
    var response = await network.makeRequestWithQueryParams(
        "runskillz.php", "targetplayer=0&whichskill=7224&quantity=1");
    return response.responseCode;
  }

  requestPerfectDrink() async {
    await network.makeRequestWithQueryParams(
        "inv_booze.php", "which=1&whichitem=8740");
  }

  requestEatSleazyHimein() async {
    print("eating");
    await network.makeRequestWithQueryParams(
        "inv_eat.php", "which=1&whichitem=1596");
  }

  /// Use a milk of mag
  requestMilkUse() async {
    await network.makeRequestWithQueryParams(
        "inv_use.php", "which=3&whichitem=1650");
  }
}
