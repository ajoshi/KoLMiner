import 'package:flutter/material.dart';
import 'package:kol_miner/kol_network.dart';
import 'package:kol_miner/widgets/login/login_page.dart';
import 'package:kol_miner/widgets/mining/mining_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'KoL Miner',
      theme: new ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: new Screen(),
    );
  }
}

class Screen extends StatefulWidget {
  final KolNetwork _network = new KolNetwork();
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
                title: 'Mining',
                network: widget._network,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new LoginPage(
        title: 'KoL Miner', network: widget._network, onLogin: onLogin);
  }
}
