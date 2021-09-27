import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/constants.dart';
import 'package:kol_miner/historical_mining_data/saved_miner_data.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/lazy/lazy_requests.dart';
import 'package:kol_miner/outfit/outfit_manager.dart';

/// This widget is for use by lazy people who are a burden to humanity
class LazyUselessPersonWidget extends StatefulWidget {
  final KolNetwork network;

  // Lets the parent widget tell this one to update on command
  final GlobalKey<LazyPersonState> key = new GlobalKey();

  LazyUselessPersonWidget(
    this.network, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new LazyPersonState();
  }
}

class LazyPersonState extends State<LazyUselessPersonWidget> {
  int _milkTurns = -1;
  LazyRequest lazyRequest;
  OutfitManager _outfitManager;

  initState() {
    super.initState();
    lazyRequest = LazyRequest(widget.network);
    _outfitManager = OutfitManager(widget.network);
    requestPlayerDataUpdate();
  }

  @override
  Widget build(BuildContext context) {
    if (DEBUG) {
      return new Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Column(
          children: <Widget>[
            buildInfoBox(),
            getRowOfActions(LazyWidgetRow('HP/MP', [LazyWidgetButtonModel('Resolve',_onResolveClicked), LazyWidgetButtonModel('Heals', _onHealClicked)])),
            getRowOfActions(new LazyWidgetRow('Consume', [LazyWidgetButtonModel('Eat',_onEatClicked), LazyWidgetButtonModel('Drink', _onDrinkClicked)])),
            getRowOfActions(new LazyWidgetRow('Equip',  [LazyWidgetButtonModel('RO',_onEquipOutfitRoll), LazyWidgetButtonModel('Mining', _equipVolc), LazyWidgetButtonModel('Velvet', _onEquipOutfitVelv)])),
            _getButtonForAction(LazyWidgetButtonModel('Collect coin', _onCollectCoinClicked)), // Put on Velvet, then hit coin endpoints
          ],
        ),
      );
    }
    // not allowed to show lazy widget, so show empty widget
    return new Container();
  }

  Widget getRowOfActions(LazyWidgetRow rowData) {
    var row = rowData.buttons.map((buttonModel) => _getButtonForAction(buttonModel)).toList(growable: true);
    var label = ConstrainedBox(
        child: Text(rowData.title, style: Theme.of(context).textTheme.caption),
        constraints: const BoxConstraints(minWidth: 60),
    );
    row.insert(0, label);
    return Padding(padding: EdgeInsets.all(1.0),
    child: Row(
      children: row,
    ),);
  }

  Widget _getButtonForAction(LazyWidgetButtonModel model) {
    return Padding(
        padding: EdgeInsets.all(5.0),
        child: getPlatformButton(
          context,
          onPressed: model.clickAction,
          child: new Text(
            model.label,
          ),
          color: Theme.of(context).primaryColorDark,
        ));
  }

  /// Builds the  box that shows user data
  Widget buildInfoBox() {
    if (lazyRequest == null || _milkTurns == -1) {
      return Text("RUNNING IN DEBUG MODE");
    }
    return Text("RUNNING IN DEBUG MODE"
        "\n MP: ${lazyRequest.currentMp}"
        "\node: ${lazyRequest.odeTurns} "
        "\nmilk: ${lazyRequest.currentMilkTurns}");
  }

  /// Updates the UI with the new mp
  _updatePlayerData() {
    if (mounted) {
      setState(() => _milkTurns = lazyRequest.currentMilkTurns);
    }
  }

  /// Makes a server request to update player data and updates UI when data comes back
  requestPlayerDataUpdate() {
    if (mounted) {
      lazyRequest.getPlayerData().then((_) => _updatePlayerData());
    }
  }

  _onDrinkClicked() {
    lazyRequest.requestPerfectDrink().then((code) => requestPlayerDataUpdate());
  }

  _equipVolc() {
    _outfitManager.equipOutfitUsingName("volc");
  }

  _onEquipOutfitRoll() {
    _outfitManager.equipOutfitUsingName("roll");
  }

  _onEquipOutfitVelv() {
    _outfitManager.equipOutfitUsingName("velv");
  }

  _onCollectCoinClicked() {
    _outfitManager.equipOutfitUsingName("velv").then((_) => lazyRequest.visitDisco());
  }

  _onEatClicked() {
    lazyRequest.requestMilkUse().then((_) =>
        lazyRequest.requestEatSleazyHimein().then((code) =>
            requestPlayerDataUpdate()));
  }

  _onResolveClicked() {
    lazyRequest
        .requestResolutionSummon()
        .then((code) => requestPlayerDataUpdate());
  }

  _onHealClicked() {
    lazyRequest.requestNunHealing().then((code) => requestPlayerDataUpdate());
  }
}

// data class that defines a row of widgets
class LazyWidgetRow {
  String title;
  List<LazyWidgetButtonModel> buttons;

  LazyWidgetRow(this.title, this.buttons);
}

class LazyWidgetButtonModel {
  final String label;
  final VoidCallback clickAction;

  LazyWidgetButtonModel(this.label, this.clickAction);
}