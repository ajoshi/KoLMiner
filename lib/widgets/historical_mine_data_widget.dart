import 'package:flutter/material.dart';
import 'package:kol_miner/saved_miner_data.dart';

/// Shows the historical mining data for this app
/// Shows nothing if there is no data
class HistoricalMineWidget extends StatelessWidget {
  final MiningSessionData data;
  HistoricalMineWidget(this.data);

  @override
  Widget build(BuildContext context) {
    if (data == null || data.advCount == 0) {
      // probably shouldn't send back a padding of 1 for no reason
      return new Padding(padding: EdgeInsets.all(1.0));
    }
    // build the actual widget here
    return new Column(
      children: <Widget>[
        new Text(
            "Saved you ${data.advCount} adventures with ${data.getMpaAsString()} MPA"),
      ],
    );
  }
}
