import 'package:flutter/material.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/login/login_page.dart';
import 'package:kol_miner/mining/widget/mining_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  static const String APP_NAME = "ajoshiMiningApp";
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'KoL Miner',
      theme: new ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: new Screen(new KolNetwork(APP_NAME)),
    );
  }
}

class Screen extends StatefulWidget {
  final KolNetwork network;

  const Screen( this.network, {Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return new ScreenState();
  }
}

class ScreenState extends State<Screen> {
  void onLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MiningPage(
                title: 'Mine for gold',
                network: widget.network,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new LoginPage(
        title: 'KoL Miner', network: widget.network, onLogin: onLogin);
  }
}
