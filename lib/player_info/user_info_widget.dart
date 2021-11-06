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

  /// Builds the  box that shows user data
  Widget _buildInfoBox() {
    if (_advs == -1) {
      return Text("");
    }
    return new Column(
      children: <Widget>[
        _buildHpMpBar("HP", Colors.red, _userInfoRequest.currentHp,
            _userInfoRequest.maxHp),
        _buildHpMpBar("MP", Colors.blue, _userInfoRequest.currentMp,
            _userInfoRequest.maxMp),
        new Text(
          "Full: ${_userInfoRequest.full}",
          style: Theme.of(context).textTheme.bodyText2,
        ),
        new Text(
          "Drunk: ${_userInfoRequest.drunk}",
          style: Theme.of(context).textTheme.bodyText2,
        ),
        new Text(
          "Meat: ${meatFormat.format(_userInfoRequest.meat)}",
          style: Theme.of(context).textTheme.bodyText2,
        ),
        new Text(
          "Advs: $_advs ",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        new Text(
          "$_advsUsed used",
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }

  /// Builds a progress bar that shows current+max HP and MP
  Widget _buildHpMpBar(String title, Color color, int value, int max) {
    return new Container(
      child: new Row(
        children: <Widget>[
          new Text("$title: $value/$max "),
          new Container(
            padding: EdgeInsets.only(left: 4.0),
            child: new LinearProgressIndicator(
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
    );
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
}
