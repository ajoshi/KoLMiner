import 'package:flutter/material.dart';
import 'package:kol_miner/historical_mining_data/saved_miner_data.dart';

/// Shows the historical mining data for this app
/// Shows nothing if there is no data
class HistoricalMineWidget extends StatelessWidget {
  final MiningSessionData? data;
  final double textSize;
  HistoricalMineWidget(this.data, {this.textSize = 12.0});

  String _getSemanitcsLabel() {
    if (data == null) return "";
    return "Mined ${data?.goldcount} gold over ${data?.advCount} adventures. ${data?.getMpaAsString()} MPA";
  }

  @override
  Widget build(BuildContext context) {
    if (data == null || data?.advCount == 0) {
      // probably shouldn't send back a padding of 1 for no reason
      return new Padding(padding: const EdgeInsets.all(4.0));
    }
    // build the actual widget here
    return new Column(
      children: <Widget>[
        new Text(
          data.toString(),
          semanticsLabel: _getSemanitcsLabel(),
          style: TextStyle(fontSize: textSize),
        ),
      ],
    );
  }
}
