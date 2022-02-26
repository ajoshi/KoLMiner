import 'package:flutter/material.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/player_info/user_info_requests.dart';
import 'package:intl/intl.dart';

/// Shows basic user info: HP, MP, advs
class UserInfoWidget extends StatefulWidget {
  final KolNetwork network;

  // Lets the parent widget tell this one to update on command
  final GlobalKey<UserInfoState> key = new GlobalKey();

  UserInfoWidget(
    this.network, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new UserInfoState();
  }
}

class UserInfoState extends State<UserInfoWidget> {
  // init to -1 and not 0 because 0 is a valid state
  int _advs = -1;
  int _advsUsed = 0;
  late final UserInfoRequest _userInfoRequest;
  final meatFormat = new NumberFormat.decimalPattern();

  initState() {
    super.initState();
    _userInfoRequest = UserInfoRequest(widget.network);
    requestPlayerDataUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          _buildInfoBox(),
        ],
      ),
    );
  }

  int _getColorInt(int maxColor, int maxValue, int currentValue) {
    var ratio = (currentValue / maxValue);
    if (ratio > 1)
      ratio =
          1; // we can go over the limit, but the color should just stay *at* the limit
    var color = (ratio * maxColor).toInt();
    return color;
  }

  /// Builds the  box that shows user data
  Widget _buildInfoBox() {
    if (_advs == -1) {
      return Text("");
    }
    return Semantics(
        label: "Character info.",
        child: new Column(
          children: <Widget>[
            _buildHpMpBar("HP", Colors.red, _userInfoRequest.currentHp,
                _userInfoRequest.maxHp),
            _buildHpMpBar("MP", Colors.blue, _userInfoRequest.currentMp,
                _userInfoRequest.maxMp),
            new Text(
              "Fullness: ${_userInfoRequest.full}",
              semanticsLabel: "${_userInfoRequest.full} Fullness.",
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  color: Color.fromARGB(
                      255, 0, _getColorInt(128, 20, _userInfoRequest.full), 0)),
            ),
            new Text(
              "Drunkeness: ${_userInfoRequest.drunk}",
              semanticsLabel: "${_userInfoRequest.drunk} Drunkeness.",
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  color: Color.fromARGB(255,
                      _getColorInt(255, 20, _userInfoRequest.drunk), 0, 0)),
            ),
            new Text(
              "Ode: ${_userInfoRequest.odeTurns}",
              semanticsLabel: "${_userInfoRequest.odeTurns} turns of ode",
              style: Theme.of(context).textTheme.bodyText2,
            ),
            new Text(
              "Meat: ${meatFormat.format(_userInfoRequest.meat)}",
              semanticsLabel:
                  "${meatFormat.format(_userInfoRequest.meat)} Meat.",
              style: Theme.of(context).textTheme.bodyText2,
            ),
            new Text(
              "Advs: $_advs",
              semanticsLabel: "$_advs adventures left",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            new Text(
              "$_advsUsed used",
              semanticsLabel: "$_advsUsed used.",
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ));
  }

  /// Builds a progress bar that shows current+max HP and MP
  Widget _buildHpMpBar(String title, Color color, int value, int max) {
    return Semantics(
        child: new Container(
      child: new Row(
        children: <Widget>[
          ExcludeSemantics(
            child: new Text("$title: $value/$max "),
          ),
          new Container(
            padding: EdgeInsets.only(left: 4.0),
            child: new LinearProgressIndicator(
              semanticsLabel: title,
              value: value / max,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: Color.fromRGBO(200, 200, 200, .3),
            ),
            width: 130.0,
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      padding: EdgeInsets.only(top: 2.0, bottom: 2.0, left: 25.0, right: 25.0),
    ));
  }

  /// Updates the UI with the new mp
  _updatePlayerData() {
    if (mounted) {
      setState(() => _advs = _userInfoRequest.advs);
    }
  }

  /// Decrements the adventure count by the passed in number. Defaults to 1.
  /// We need this to update the advcount without making excess network calls
  adventureUsed({int count = 1}) {
    setState(() {
      _advs = _advs - count;
      _advsUsed = _advsUsed + count;
    });
  }

  /// Makes a server request to update player data and updates UI when data comes back
  requestPlayerDataUpdate() {
    if (mounted) {
      _userInfoRequest.getPlayerData().first.then((_) => _updatePlayerData());
    }
  }

  /// Makes a server request to update player data and updates UI when data comes back
  Future<UserInfoRequest?> requestPlayerDataUpdateAndReturnValue() {
    if (mounted) {
      return _userInfoRequest.getPlayerData().first.then((_) {
        _updatePlayerData();
        return _userInfoRequest;
      });
    }
    return Future.value(null);
  }
}
