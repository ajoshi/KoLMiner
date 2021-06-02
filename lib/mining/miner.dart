import 'dart:async';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:kol_miner/network/kol_network.dart';

import '../constants.dart';
import 'mine.dart';

/// Wraps the [KolNetwork] class to make and parse mining related calls
/// Also contains the overall algorithm for mining.
/// The fix for https://github.com/ajoshi/KoLMiner/issues/3 should be here
class Miner {
  final KolNetwork _network;
  Mine currentMine;

  Miner(this._network);

  /// Get the layout of the mine. We can't do anything without knowing what
  /// the mine looks like
  Future<MineDataResponse> getMineLayout() async {
    var contents =
        await _network.makeRequestWithQueryParams("mining.php", "mine=6");
    if (contents.responseCode == NetworkResponseCode.SUCCESS) {
      try {
        parseMineLayout(contents.response, 0);
        return MineDataResponse(
            contents.responseCode, MiningResponseCode.SUCCESS);
      } catch (error) {
        print(error);
        return MineDataResponse(
            contents.responseCode, MiningResponseCode.NO_ACCESS);
      }
    }
    return MineDataResponse(contents.responseCode, MiningResponseCode.FAILURE);
  }

  /// Autosell some of that mined gold. Sells one piece by default
  Future<bool> autoSellGold({int count = 1}) async {
    print("Selling $count gold");
    var response = await _network.makeRequestWithQueryParams("sellstuff.php",
        "action=sell&ajax=1&type=quant&howmany=$count&whichitem%5B%5D=8424",
        method: HttpMethod.POST);
    return (response.responseCode == NetworkResponseCode.SUCCESS);
  }

  /// Mines the next reasonable square. If one isn't found, gets the next mine and tries again
  Future<MiningResponse> mineNextSquare() async {
    if (currentMine == null) {
      // get the layout if we don't have it
      var response = await getMineLayout();
      if (response.miningResponseCode != MiningResponseCode.SUCCESS) {
        // can't access the mine at all
        return MiningResponse(
            response.networkResponseCode, response.miningResponseCode, false);
      }
    }
    //  print(currentMine);
    MineableSquare targetSquare = currentMine.getNextMineableSquare();
    if (targetSquare == null) {
      // if we have no valid links anymore, get a new mine
      if (currentMine.canGetNewMine) {
        if (DEBUG) {
          print("we need a new mine and we can get one");
        }
        if (await getNextMine()) {
          if (DEBUG) {
            print("got a new mine!");
          }
          // if we did get a new mine, then mine in that one
          return mineNextSquare();
        } else {
          // failed to get new mine. Out of advs? no hot res left?
          return new MiningResponse(
              NetworkResponseCode.FAILURE, MiningResponseCode.FAILURE, false);
        }
      } else {
        if (DEBUG) {
          print("mining randomly so we can gtfo");
        }
        // mine somewhere at random so the 'find new cavern' button shows up
        targetSquare = currentMine.getThrowawayMineSquare();
      }
    }
    return mineSquare(targetSquare);
  }

  /// Mines the given square and returns a failure if it can't
  Future<MiningResponse> mineSquare(MineableSquare targetSquare) async {
    //    print("we gonn mine $targetSquare");
    // if the url changes (maybe?) to not have params in it, the app name won't be parsed
    // since params are optional, everything should work fine on our end though
    var mineResponse =
        await _network.makeRequest("${targetSquare.url}&${_network.appName}");
    if (mineResponse.responseCode == NetworkResponseCode.SUCCESS) {
      if (DEBUG) {
        print("mined $targetSquare");
      }
      bool didStrikeGold = mineResponse.response.contains("carat");
      if (mineResponse.response.contains("You're out of adventures.") ||
          mineResponse.response
              .contains("You're way too drunk to mine right now")) {
        // special check else we keep trying until our counter is over
        // not infinite loop, but we can quit sooner so we should
        return MiningResponse(
            NetworkResponseCode.SUCCESS, MiningResponseCode.FAILURE, false);
      }
      parseMineLayout(mineResponse.response, currentMine.minedSquares + 1);
      if (didStrikeGold) {
        // once a gold is found, we want to move on to the next mine
        autoSellGold();
        currentMine.squares.clear();
      }
      return new MiningResponse.success(didStrikeGold);
    } else {
      return new MiningResponse(
          mineResponse.responseCode, MiningResponseCode.FAILURE, false);
    }
  }

  /// Gets the next mine if it can.
  /// Returns true on success.
  Future<bool> getNextMine() async {
    var miningResponse = await _network.makeRequestWithQueryParams(
        "mining.php", "mine=6&reset=1");
    if (miningResponse.responseCode == NetworkResponseCode.SUCCESS) {
      parseMineLayout(miningResponse.response, 0);
      if (miningResponse.response.contains("You're out of adventures.")) {
        return false;
      }
    } else
      return false;
    return true;
  }

  /// Parses the mine layout so we know where we should mine next
  Document parseMineLayout(String contents, int squaresAlreadyMined) {
    var layout = parse(contents);
    var listOfMineSquares = <MineableSquare>[];
    var linkElements = layout.getElementsByTagName("a");
    for (var element in linkElements) {
      var link = element.attributes["href"];
      // not all links are mining links, so exclude those
      if (link == null ||
          element.children == null ||
          element.children.isEmpty) {
        continue;
      }
      var child = element.children[0];
      var isShiny = child.attributes["alt"].contains("Promising");
      // alt: use the alttext for images to figure out the location+shininess
      // var isShiny = child.attributes["src"].contains("https://s3.amazonaws.com/images.kingdomofloathing.com/otherimages/mine/wallsparkle");
      var altText = child.attributes["alt"];
      int y =
          int.parse(altText.substring(altText.length - 2, altText.length - 1));
      int x =
          int.parse(altText.substring(altText.length - 4, altText.length - 3));
      MineableSquare square =
          MineableSquare(link, isShiny, x, y);
      listOfMineSquares.add(square);
    }
    Mine newMine = new Mine(listOfMineSquares, contents.contains("Find New Cavern"), squaresAlreadyMined);
    layout.getElementsByClassName("button");
    if (DEBUG && newMine.squares.length == 0) {
      print("network response: [$contents]");
    }
    currentMine = newMine;
    return layout;
  }
}

class MiningResponse {
  /// Tells us if the network call succeeded/failed
  final NetworkResponseCode networkResponseCode;

  /// Tells us if the mining attempt succeeded or failed (assuming network succeeded)
  final MiningResponseCode miningResponseCode;

  /// true if we struck gold
  final bool foundGold;

  MiningResponse(
    this.networkResponseCode,
    this.miningResponseCode,
    this.foundGold,
  );

  /// Constructor to use when mining has succeeded
  MiningResponse.success(
    this.foundGold,
  )   : miningResponseCode = MiningResponseCode.SUCCESS,
        networkResponseCode = NetworkResponseCode.SUCCESS;

  bool isSuccess() {
    return networkResponseCode == NetworkResponseCode.SUCCESS &&
        miningResponseCode == MiningResponseCode.SUCCESS;
  }
}

/// Mining can fail even if network response fails so we need a new enum
enum MiningResponseCode {
  SUCCESS,

  /// User does not have access to mine (no ticket/outfit/hot res)
  NO_ACCESS,

  /// Mining failed (0 hp, 0 advs, something else)
  FAILURE,
}

/// Data class that tells us if the call to get mine data succeeded or not
class MineDataResponse {
  /// Tells us if the network call succeeded/failed
  final NetworkResponseCode networkResponseCode;

  /// Tells us if the mining attempt succeeded or failed (assuming network succeeded)
  final MiningResponseCode miningResponseCode;

  MineDataResponse(this.networkResponseCode, this.miningResponseCode);
}
