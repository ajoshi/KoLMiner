import 'dart:async';
import 'package:universal_html/html.dart' as html;

import 'package:kol_miner/network/kol_network.dart';

/// Wraps the [KolNetwork] class to make and parse arbitrary chat commands.
/// Will also parse response and make secondary calls as server requests
class ChatCommander {
  final KolNetwork _network;

  ChatCommander(this._network);

  /// Makes an arbitrary chat command request and follows most server redirects
  /// in the public interest the leading / is always appended
  /// Request should be of form "buy 10 ben" and not "/buy 10 ben"
  Future<String?> executeChatCommand(String command) async {
    var encodedCommand = Uri.encodeFull(command);
    return executeChainCommands(encodedCommand,
        isSecondaryCall: false,
        isPureChatCommand:
            command.startsWith("w ") || command.startsWith("msg "));
  }

  /// Executes the pass in chat [command].
  /// If it [isSecondaryCall], will call the url directly, else use the chat endpoint
  Future<String?> _executeCommand(String command,
      {bool isSecondaryCall = true}) async {
    if (isSecondaryCall) {
      return _callPath(command);
    } else {
      return (await _network.makeRequestWithQueryParams("submitnewchat.php",
              "playerid=${_network.getPlayerId()}&graf=%2Fnewbie+%2F$command&j=1",
              method: HttpMethod.POST,
              emptyResponseDefaultValue:
                  // commands can sometimes not respond, like skills.php?whichskill=7218&quantity=3&ajax=1&action=Skillz&ref=1&targetplayer=2129446
                  NetworkResponse(NetworkResponseCode.FAILURE, "")))
          .response;
    }
  }

  Future<String?> _callPath(String path) async {
    return (await _network.makeRequestToPath(path,
            method: HttpMethod.POST,
            emptyResponseDefaultValue:
                NetworkResponse(NetworkResponseCode.FAILURE, "")))
        .response;
  }

  /// Executes a [command] that can trigger another command (like macros)
  /// Returns no output if [isPureChatCommand] since chat isn't supported by this app
  Future<String?> executeChainCommands(String command,
      {bool isSecondaryCall = true, bool isPureChatCommand = false}) async {
    var response =
        await _executeCommand(command, isSecondaryCall: isSecondaryCall);
    if (response == null) return "";
    var start = "<font color=green>";
    var end = "<\\/font>";
    String chatOutput = "";

    var output = _getSubstringBetween(response, start, end);
    chatOutput = _appendTwoStringsWithNewline(
        chatOutput, _getChatOutputFromResponse(response));
    while (output != null) {
      var redirectUrl =
          _getSubstringBetween(output.match, "dojax('", "');)-->");
      if (redirectUrl != null) {
        var childResponse = _getChatOutputFromResponse(
            await executeChainCommands(redirectUrl.match));
        chatOutput = _appendTwoStringsWithNewline(chatOutput, childResponse);
        //      aj_print("Redirect for ${redirectUrl.match} at index ${redirectUrl.index}: $didSucceed");
      } else {
        //    aj_print("redirecturl was null");
      }
      output = _getSubstringBetween(response, start, end, output.index);
    }
    if (isPureChatCommand) {
      // Pure chat commands give us json and I don't care enough to parse it again
      return "";
    }
    return chatOutput;
  }

  String _appendTwoStringsWithNewline(String a, String b) {
    if (a.isEmpty) return b;
    if (b.isEmpty) return a;

    return a + "\n" + b;
  }

  String _getChatOutputFromResponse(String? response) {
    if (response == null) return "";
    var outputsMatch =
        _getSubstringBetween(response, "\"output\":\"", "<\\/font>");
    if (outputsMatch != null) {
      response = outputsMatch.match;
    } else {
      var resultsMatch = _getSubstringAfter(response, "Results:");
      if (resultsMatch != null) {
        response = resultsMatch.match;
      }
    }
    //   aj_print("Substring found for for $response");
    var text = html.Element.span()..appendHtml(response);
    return text.innerText;
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

  SubstringMatch? _getSubstringAfter(String response, String leftBound,
      [int offset = 0]) {
    int startIndex = response.indexOf(leftBound, offset);
    if (startIndex == -1) {
      return null;
    }
    startIndex += leftBound.length;

    return SubstringMatch(response.substring(startIndex), startIndex);
  }
}

class SubstringMatch {
  final String match;
  final int index;

  SubstringMatch(this.match, this.index);
}
