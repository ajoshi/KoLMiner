import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kol_miner/accounts/kol_account.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/extensions.dart';
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
class _LoginFormState extends State<LoginForm> {
  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final passwordController = TextEditingController();

  // Normal edittext unless the entered string is a subset of known username
  // if subset, it shows a dropdown. Selecting dropdown populates password field
  late AutoCompleteTextField usernameAutoCompleteView;
  GlobalKey<AutoCompleteTextFieldState<String>> keyForAutocomplete =
      new GlobalKey();

  // current value of the Autocomplete text field
  String _usernameTextViewValue = "";

  final KolAccountManager accountManager = KolAccountManager();

  // List of all the accounts that have logged in before
  List<KolAccount>? accounts = null;

  // List of all the usernames. Used by AutoComplete
  List<String>? usernameSuggestions = null;

  bool isLoggingIn = false;

  // Message to show when login attempt has failed
  String messageToShow = "";

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
      widget.network
          .login(
            newAccount.username,
            newAccount.password,
          )
          .then((responseCode) => onLoginResponse(responseCode, newAccount));
      usernameSuggestions = <String>[];
    });
  }

  Widget getSubmitButtonOrSpinner() {
    if (_isEnabled()) {
      return getPlatformButton(
        context,
        onPressed: widget.enabled ? _onLoginPressed : null,
        child: new Text('Log in'),
      );
    } else {
      return new CircularProgressIndicator();
    }
  }

  /// Called when the login code has hit the network and received a response
  void onLoginResponse(
      NetworkResponseCode responsecode, KolAccount newAccount) {
    messageToShow = "";
    switch (responsecode) {
      case NetworkResponseCode.SUCCESS:
        accountManager.saveAccount(newAccount);
        accounts = null;
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
      _updateUsernameSuggestions();
      isLoggingIn = false;
      // if (accounts.length > 0) {
      // maybe we can autologin if there is just one account? But then how will
      // people add second accounts?
      //  userNameController.text = accounts[0].username;
      //  passwordController.text = accounts[0].password;
      // }
    });
  }

  void _updateUsernameSuggestions() {
    if (usernameSuggestions?.isNotEmpty == true) {
      usernameAutoCompleteView.updateSuggestions(usernameSuggestions);
    }
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

  @override
  Widget build(BuildContext context) {
    if (accounts == null) {
      accountManager
          .getAllAccounts()
          .then((accounts) => _onAccountListLoaded(accounts));
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

    new OutlineInputBorder(
        gapPadding: 0.0, borderRadius: new BorderRadius.circular(20.0));

    usernameAutoCompleteView = AutoCompleteTextField<String>(
      itemSubmitted: _onUsernameSelected,
      textChanged: _onUsernameFieldUpdated,
      textSubmitted: _onSubmitImeAction,
      clearOnSubmit: false,
      key: keyForAutocomplete,
      decoration: new InputDecoration(
          hintText: "Username", suffixIcon: new Icon(Icons.person)),
      itemBuilder: (context, item) {
        return new Padding(padding: EdgeInsets.all(8.0), child: new Text(item));
      },
      itemSorter: (a, b) {
        return a.compareTo(b);
      },
      itemFilter: (item, query) {
        return item.toLowerCase().startsWith(query.toLowerCase());
      },
      suggestions: usernameSuggestions,
      minLength: 0,
    );

    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        usernameSuggestions == null ? Container() : usernameAutoCompleteView,
        new TextField(
          obscureText: true,
          decoration: new InputDecoration(
            hintText: "Password",
            suffixIcon: new Icon(Icons.lock),
          ),
//          style: TextStyle(fontSize: 20.0, color: Colors.black),
          enabled: _isEnabled(),
          controller: passwordController,
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
        messageToShow.isEmpty
            ? new Container()
            : Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
                child: Text(
                  messageToShow,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
      ],
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
}
