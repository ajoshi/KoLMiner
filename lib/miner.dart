import 'dart:async';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:kol_miner/kol_network.dart';

class Miner {
  final KolNetwork network;
  Mine currentMine;

  Miner({this.network});

  /// Get the layout of the mine. We can't do anything without knowing what
  /// the mine looks like
  Future<NetworkResponseCode> getMineLayout() async {
    var contents =
        await network.makeRequest("mining.php?mine=6&for=ajoshiMiningApp");
    if (contents.responseCode == NetworkResponseCode.SUCCESS) {
      try {
        parseMineLayout(contents.response);
      } catch (error) {
        print(error);
        return NetworkResponseCode.FAILURE;
      }
    }
    return contents.responseCode;
  }

  /// Mines the next reasonable square. If one isn't found, gets the next mine and tries again
  Future<MiningResponse> mineNextSquare() async {
    if (currentMine == null) {
      // get the layout if we don't have it
      var response = await getMineLayout();
      if (response != NetworkResponseCode.SUCCESS) {
        // can't access the mine at all
        return MiningResponse(response, MiningResponseCode.NO_ACCESS, false);
      }
    }
    //  print(currentMine);
    MineableSquare targetSquare = currentMine.getNextMineableSquare();
    if (targetSquare == null) {
      // if we have no valid links anymore, get a new mine
      if (currentMine.canGetNewMine) {
        print("we need a new mine and we can get one");
        if (await getNextMine()) {
          print("got a new mine!");
          // if we did get a new mine, then mine in that one
          return mineNextSquare();
        } else {
          // failed to get new mine. Out of advs? no hot res left?
          return new MiningResponse(
              NetworkResponseCode.FAILURE, MiningResponseCode.FAILURE, false);
        }
      } else {
        print("mining randomly so we can gtfo");
        // mine somewhere at random so the 'find new cavern' button shows up
        targetSquare = currentMine.getThrowawayMineSquare();
      }
    }
    print("we gonn mine $targetSquare");
    var mineResponse = await network.makeRequest(targetSquare.url);
    if (mineResponse.responseCode == NetworkResponseCode.SUCCESS) {
      bool didStrikeGold = mineResponse.response.contains("carat");
      if (mineResponse.response.contains("You're out of adventures.")) {
        // special check else we keep trying until our counter is over
        // not infinite loop, but we can quit sooner so we should
        return MiningResponse(
            NetworkResponseCode.FAILURE, MiningResponseCode.FAILURE, false);
      }
      parseMineLayout(mineResponse.response);
      return new MiningResponse.success(
          NetworkResponseCode.SUCCESS, didStrikeGold);
    } else {
      return new MiningResponse(
          mineResponse.responseCode, MiningResponseCode.FAILURE, false);
    }
  }

  Future<bool> getNextMine() async {
    var miningResponse = await network
        .makeRequest("mining.php?mine=6&reset=1&for=ajoshiMiningApp");
    if (miningResponse.responseCode == NetworkResponseCode.SUCCESS) {
      parseMineLayout(miningResponse.response);
      if (miningResponse.response.contains("You're out of adventures.")) {
        return false;
      }
    } else
      return false;
    return true;
  }

  Document parseMineLayout(String contents) {
    var layout = parse(contents);
    var listOfMineSquares = new List<MineableSquare>();
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
//        var isShiny = child.attributes["src"].contains("https://s3.amazonaws.com/images.kingdomofloathing.com/otherimages/mine/wallsparkle");
      var altText = child.attributes["alt"];
      int y =
          int.parse(altText.substring(altText.length - 2, altText.length - 1));
      int x =
          int.parse(altText.substring(altText.length - 4, altText.length - 3));
      var isInFirstTwoRows = y == 5 || y == 6;
      MineableSquare square =
          MineableSquare(link, isShiny, isInFirstTwoRows, x, y);
      listOfMineSquares.add(square);
    }
    Mine newMine = new Mine(listOfMineSquares);
    layout.getElementsByClassName("button");
    newMine.canGetNewMine = contents.contains("Find New Cavern");
    currentMine = newMine;
    return layout;
  }
}

/// An instance of a mine. Contains a list of minable squares
class Mine {
  List<MineableSquare> squares = new List();
  bool canGetNewMine = false;

  /// constructor takes in a list of initial mineable squares
  Mine(this.squares);

  void addSquare(MineableSquare square) {
    squares.add(square);
  }

  /// algorithm:
  /// check exposed shinies. If found, click
  /// if no shinies, click anywhere once. If shiny found, click. Else newmine
  MineableSquare getNextMineableSquare() {
    // mine visible shiny squares asap (unless they're in 3rd row)
    MineableSquare square;
    square = squares.firstWhere((test) => test.isShiny && test.isFirstTwoRows,
        orElse: () => square = null);
    if (square == null) {
      print("need a new mine");
      // need a new mine
      return null;
    }
    return square;
  }

  // If we see no shinies, we need a new mine. But a new mine can't be
  // requested until we've mined at least once.
  /// This method gives us a square we can mine that has a high-ish prob of
  /// exposing a shiny. Else we can just ask for a new mine.
  MineableSquare getThrowawayMineSquare() {
    return squares.firstWhere((test) => test.x != 01 && test.x != 6);
  }

  String toString() {
    String value = "";
    for (MineableSquare sq in squares) {
      value = value + sq.toString() + "\n";
    }
    return value;
  }
}

/// A square in the mining grid
class MineableSquare {
  final String url;
  final bool isShiny;
  final bool isFirstTwoRows;
  final int x;
  final int y;

  MineableSquare(this.url, this.isShiny, this.isFirstTwoRows, this.x, this.y);

  bool isHighPriority() {
    return isFirstTwoRows && isShiny;
  }

  bool isLowPriority() {
    return isFirstTwoRows;
  }

  bool isCornerSquare() {
    return x == 0 || x == 7;
  }

  String toStringForResponse() {
    return "at ($x,$y). shiny? $isShiny isFront? $isFirstTwoRows";
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

  MiningResponse.success(
    this.networkResponseCode,
    this.foundGold,
  ) : miningResponseCode = MiningResponseCode.SUCCESS;

  bool isSuccess() {
    return networkResponseCode == NetworkResponseCode.SUCCESS &&
        miningResponseCode == MiningResponseCode.SUCCESS;
  }
}

/// Mining can fail even if network response fails so we need a new enum
enum MiningResponseCode {
  SUCCESS,
  NO_ACCESS,
  FAILURE,
}
