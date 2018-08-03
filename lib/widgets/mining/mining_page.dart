import 'package:flutter/material.dart';
import 'package:kol_miner/kol_network.dart';
import 'package:kol_miner/miner.dart';
import 'package:kol_miner/saved_miner_data.dart';
import 'package:kol_miner/widgets/mining/mining_input.dart';
import 'package:kol_miner/widgets/mining/mining_output.dart';

/// This is the screen where the mining happens
class MiningPage extends StatefulWidget {
  MiningPage({Key key, this.title, this.network}) : super(key: key);

  final String title;
  final KolNetwork network;

  @override
  _MiningPage createState() => new _MiningPage();
}

class _MiningPage extends State<MiningPage> {
  int _goldCounter = 0;
  int _advsUsed = 0;

  int _goldCounterForSession = 0;
  int _advSpentCounterForSession = 0;

  bool didEncounterError = false;

  Miner miner;
  bool enableButton = true;
  final myController = TextEditingController();

  void _onMineClicked() {
    getMiningData().then((value) => print(value.toString()));
    var advsToMine = int.tryParse(myController.text);
    if (advsToMine == null) {
      // we couldn't figure out how many advs to mine for, so just stop
      return;
    }
    _goldCounterForSession = 0;
    _advSpentCounterForSession = 0;
    setState(() {
      // disable the mining ui
      enableButton = false;
    });
    mineNtimes(advsToMine);
  }

  /// Mines the specified number of times. Will stop if an error occurs.
  void mineNtimes(int n) async {
    var startTime = new DateTime.now().millisecondsSinceEpoch;
    while (n > 0 && !didEncounterError) {
      n--;
      var response = await miner.mineNextSquare();
      onMineResponse(response);
    }
    var endTime = new DateTime.now().millisecondsSinceEpoch;
    // save this new data so we know how much we've mined since installation
    saveNewMiningData(new MiningSessionData(_goldCounterForSession,
        _advSpentCounterForSession, endTime - startTime));
    // update ui with good news: we've mined and now we can mine again (maybe)
    setState(() {
      enableButton = true;
    });
  }

  /// Checks the response of every mine operation and updates UI accordingly
  void onMineResponse(MiningResponse response) {
    if (response.isSuccess()) {
      if (response.foundGold) {
        miner.autoSellGold();
        _goldCounter++;
        _goldCounterForSession++;
      }

      setState(() {
        _advsUsed++;
        _advSpentCounterForSession++;
      });
    } else {
      onError(response);
    }
  }

  /// What to do when we hit an error: back out to login page
  void onError(MiningResponse response) {
    // on error: stop mining, pop the backstack to go back to login and show error dialog
    didEncounterError = true;
    Navigator.pop(context);
    widget.network.logout();
    String message = getErrorMessageForMiningResponse(response);
    showDialog(
      context: this.context,
      builder: (buildContext) => getErrorDialog(buildContext,
          message),
    );
  }

  /// Dialog to show when an error occurs
  Widget getErrorDialog(BuildContext buildContext, String message) {
    return new AlertDialog(
      content: new Text(
        message,
        style: Theme.of(context).textTheme.subhead,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (miner == null) {
      miner = new Miner(network: widget.network);
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: getCenteredListView(),
//      floatingActionButton: enableButton? new FloatingActionButton(
//        onPressed: _onMineClicked,
//        tooltip: 'Mine',
//        child: new Icon(Icons.add),
//      ): null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// DOES NOT NEED TO BE IN THIS CLASS
  /// Gets human readable string for mining errors. Will be seen by end user
  String getErrorMessageForMiningResponse(MiningResponse response) {
    String message;
    switch (response.miningResponseCode) {
      case MiningResponseCode.FAILURE:
        message =
        'Unable to mine (0 HP? No hot res? Dirty bugbears in your interwebz?) '
            'Log in via your browser, fix the issue, and log in again';
        break;
      case MiningResponseCode.NO_ACCESS:
        message =
        'Unable to access the mine. Make sure you have used the '
            'charter/ticket and are wearing the mining outfit';
        break;
      case MiningResponseCode.SUCCESS:
      // success shouldn't show up in onError
        message =
        'Uhhh.... tell me if you see this message because it\'s a bug';
        break;
    }
    return message;
  }

  /// DOES NOT NEED TO BE IN THIS CLASS
  /// Gets human readable string for network errors. Will be seen by end user
  String getErrorMessageForNetworkResponse(NetworkResponseCode responseCode) {
    String message;
    switch (responseCode) {
      case NetworkResponseCode.ROLLOVER:
        message = 'Rollover is in progress. Try again when servers are back up';
        break;
      case NetworkResponseCode.EXPIRED_HASH:
        message = 'Did you log in via the browser while mining? Don\'t do that';
        break;
      case NetworkResponseCode.FAILURE:
        message =
        'Network call failed. Are you offline? Bad wifi? Get better wifi';
        break;
      case NetworkResponseCode.SUCCESS:
      // success shouldn't show up in onError
        message =
        'Uhhh.... tell me if you see this message because it\'s a bug';
    }
    return message;
  }

  /// Content to show to the user
  Widget getContent() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Text(
            "Mining is love. Mining is life.",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(1.0),
        ),
        new MiningOutput(_goldCounter, _advsUsed),
        new MiningInputFields(myController, enableButton, _onMineClicked),
      ],
    );
  }

  /// Gives us a padded and centered listview full of content
  Widget getCenteredListView() {
    return new ListView(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Center(
            child: getContent(),
          ),
        ),
      ],
    );
  }
}
