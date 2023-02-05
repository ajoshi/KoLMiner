import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kol_miner/login/login_page.dart';
import 'package:kol_miner/mining/widget/mining_page.dart';
import 'package:kol_miner/network/kol_network.dart';

import 'constants.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  static const String APP_API_NAME = "ajoshiMiningApp";
  static const String APP_NAME = "70s Gold Extractor";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if(USE_NEUMORPHISM) {
      return NeumorphicApp(
        debugShowCheckedModeBanner: false,
        title: '70s Gold Extractor',
        color: Colors.amber,
        themeMode: ThemeMode.light,
        theme: NeumorphicThemeData(

          accentColor: Colors.amberAccent,
          baseColor: Color(0xFFdedede),
          lightSource: LightSource.topLeft,
          depth: 3,
        ),
        darkTheme: NeumorphicThemeData(
          baseColor: Color(0xFF3E3E3E),
          lightSource: LightSource.topLeft,
          accentColor: Colors.amberAccent,
          depth: 3,
        ),
        home: Screen(new KolNetwork(APP_API_NAME), APP_NAME),
      );
    } else {
      return new MaterialApp(
        title: APP_NAME,
        theme: new ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: new Screen(new KolNetwork(APP_API_NAME), APP_NAME),
      );
    }

  }
}

class Screen extends StatefulWidget {
  final KolNetwork network;
  final String title;

  const Screen(this.network, this.title, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new ScreenState();
  }
}

class ScreenState extends State<Screen> {
  void onLogin() {
    _navigateToMiningScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    return new LoginPage(widget.network, onLogin, title: widget.title);
  }

  void _navigateToMiningScreen(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MiningPage(
                widget.network,
                title: 'Mine for gold',
              )),
    );

    // Show an error dialog if an error result was returned
    if (result != null) {
      showDialog(
        context: this.context,
        builder: (buildContext) =>
            getErrorDialog(buildContext, result.errorMessage),
      );
    }
  }

  /// Dialog to show when an error occurs
  Widget getErrorDialog(BuildContext buildContext, String message) {
    return new AlertDialog(
      content: new Text(
        message,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }
}
