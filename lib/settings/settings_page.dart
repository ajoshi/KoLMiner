import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/settings/settings.dart';
import 'package:kol_miner/utils.dart';

import '../SafeTextEditingController.dart';
import 'setting_text_input_widget.dart';

/// This page shows Settings
class SettingsPage extends StatefulWidget {
  SettingsPage({this.title = "Settings", Key? key}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends DisposableHostState<SettingsPage> {
  Settings? _settings;

  // Stick all controllers in a map so we don't recreate them every time build happens
  final Map<String, SafeTextEditingController> _textEditingControllerMap =
      new HashMap();

  void _setSettings(Settings settings) {
    setState(() {
      _settings = settings;
    });
  }

  SafeTextEditingController _getEditingControllerForKey(
      String key, String defaultText) {
    var existingController = _textEditingControllerMap[key];
    if (existingController != null) return existingController;

    var newController = new SafeTextEditingController().register(this);
    newController.text = defaultText;
    _textEditingControllerMap[key] = newController;
    return newController;
  }

  Widget _actionIdInputRow(Setting? setting, String hintText) {
    return _inputRow(
        setting,
        hintText,
        TextInputType.numberWithOptions(signed: false, decimal: false),
        " ID",
        "ID");
  }

  Widget _chatInputRow(
      Setting? setting, String hintText, String semanticsLabel) {
    return _inputRow(
        setting, hintText, TextInputType.text, " command", semanticsLabel);
  }

  Widget _inputRow(
      Setting? setting,
      String hintText,
      TextInputType secondInputType,
      String secondInputHintSuffix,
      String semanticsLabel) {
    if (setting == null) {
      return Container();
    }
    TextEditingController nameController = _getEditingControllerForKey(
        setting.sharedprefKey + "Name", setting.name);
    TextEditingController valueController = _getEditingControllerForKey(
        setting.sharedprefKey + "Value", setting.data);
    return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MergeSemantics(
            child: ConstrainedBox(
              child: new Text(hintText,
                  semanticsLabel: semanticsLabel,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.overline),
              constraints: const BoxConstraints(minWidth: 40),
            ),
          ),
          new SettingTextInputField("Button name", TextInputType.text, (value) {
            setting.name = value;
          }, nameController, 10),
          new SettingTextInputField(
              hintText + secondInputHintSuffix, secondInputType, (value) {
            setting.data = value;
          }, valueController, 30),
        ]);
  }

  /// This is needed because focus change listener doesn't get fired right when user taps on a button
  /// So we artificially move focus, then wait 10 ms (fml) and then invoke the exit callback
  void _onSaveClicked() {
    // TODO: Use a higher scoped focusnode instead
    // https://flutter.dev/docs/development/ui/advanced/focus#unfocusing
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 10), () {})
        .then((value) => _saveSettingsAndExit());
  }

  void _saveSettingsAndExit() {
    saveNewSettings(_settings);
    aj_print("$_settings");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      getSettings().then((settings) {
        _setSettings(settings);
      });
    }

    var loginPage = new Padding(
      padding: const EdgeInsets.all(5.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: new Text(
                  "Save commonly used food/booze/skills as buttons for easier use",
                  style: Theme.of(context).textTheme.bodyText2),
            ),
          ),
          _actionIdInputRow(_settings?.food, "Food"),
          _actionIdInputRow(_settings?.booze, "Booze"),
          _actionIdInputRow(_settings?.skill, "Skill"),
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 4.0, top: 12.0, right: 4.0, bottom: 4.0),
              child: new Text(
                  'Save up to three commonly used chat commands without the slash. (eg. \"outfit roll\") for easier use',
                  style: Theme.of(context).textTheme.bodyText2),
            ),
          ),
          _chatInputRow(_settings?.chat1, "Cmd 1", "Chat command 1"),
          _chatInputRow(_settings?.chat2, "Cmd 2", "Chat command 2"),
          _chatInputRow(_settings?.chat3, "Cmd 3", "Chat command 3"),
          _chatInputRow(_settings?.chat4, "Cmd 4", "Chat command 4"),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: getKolButton(
                context,
                onPressed: _onSaveClicked,
                child: new Text(
                  "Save",
                ),
              ),
            ),
          ),
        ],
      ),
    );

    ListView scrollableBody = new ListView(
      children: <Widget>[
        loginPage,
      ],
    );

    Scaffold scaffold = new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
      ),
      body: scrollableBody,
    );
    return scaffold;
  }
}
