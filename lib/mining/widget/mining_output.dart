import 'package:flutter/material.dart';
import 'package:kol_miner/historical_mining_data/saved_miner_data.dart';

/// Shows the result of mining. This is where we show the user how many
/// advs were spent and how much money was made
class MiningOutput extends StatelessWidget {
  MiningOutput(this.goldCount, this.advsUsed);

  final int goldCount;
  final int advsUsed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        new Text(
          'Gold mined: $goldCount',
          style: Theme.of(context).textTheme.display1,
        ),
        new Text(
          'Meat: ${getMeatAsString()}',
          style: Theme.of(context).textTheme.headline,
        ),
        new Text(
          'MPA: ${getMpaAsString()}',
          style: Theme.of(context).textTheme.body2,
        ),
      ],
    );
  }

  /// Calculates the MPA of this session
  String getMpaAsString() {
    var sessionData = new MiningSessionData(goldCount, advsUsed, 0);
    return sessionData.getMpaAsString();
  }

  /// Calculates the MPA of this session
  String getMeatAsString() {
    var sessionData = new MiningSessionData(goldCount, advsUsed, 0);
    return sessionData.getMeatAsString();
  }
}
