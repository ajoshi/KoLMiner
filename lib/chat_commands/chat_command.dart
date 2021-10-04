import 'dart:async';

import 'package:kol_miner/network/kol_network.dart';

/// Wraps the [KolNetwork] class to make and parse arbitrary chat commands.
/// Will also parse response and make secondary calls as server requests
class ChatCommander {
  final KolNetwork _network;

  ChatCommander(this._network);

  /// Makes an arbitrary chat command request and follows most server redirects
  /// in the public interest the leading / is always appended
  /// Request should be of form "buy 10 ben" and not "/buy 10 ben"
  Future<bool> executeChatcommand(String command) async {
    var encodedCommand = Uri.encodeFull(command);
    var response = await _network.makeRequestWithQueryParams(
        "submitnewchat.php",
        "playerid=${_network.getPlayerId()}&graf=%2Fnewbie+%2F$encodedCommand&j=1",
        method: HttpMethod.POST,
        emptyResponseDefaultValue:
            NetworkResponse(NetworkResponseCode.FAILURE, ""));

    return followChatRedirectsInResponse(response.response);
  }

  Future<bool> followChatRedirectsInResponse(String responseString) async {
    var start = "<font color=green>";
    var end = "<\\/font>";

    bool didSucceed = false;
    // we could also output the displayed html in this response. Shows output ike "using 1 slimy paste"
    var output = _getSubstringBetween(responseString, start, end);
    while (output != null) {
      //     print("Substring found for for ${output.match} at index ${output.index}");
      var redirectUrl =
          _getSubstringBetween(output.match, "dojax('", "');)-->");
      if (redirectUrl != null) {
        didSucceed = (await _network.makeRequestToPath(redirectUrl.match,
                    method: HttpMethod.POST))
                .responseCode ==
            NetworkResponseCode.SUCCESS;
        //      print("Redirect for ${redirectUrl.match} at index ${redirectUrl.index}: $didSucceed");
      } else {
        //    print("redirecturl was null");
      }
      output = _getSubstringBetween(responseString, start, end, output.index);
    }
//    print("all donesies");
    return didSucceed;
  }

  SubstringMatch? _getSubstringBetween(
      String response, String leftBound, String rightBound,
      [int offset = 0]) {
    int startIndex = response.indexOf(leftBound, offset);
    if (startIndex == -1) {
      return null;
    }
    startIndex += leftBound.length;
    int endIndex = response.indexOf(rightBound, startIndex);

    return SubstringMatch(response.substring(startIndex, endIndex), startIndex);
  }
}

class SubstringMatch {
  final String match;
  final int index;

  SubstringMatch(this.match, this.index);
}
