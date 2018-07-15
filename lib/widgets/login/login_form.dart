import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kol_miner/kol_network.dart';

/// Widget that lets a user log in to KoL
class LoginForm extends StatefulWidget {
  LoginForm({Key key, this.network, this.onLogin}) : super(key: key);
  final VoidCallback onLogin;
  final KolNetwork network;
  @override
  _LoginFormState createState() => _LoginFormState();
}

// Define a corresponding State class. This class will hold the data related to
// our Form.
class _LoginFormState extends State<LoginForm> {
  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoggingIn = false;
  String messageToShow = "";

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    setState(() {
      isLoggingIn = true;
      var userName = userNameController.text;
      var password = passwordController.text;
      widget.network
          .login(
            userName,
            password,
          )
          .then((responseCode) => onLoginResponse(responseCode));
    });
  }

  Widget getSubmitButtonOrSpinner() {
    if (isLoggingIn) {
      return new CircularProgressIndicator();
    } else {
      return new RaisedButton(
        onPressed: _onLoginPressed,
        child: new Text('Log in'),
      );
    }
  }

  /// Called when the login code has hit the network and received a response
  void onLoginResponse(NetworkResponseCode responsecode) {
    switch (responsecode) {
      case NetworkResponseCode.SUCCESS:
        widget.onLogin();
        break;
      case NetworkResponseCode.ROLLOVER:
        onRollover();
        break;
      case NetworkResponseCode.FAILURE:
        loginFailed();
        break;
      default:
        loginFailed();
    }
    setState(() {
      isLoggingIn = false;
    });
  }

  /// Called when login has failed
  void loginFailed() {
    messageToShow = "Username or password is incorrect";
  }

  /// Called when login has failed due to Rollover (no choice but to wait)
  void onRollover() {
    messageToShow = "Rollover in progress. Try again later";
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new TextField(
          decoration: new InputDecoration(hintText: "Username"),
          style: TextStyle(fontSize: 20.0, color: Colors.black),
          enabled: !isLoggingIn,
          controller: userNameController,
        ),
        new TextField(
          obscureText: true,
          decoration: new InputDecoration(hintText: "Password"),
          style: TextStyle(fontSize: 20.0, color: Colors.black),
          enabled: !isLoggingIn,
          controller: passwordController,
        ),
        Padding(
            padding: const EdgeInsets.all(12.0),
            child: getSubmitButtonOrSpinner()),
        Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 5.0),
            child: Text(
              messageToShow,
              style: TextStyle(color: Colors.red),
            )),
      ],
    );
  }
}
