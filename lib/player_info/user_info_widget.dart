import 'package:flutter/material.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/constants.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/player_info/user_info_requests.dart';

/// Shows basic user info: HP, MP, advs
class UserInfoWidget extends StatefulWidget {
  final KolNetwork network;

  // Lets the parent widget tell this one to update on command
  final GlobalKey<UserInfoState> key = new GlobalKey();

  UserInfoWidget(
    this.network, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new UserInfoState();
  }
}

class UserInfoState extends State<UserInfoWidget> {
  int _mp = -1;
  UserInfoRequest _userInfoRequest;

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

  /// Create a standard button showing the label that calls onPressed
  Widget _getButtonForAction(String label, VoidCallback onPressed) {
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
  Widget _buildInfoBox() {
    if (_userInfoRequest == null || _mp == -1) {
      return Text("");
    }
    return Text("HP: ${_userInfoRequest.currentHp} "
        "MP: $_mp "
        "advs: ${_userInfoRequest.advs} ");
  }

  /// Updates the UI with the new mp
  _updatePlayerData() {
    if (mounted) {
      setState(() => _mp = _userInfoRequest.currentMp);
    }
  }

  /// Makes a server request to update player data and updates UI when data comes back
  requestPlayerDataUpdate() {
    if (mounted) {
      _userInfoRequest.getPlayerData().then((_) => _updatePlayerData());
    }
  }
}
