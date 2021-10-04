import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/utils.dart';

import 'chat_command.dart';

/// Edittext and button that lets the user send in chat commands
class ChatWidget extends StatefulWidget {
  const ChatWidget(this.network, {Key? key}) : super(key: key);

  final KolNetwork network;

  @override
  ChatWidgetState createState() => new ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  final chatInputTextController = TextEditingController();
  late final ChatCommander _chatCommander;

  var isEnabled = true;

  initState() {
    super.initState();
    _chatCommander = new ChatCommander(widget.network);
  }

  void _sendChat(String text) {
    aj_print("Chat: $text");
    _setSendButtonEnabled(false);
    _chatCommander.executeChatcommand(text).then((value) => _onChatResponse());
  }

  void _onChatResponse() {
    chatInputTextController.clear();
    _setSendButtonEnabled(true);
  }

  void _setSendButtonEnabled(bool newValue) {
    setState(() {
      this.isEnabled = newValue;
    });
  }

  void _onSendChatSubmitted() {
    var chatRequest = chatInputTextController.text;
    _sendChat(chatRequest);
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
          keyboardType: TextInputType.text,
          onSubmitted: _sendChat,
        ),
      ],
    );
    return mainColumn;
  }
}
