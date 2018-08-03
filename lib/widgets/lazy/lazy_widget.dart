import 'package:flutter/material.dart';
import 'package:kol_miner/kol_network.dart';
import 'package:kol_miner/lazy_requests.dart';
import 'package:kol_miner/widgets/platformui.dart';

/// This widget is for use by lazy people who are a burden to humanity
class LazyUselessPersonWidget extends StatefulWidget {
  final KolNetwork network;
  static LazyRequest lazyRequest;

  LazyUselessPersonWidget(this.network, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LazyPersonState();
  }
}

class LazyPersonState extends State<LazyUselessPersonWidget> {
  String _mp = "";

  @override
  Widget build(BuildContext context) {
    if (LazyUselessPersonWidget.lazyRequest == null) {
      LazyUselessPersonWidget.lazyRequest = LazyRequest(widget.network);
      _updatePlayerData();
    }
    return new Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          buildInfoBox(),
          getButtonForAction('Resolve to spend MP', _onResolveClicked), // cast resol
          getButtonForAction('Healz', _onHealClicked), // Heals from nunnery
          getButtonForAction('Eat', _onEatClicked), // Eat sleazy hi mein
          getButtonForAction('Drink', _onDrinkClicked), // Eat sleazy hi mein
        ],
      ),
    );
  }

  Widget getButtonForAction(String label, VoidCallback onPressed) {
    return
      Padding(padding: EdgeInsets.all(2.0), child: getPlatformButton(
      context,
      onPressed: onPressed,
      child: new Text(
        label,
      ),
      color: Theme.of(context).primaryColor,
    )
      );
  }

  Widget buildInfoBox() {
    return Text(
        "HP: ${LazyUselessPersonWidget.lazyRequest.currentHp} "
            "MP: $_mp "
            "advs: ${LazyUselessPersonWidget.lazyRequest.advs} "
            "ode: ${LazyUselessPersonWidget.lazyRequest.odeTurns} "
            "milk: ${LazyUselessPersonWidget.lazyRequest.currentMilkTurns}");
  }

  _updatePlayerData() {
    LazyUselessPersonWidget.lazyRequest
        .getPlayerData()
        .then((_) => setState(() => _mp = LazyUselessPersonWidget.lazyRequest.currentMp));
  }

  _onDrinkClicked() {
    LazyUselessPersonWidget.lazyRequest.requestPerfectDrink().then((code) => _updatePlayerData());
  }

  _onEatClicked() {
    LazyUselessPersonWidget.lazyRequest.requestEatSleazyHimein().then((code) => _updatePlayerData());
  }

  _onResolveClicked() {
    LazyUselessPersonWidget.lazyRequest.requestResolutionSummon().then((code) => _updatePlayerData());
  }

  _onHealClicked() {
    LazyUselessPersonWidget.lazyRequest.requestNunHealing().then((code) => _updatePlayerData());
  }
}
