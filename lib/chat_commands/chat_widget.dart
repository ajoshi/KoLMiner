import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kol_miner/SafeTextEditingController.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/utils.dart';

import 'chat_command.dart';

/// Edittext and button that lets the user send in chat commands
class ChatWidget extends StatefulWidget {
  ChatWidget(this.network, {Key? key}) : super(key: key);

  final KolNetwork network;

  // Lets the parent send in arbitrary chat commands
  final GlobalKey<ChatWidgetState> key = new GlobalKey();

  @override
  ChatWidgetState createState() => new ChatWidgetState();
}

class ChatWidgetState extends DisposableHostState<ChatWidget> {
  final chatInputTextController = SafeTextEditingController();
  late final ChatCommander _chatCommander;

  var isEnabled = true;
  var chatOutput = "";

  initState() {
    super.initState();
    _chatCommander = new ChatCommander(widget.network);
    chatInputTextController.register(this);
  }

  void sendChat(String text) {
    aj_print("Chat: $text");
    _setSendButtonEnabled(false);
    _chatCommander
        .executeChatCommand(text)
        .then((value) => _onChatResponse(value));
  }

  Future<String?> sendChatAndWait(String text) {
    aj_print("Chat: $text");
    _setSendButtonEnabled(false);
    return _chatCommander
        .executeChatCommand(text)
        .then((value) => _onChatResponse(value));
  }

  void _setChatOutput(String output) {
    setState(() {
      chatOutput = output.replaceAll("\\\"", "\"");
    });
  }

  String? _onChatResponse(String? response) {
    if (response != null) {
      _setChatOutput(response);
    }
    chatInputTextController.clear();
    _setSendButtonEnabled(true);
    return response;
  }

  void _setSendButtonEnabled(bool newValue) {
    setState(() {
      this.isEnabled = newValue;
    });
  }

  void _onSendChatSubmitted() {
    var chatRequest = chatInputTextController.text;
    sendChat(chatRequest);
  }

  /// We want the chat output to be hidden when there is no output
  Widget _buildChatOutputWidget() {
    if (chatOutput.isEmpty) {
      return new Container();
    }
    return new GestureDetector(
      onTap: () {
        _setChatOutput("");
      },
      child: Neumorphic(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Text(
            chatOutput,
            maxLines: 6,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mainColumn = Column(
      children: <Widget>[
        new TextField(
          controller: chatInputTextController,
          decoration: new InputDecoration(
            helperText: "Enter chat command here ",
            prefixText: "/",
            suffix: getPlatformButton(
              context,
              onPressed: isEnabled ? _onSendChatSubmitted : null,
              child: new Text(
                'Send',
              ),
            ),
          ),
          enabled: isEnabled,
          maxLength: 200,
          // hardcoded to what kol has
          keyboardType: TextInputType.text,
          onSubmitted: sendChat,
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
          child: _buildChatOutputWidget(),
        ),
      ],
    );
    return mainColumn;
  }
}
