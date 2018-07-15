import 'package:flutter/material.dart';
import 'package:kol_miner/kol_network.dart';
import 'package:kol_miner/widgets/login/login_form.dart';

/// This is the first page a user sees. It allows the user to log in and calls
/// the onLogin callback on success
class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title, this.network, this.onLogin})
      : super(key: key);

  final VoidCallback onLogin;

  final String title;
  final KolNetwork network;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _onLoggedIn() {
    setState(() {
      widget.onLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    var loginPage = new Padding(
      padding: const EdgeInsets.all(10.0),
      child: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text('Log in to KoL',
                  style: Theme.of(context).textTheme.display1),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Text(
                'Log in with your Kingdom of Loathing login to become a miner. Go back in time to become a minor.',
              ),
            ),
            new LoginForm(
              onLogin: _onLoggedIn,
              network: widget.network,
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
