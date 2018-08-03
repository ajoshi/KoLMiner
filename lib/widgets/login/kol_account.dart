import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class KolAccount {
  final String username;
  final String password;

  KolAccount(this.username, this.password);

  String toString() {
    return username + password;
  }

  bool operator == (other) {
    return (username == other.username) && (password == other.password);
  }

  int get hashCode {
    return username.length + password.length;
  }
}

class KolAccountManager {
  static const KEY_USERNAMES = "Kol_stored_usernames";
  static const KEY_PASSWORDS = "Kol_stored_passwords";

  SharedPreferences prefs;

  /// gets all the kol accounts saved on disk
  Future<List<KolAccount>> getAllAccounts() async {
    List<KolAccount> accounts = List();
    await _getSharedPref();
    // god, this is laughably bad
    List<String> usernames = prefs.getStringList(KEY_USERNAMES);
    List<String> passwords = prefs.getStringList(KEY_PASSWORDS);
    if(usernames == null || passwords == null) {
      print("no accounts on disk");
      return accounts;
    }

    int userCount = usernames.length;
    // join the 2 username+password arrays to make a KolAccount array
    for(int c = 0; c < userCount; c++) {
      KolAccount account = KolAccount(usernames[c], passwords[c]);
//      print(account);
      accounts.add(account);
    }
  //  print("getAllAccs: $userCount");
    return accounts;
  }

  /// saves one kol account to disk
  saveAccount(KolAccount account) async {
     await _getSharedPref();
     List<KolAccount> accounts = await getAllAccounts();
     //   print("saving " + account.username + " " + account.password);
     if (!accounts.contains(account)) {
       accounts.add(account);
     }
     saveAccounts(accounts);
  }

  /// saves all the passed in accounts to disk
  saveAccounts(List<KolAccount> accounts) async {
    List<String> usernames = List();
    List<String> passwords = List();
    for(var account in accounts) {
      usernames.add(account.username);
      passwords.add(account.password);
    }
    await _getSharedPref();
    prefs.setStringList(KEY_USERNAMES, usernames);
    prefs.setStringList(KEY_PASSWORDS, passwords);
  }

  Future<SharedPreferences> _getSharedPref() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
    return prefs;
  }
}
