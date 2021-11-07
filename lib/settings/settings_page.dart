import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/historical_mining_data/saved_miner_data.dart';
import 'package:kol_miner/historical_mining_data/historical_mine_data_widget.dart';
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

class _SettingsPageState extends SafeTextEditingControllerHost<SettingsPage> {
  Settings? _settings = null;

  void _setSettings(Settings settings) {
    setState(() {
      _settings = settings;
    });
  }

  void _onSavePressed() {
    //    saveNewSettings(_settings);
    aj_print("${_settings?.food?.name}");
    aj_print("${_settings?.food?.data}");
  }

  Widget _inputRow(Setting? setting, String hintText) {
    TextEditingController nameController = new SafeTextEditingController().register(this);
    TextEditingController valueController = new SafeTextEditingController().register(this);
    return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Text(hintText, style: Theme.of(context).textTheme.overline),
          new SettingTextInputField("Button name", TextInputType.text, (value) {
            setting?.name = value;
          },
              nameController
          ),
          new SettingTextInputField(hintText + " id",
              TextInputType.numberWithOptions(signed: false, decimal: false),
              (value) {
            setting?.data = value;
          },
              valueController),
        ]);
  }

  Widget _chatInputRow(Setting? setting, String hintText) {
    TextEditingController nameController = new SafeTextEditingController().register(this);
    TextEditingController valueController = new SafeTextEditingController().register(this);
    return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Text(hintText, style: Theme.of(context).textTheme.overline),
          new SettingTextInputField("Button name", TextInputType.text, (value) {
            setting?.name = value;
          },
              nameController),
          new SettingTextInputField(hintText + " command", TextInputType.text, (value) {
            setting?.data = value;
          },
              valueController),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      getSettings().then((settings) {
        _setSettings(settings);
      });
    }

    var loginPage = new Padding(
      padding: const EdgeInsets.all(10.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: new Text(
                "Save commonly used food/booze/skills as buttons for easier use",
                //https://www.kingdomofloathing.com/inv_eat.php?pwd=f22d1ea8c998551f6ce74de08c89172e&which=1&whichitem=5483
                style: Theme.of(context).textTheme.bodyText2),
          ),
          _inputRow(_settings?.food, "Food"),
          _inputRow(_settings?.booze, "Booze"),
          _inputRow(_settings?.skill, "Skill"),
          Padding(
            padding: const EdgeInsets.only(
                left: 4.0, top: 12.0, right: 4.0, bottom: 4.0),
            child: new Text(
                'Save up to three commonly used chat commands without the slash (eg. \"outfit roll\") for easier use',
                style: Theme.of(context).textTheme.bodyText2),
          ),
          _chatInputRow(_settings?.chat1, "Cmd 1"),
          _chatInputRow(_settings?.chat2, "Cmd 2"),
          _chatInputRow(_settings?.chat3, "Cmd 3"),
          Center(
            child: getKolButton(
              context,
              onPressed: _onSavePressed,
              child: new Text(
                "Save",
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
