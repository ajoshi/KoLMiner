import 'package:flutter/material.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/historical_mining_data/saved_miner_data.dart';
import 'package:kol_miner/historical_mining_data/historical_mine_data_widget.dart';
import 'package:kol_miner/login/login_form.dart';

/// This is the first page a user sees. It allows the user to log in and calls
/// the onLogin callback on success
class LoginPage extends StatefulWidget {
  LoginPage(this.network, this.onLogin, {this.title = "", Key? key})
      : super(key: key);

  final VoidCallback onLogin;

  final String title;
  final KolNetwork network;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  MiningSessionData? miningData = null;

  void _onLoggedIn() {
    setState(() {
      widget.onLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    getMiningData().then((data) => setState(() {
          miningData = data;
        }));
    var loginPage = new Padding(
      padding: const EdgeInsets.all(10.0),
      child: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Text('Log in to KoL',
                  style: Theme.of(context).textTheme.headline4),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: new Text(
                'Log in with your Kingdom of Loathing login to become a miner. Go back in time to become a minor.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: new LoginForm(
                widget.network,
                _onLoggedIn,
              ),
            ),
            HistoricalMineWidget(
              miningData,
            ),
          ],
        ),
      ),
    );

    ListView scrollableBody = new ListView(
      children: <Widget>[
        loginPage,
      ],
    );

    Scaffold scaffold = new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: scrollableBody,
    );
    return scaffold;
  }
}
