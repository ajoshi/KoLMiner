import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kol_miner/chat_commands/chat_command.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/lazy/lazy_requests.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/settings/settings.dart';

import '../utils.dart';

abstract class PreconfiguredActionsWidgetHost {
  void onPreConfiguredActionsWidgetRequestsStatusUpdate();
  void onPreConfiguredActionsWidgetError();
  void onPreConfiguredActionsWidgetChatRequest(String chat);
}

/// This widget allows users to eat/sleep/etc using buttons
/// The label and ids are modified in the Settings
class PreconfiguredActionsWidget extends StatelessWidget {
  final KolNetwork _network;

  final PreconfiguredActionsWidgetHost host;
  final Settings settings;
  late final LazyRequest lazyRequest;

  PreconfiguredActionsWidget(
    this.host,
    this._network,
    this.settings, {
    Key? key,
  }) : super(key: key) {
    lazyRequest = new LazyRequest(_network);
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          getRowOfActions(
              _WidgetRow('Consume', [
                _PreconfiguredActionModel(settings.food, _onEatClicked),
                _PreconfiguredActionModel(settings.booze, _onDrinkClicked)
              ]),
              context),
          getRowOfActions(
              new _WidgetRow('MP', [
                _PreconfiguredActionModel(settings.skill, _onResolveClicked),
                _PreconfiguredActionModel(
                    Setting("Visit nuns", "", ""), _onHealClicked),
              ]),
              context),
          getRowOfActions(
              new _WidgetRow('Chat', [
                _PreconfiguredActionModel(settings.chat1, _onChatClicked),
                _PreconfiguredActionModel(settings.chat2, _onChatClicked)
              ]),
              context),
          getRowOfActions(
              new _WidgetRow('', [
                _PreconfiguredActionModel(settings.chat3, _onChatClicked),
                _PreconfiguredActionModel(settings.chat4, _onChatClicked),
              ]),
              context),
        ],
      ),
    );
  }

  Widget getRowOfActions(_WidgetRow rowData, BuildContext context) {
    var row = rowData.buttons
        .map((buttonModel) => _getButtonForAction(buttonModel, context))
        .toList(growable: true);
    // dirty, but ensures we don't show useless labels
    if (rowData.buttons
        .every((element) => element.setting?.name.isEmpty != false)) {
      return Container();
    }
    var label = ConstrainedBox(
      child: Text(rowData.title,
          style: Theme.of(context).textTheme.caption,
          overflow: TextOverflow.ellipsis),
      constraints: const BoxConstraints(minWidth: 60),
    );
    row.insert(0, label);
    return Padding(
      padding: EdgeInsets.all(1.0),
      child: Row(
        children: row,
      ),
    );
  }

  Widget _getButtonForAction(
      _PreconfiguredActionModel model, BuildContext context) {
    if (model.setting == null || model.setting!.name.isEmpty)
      return Container();
    return Padding(
        padding: EdgeInsets.all(5.0),
        child: getKolButton(
          context,
          onPressed: () {
            model.clickAction.call(model.setting!.data);
          },
          child: new Text(
            model.setting!.name,
          ),
        ));
  }

  _requestStatusUpdate() {
    host.onPreConfiguredActionsWidgetRequestsStatusUpdate();
  }

  _onChatClicked(String command) {
    host.onPreConfiguredActionsWidgetChatRequest(command);
  }

  _onDrinkClicked(String id) {
    lazyRequest.requestDrink(id).then((code) => _requestStatusUpdate());
  }

  _onEatClicked(String id) {
    lazyRequest.requestFood(id).then((code) {
      _requestStatusUpdate();
    });
  }

  _onResolveClicked(String skillId) {
    lazyRequest.requestSkill(skillId).then((code) {
      {
        _requestStatusUpdate();
      }
    });
  }

  _onHealClicked(String irrelevant) {
    lazyRequest.requestNunHealing().then((code) => _requestStatusUpdate());
  }
}

// data class that defines a row of widgets
class _WidgetRow {
  String title;
  List<_PreconfiguredActionModel> buttons;

  _WidgetRow(this.title, this.buttons);
}

class _PreconfiguredActionModel {
  final Setting? setting;
  final Function(String value) clickAction;

  _PreconfiguredActionModel(this.setting, this.clickAction);
}
