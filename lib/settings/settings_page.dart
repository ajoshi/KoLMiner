import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/dialog/TextDialog.dart';
import 'package:kol_miner/settings/settings.dart';
import 'package:kol_miner/utils.dart';

import '../SafeTextEditingController.dart';
import 'setting_text_input_widget.dart';
import 'settings_descriptions.dart';

/// This page shows Settings
class SettingsPage extends StatefulWidget {
  /// Characters that a single chat command can have. Allows chaining more easily
  static const MAX_CHAT_COMMAND_LENGTH = 140;

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

  Widget _actionIdInputRow(
      Setting? setting, String hintText, String explanation) {
    return _inputRow(
        setting,
        hintText,
        TextInputType.numberWithOptions(signed: false, decimal: false),
        " ID",
        "ID",
        explanation: explanation);
  }

  Widget _chatInputRow(
      Setting? setting, String hintText, String semanticsLabel) {
    return _inputRow(
        setting, hintText, TextInputType.text, " command", semanticsLabel);
  }

  Widget _checkboxRow(
      BooleanSetting? setting, String label, String semanticsLabel,
      {BoxConstraints boxConstraints = const BoxConstraints(minWidth: 40),
      String? explanation}) {
    if (setting == null) {
      return Container();
    }
    var infoWidget;
    if (explanation != null) {
      infoWidget = infoIcon(label, explanation);
    } else {
      infoWidget = Container();
    }
    return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          getCheckbox(
            context,
            initialValue: setting.data,
            onchanged: (value) {
              setState(() {
                setting.data = value ?? false;
              });
            },
          ),
          infoWidget,
          Padding(
            padding: EdgeInsets.only(right: 2.0),
          ),
          new Text(label,
              maxLines: 2,
              softWrap: true,
              semanticsLabel: semanticsLabel,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.overline),
        ]);
  }

  Widget infoIcon(String label, String explanation) {
    return InkWell(
      child: Icon(
        Icons.info_outline,
        color: Colors.black38,
        size: 19.0,
        semanticLabel: 'Explain in detail',
      ),
      onTap: () => textDialog(context, label, explanation),
    );
  }

  Widget _getMultilineTextInput(TextboxSetting? setting, String hintText) {
    if(setting == null) {
      return Container();
    }

    TextEditingController scriptController = _getEditingControllerForKey(
        setting.sharedprefKey, setting.getAsString());
    return Row(  mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
        new SettingTextInputField(
        hintText, TextInputType.multiline, (value) {
          print(value);
          setting.saveData(value);
        }, scriptController, 500, maxLines: 6, minLines: 2,)
        ]
    );
  }

  Widget _inputRow(
      Setting? setting,
      String label,
      TextInputType? secondInputType,
      String secondInputHintSuffix,
      String semanticsLabel,
      {BoxConstraints boxConstraints = const BoxConstraints(minWidth: 40),
      String hint = "Button name",
      String? explanation}) {
    if (setting == null) {
      return Container();
    }
    TextEditingController nameController = _getEditingControllerForKey(
        setting.sharedprefKey + "Name", setting.name);
    TextEditingController valueController = _getEditingControllerForKey(
        setting.sharedprefKey + "Value", setting.data);

    Widget icon;
    if (explanation != null) {
      icon = Padding(
        padding: EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
        child: infoIcon(label, explanation),
      );
    } else {
      icon = Container();
    }

    return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          icon,
          MergeSemantics(
            child: ConstrainedBox(
              child: new Text(label,
                  semanticsLabel: semanticsLabel,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.overline),
              constraints: boxConstraints,
            ),
          ),
          new SettingTextInputField(hint, TextInputType.text, (value) {
            setting.name = value;
          }, nameController, 10),
          if (secondInputType != null)
            new SettingTextInputField(
                label + secondInputHintSuffix, secondInputType, (value) {
              setting.data = value;
            }, valueController, SettingsPage.MAX_CHAT_COMMAND_LENGTH),
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

    var page = new Padding(
      padding: const EdgeInsets.all(5.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: new Text(
                  "Enter the name of your volcano mining outfit and one to equip after mining is done. The app will equip them as needed",
                  style: Theme.of(context).textTheme.bodyText2),
            ),
          ),
          _inputRow(_settings?.volcOutfitName, "Mining outfit", null, "",
              "Volcano Mining outfit name",
              boxConstraints: const BoxConstraints(minWidth: 100),
              hint: "Mining outfit name",
              explanation: VOLC_OUTFIT_NAME_DESCRIPTION),
          _inputRow(_settings?.roOutfitName, "Post-mining outfit", null, "",
              "Post-mining outfit name",
              boxConstraints: const BoxConstraints(minWidth: 100),
              hint: "RO outfit name (rollover outfit?)",
              explanation: POST_MINING_OUTFIT_NAME_DESCRIPTION),
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: new Text(
                  "Save commonly used food/booze/skills as buttons for easier use",
                  style: Theme.of(context).textTheme.bodyText2),
            ),
          ),
          _actionIdInputRow(_settings?.food, "Food", FOOD_DESCRIPTION),
          _actionIdInputRow(_settings?.booze, "Booze", BOOZE_DESCRIPTION),
          _actionIdInputRow(_settings?.skill, "Skill", SKILL_DESCRIPTION),
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 4.0, top: 12.0, right: 4.0, bottom: 4.0),
              child: new Row(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 9.0),
                    child: infoIcon("Chat commands", CHAT_CMD_DESC),
                  ),
                  new Text(
                      'Save up to six commonly used chat commands for easier use',
                      style: Theme.of(context).textTheme.bodyText2),
                ],
              ),
            ),
          ),
          _chatInputRow(
              _settings?.chatCommands?.elementAt(0), "Cmd 1", "Chat command 1"),
          _chatInputRow(
              _settings?.chatCommands?.elementAt(1), "Cmd 2", "Chat command 2"),
          _chatInputRow(
              _settings?.chatCommands?.elementAt(2), "Cmd 3", "Chat command 3"),
          _chatInputRow(
              _settings?.chatCommands?.elementAt(3), "Cmd 4", "Chat command 4"),
          _chatInputRow(
              _settings?.chatCommands?.elementAt(4), "Cmd 5", "Chat command 5"),
          _chatInputRow(
              _settings?.chatCommands?.elementAt(5), "Cmd 6", "Chat command 6"),
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: new Text(
                  "The app will autoheal at the nuns if your HP drops too low. Autoheal is disabled if this is empty.",
                  style: Theme.of(context).textTheme.bodyText2),
            ),
          ),
          _inputRow(_settings?.autohealMinHp, "Min HP for nuns", null, "",
              "Min HP for nuns",
              boxConstraints: const BoxConstraints(minWidth: 100),
              hint: "",
              explanation: MIN_HP_DESC),
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: new Text(
                  "The app will autocast the default skill above if MP goes above a certain limit. Autocasting is disabled if this empty.",
                  style: Theme.of(context).textTheme.bodyText2),
            ),
          ),
          _inputRow(_settings?.autocastMaxMp, "Max MP", null, "", "Max MP",
              boxConstraints: const BoxConstraints(minWidth: 100),
              hint: "",
              explanation: MAX_MP_DESCRIPTION),
          _checkboxRow(
              _settings?.shouldAutosellGold, "Autosell gold", "Autosell gold",
              explanation: AUTOSELL_GOLD_DESC),

          /// TODO enable this when neumorphism support is done
          // _checkboxRow(_settings?.shouldUseNeumorphism, "Use fancy new UI",
          //     "UI setting. Just keep this off"),

          _getMultilineTextInput(_settings?.autoconsumeList, "App will autoconsume this shit"),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: getKolButton(
                context,
                onPressed: _onSaveClicked,
                child: new Text(
                  "Save",
                  style: new TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    ListView scrollableBody = new ListView(
      children: <Widget>[
        page,
      ],
    );
    Scaffold scaffold = new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: _onSaveClicked,
            icon: const Icon(Icons.save),
            tooltip: "Save settings",
          ),
        ],
        title: new Text(widget.title),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
      ),
      body: scrollableBody,
    );
    return scaffold;
  }
}
