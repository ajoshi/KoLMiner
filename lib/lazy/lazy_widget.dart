import 'package:flutter/material.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/constants.dart';
import 'package:kol_miner/historical_mining_data/saved_miner_data.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/lazy/lazy_requests.dart';

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

  initState() {
    super.initState();
    lazyRequest = LazyRequest(widget.network);
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
            getButtonForAction('Resolve to spend MP', _onResolveClicked),
            // cast resol
            getButtonForAction('Healz', _onHealClicked),
            // Heals from nunnery
            getButtonForAction('Eat', _onEatClicked),
            // Eat sleazy hi mein
            getButtonForAction('Drink', _onDrinkClicked), // Eat sleazy hi mein
            // Clears saved MPA, etc to make impact of algo changes easier to calculate
            getButtonForAction('Clear historical data', _onClearDataClicked), // Clear saved mining data
          ],
        ),
      );
    }
    // not allowed to show lazy widget, so show empty widget
    return new Container();
  }

  /// Create a standard button showing the label that calls onPressed
  Widget getButtonForAction(String label, VoidCallback onPressed) {
    return Padding(
        padding: EdgeInsets.all(2.0),
        child: getPlatformButton(
          context,
          onPressed: onPressed,
          child: new Text(
            label,
          ),
          color: Theme.of(context).primaryColor,
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


  _onClearDataClicked() {
    clearMiningData();
  }

  _onEatClicked() {
    lazyRequest
        .requestEatSleazyHimein()
        .then((code) => requestPlayerDataUpdate());
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
