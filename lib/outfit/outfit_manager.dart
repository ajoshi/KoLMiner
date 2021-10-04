import 'dart:async';

import 'package:kol_miner/network/kol_network.dart';

import '../utils.dart';

/// Wraps the [KolNetwork] class to make and parse outfit related calls
@Deprecated("Use ChatCommander instead")
class OutfitManager {
  final KolNetwork _network;

  OutfitManager(this._network);

  Future<bool> equipPreparedOutfit(int? outfitId) async {
    if (outfitId == null) {
      return false;
    }
    var response = await _network.makeRequestWithQueryParams(
        "inv_equip.php", "action=outfit&which=2&whichoutfit=$outfitId",
        method: HttpMethod.POST, allowEmptyResponse: true);
    return (response.responseCode == NetworkResponseCode.SUCCESS);
  }

  Future<bool> equipSinglePiece(int equipmentId) async {
    var response = await _network.makeRequestWithQueryParams(
        "inv_equip.php", "which=2&action=equip&whichitem=$equipmentId",
        method: HttpMethod.POST, allowEmptyResponse: true);
    return (response.responseCode == NetworkResponseCode.SUCCESS);
  }

  Future<bool> equipOutfitUsingName(String outfitName) async {
    var response = await _network.makeRequestWithQueryParams(
        "submitnewchat.php",
        "playerid=${_network.getPlayerId()}&graf=%2Fnewbie+%2Foutfit+$outfitName&j=1",
        method: HttpMethod.POST);

    return equipPreparedOutfit(_getOutfitIdFromChatResponse(response.response));
  }

  int? _getOutfitIdFromChatResponse(String response) {
    aj_print(response);
    String leftBound = "whichoutfit=";
    int startIndex = response.indexOf(leftBound);
    if (startIndex == -1) {
      return null;
    }
    startIndex += leftBound.length;
    int endIndex = response.indexOf("&ajax=1", startIndex);

    return int.tryParse(response.substring(startIndex, endIndex));
  }
}
