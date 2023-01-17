import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kol_miner/accounts/kol_account.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/extensions.dart';
import 'package:kol_miner/login/autocomplete_username_input.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';

/// Widget that lets a user log in to KoL
class LoginForm extends StatefulWidget {
  LoginForm(this.network, this.onLogin, {Key? key, this.enabled = true})
      : super(key: key);
  final VoidCallback onLogin;
  final KolNetwork network;
  final bool enabled;

  @override
  _LoginFormState createState() => _LoginFormState();
}

// Define a corresponding State class. This class will hold the data related to
// our Form.
class _LoginFormState extends State<LoginForm>
    implements AutoCompleteUsernameInputHost {
  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final passwordController = TextEditingController();

  // current value of the Autocomplete text field
  String _usernameTextViewValue = "";

  final KolAccountManager accountManager = KolAccountManager();

  // List of all the accounts that have logged in before
  List<KolAccount>? accounts = null;

  // List of all the usernames. Used by AutoComplete
  List<String>? usernameSuggestions = null;

  // toggled by user to allow password to be hidden/shown in UI- UX improvement to avoid typos
  bool _obscurePassword = true;

  bool isLoggingIn = false;

  // Message to show when login attempt has failed
  String messageToShow = "";
  String nonErrorMessageToShow = "";

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    setState(() {
      FocusScope.of(context).requestFocus(new FocusNode());
      isLoggingIn = true;
      var password = passwordController.text;
      var newAccount = KolAccount(_usernameTextViewValue, password);
      aj_print("logging in with " + newAccount.toString());
      if (newAccount.password.length > 2) {
        String displayPass = "";
        if (!_obscurePassword) {
          displayPass = "[${newAccount.password}]";
        }

        nonErrorMessageToShow =
            "Logging in: [${newAccount.username}] $displayPass";
      } else {
        nonErrorMessageToShow = "You probably need a password to log in";
      }
      widget.network
          .login(
            newAccount.username,
            newAccount.password,
          )
          .then((responseCode) => onLoginResponse(responseCode, newAccount));
    });
  }

  Widget getSubmitButtonOrSpinner() {
    if (_isEnabled()) {
      //https://pub.dev/packages/flutter_neumorphic

      return getPlatformButton(
        context,
        onPressed: widget.enabled ? _onLoginPressed : null,
        child: new Text('Log in'),
      );
    } else {
      return new CircularProgressIndicator();
      /*
           return  new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          new Text("Logging in as $")
          new CircularProgressIndicator(),
        ],
      );
      // return new CircularProgressIndicator();
    }
       */
    }
  }

  /// Called when the login code has hit the network and received a response
  void onLoginResponse(
      NetworkResponseCode responsecode, KolAccount newAccount) {
    nonErrorMessageToShow = "";
    messageToShow = "";
    switch (responsecode) {
      case NetworkResponseCode.SUCCESS:
        accountManager.saveAccount(newAccount);
        accounts = null;
        _updateAccountsList();
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

  void _onAccountListLoaded(List<KolAccount> newAccounts) {
    accounts = newAccounts;
    aj_print("new list of accounts: ");
    newAccounts.forEach((element) {
      aj_print(element);
    });
    var suggestions =
        newAccounts.map((acct) => acct.username).toList(growable: false);

    setState(() {
      usernameSuggestions = suggestions;
      isLoggingIn = false;
      // if (accounts.length > 0) {
      // maybe we can autologin if there is just one account? But then how will
      // people add second accounts?
      //  userNameController.text = accounts[0].username;
      //  passwordController.text = accounts[0].password;
      // }
    });
  }

  void _onUsernameFieldUpdated(String newText) {
    _usernameTextViewValue = newText;
    if (newText.isEmpty) {
      // clear password field because username is empty
      passwordController.text = "";
    }
  }

  /// Nullable
  /// Gets a password if the given username is stored. Else returns null
  String? _getPasswordForUsername(String username) {
    return accounts
        ?.firstWhereOrNull((acct) => username == acct.username)
        ?.password;
  }

  void _onSubmitImeAction(String newText) {
    // ignore?
    aj_print("Text submitted: " + newText);
  }

  void _onUsernameSelected(String username) {
    _usernameTextViewValue = username;
    var passwordForText = _getPasswordForUsername(username);
    if (passwordForText != null) {
      passwordController.text = passwordForText;
      // try to log in
      _onLoginPressed();
    }
  }

  void _updateAccountsList() {
    accountManager
        .getAllAccounts()
        .then((accounts) => _onAccountListLoaded(accounts));
  }

  void _toggleShowPassword() {
    aj_print(
        "Toggling show password from $_obscurePassword to ${!_obscurePassword}");
    _obscurePassword = !_obscurePassword;
  }

  @override
  Widget build(BuildContext context) {
    if (accounts == null) {
      _updateAccountsList();
    }
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        AutoCompleteUsernameInput(usernameSuggestions, this),
        new TextField(
          obscureText: _obscurePassword,
          decoration: new InputDecoration(
              hintText: "Password",
              suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _toggleShowPassword();
                    });
                  },
                  icon: Icon(
                      _obscurePassword ? Icons.remove_red_eye : Icons.lock))),
          enabled: _isEnabled(),
          controller: passwordController,
          onSubmitted: (value) => _onLoginPressed(),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 12.0, 5.0, 5.0),
            child: getSubmitButtonOrSpinner()),
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: GestureDetector(
            child: new Text(
              'Create new account or reset password',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.indigoAccent,
              ),
            ),
            onTap: () => _launchKolInBrowser(),
          ),
        ),
        getDisplayedMessage(),
      ],
    );
  }

  Widget getDisplayedMessage() {
    return messageToShow.isEmpty
        ? getNonErrorMessage()
        : Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
            child: Text(
              messageToShow,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          );
  }

  Widget getNonErrorMessage() {
    return nonErrorMessageToShow.isEmpty
        ? new Container()
        : Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
            child: Text(
              nonErrorMessageToShow,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          );
  }

  bool _isEnabled() {
    return !isLoggingIn && widget.enabled;
  }

  void _launchKolInBrowser() async {
    // https://pub.dev/packages/url_launcher#configuration
    // TODO might need additional fixing if iOS needs this
    const url = "https://www.kingdomofloathing.com/";
    if (await canLaunch(url)) {
      await launch(
        url,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  onUsernameSelected(String username) {
    _onUsernameSelected(username);
  }

  @override
  onTextChanged(String newText) {
    _onUsernameFieldUpdated(newText);
  }
}
