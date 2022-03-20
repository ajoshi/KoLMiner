import 'dart:async';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

class KolAccount {
  final String username;
  final String password;

  KolAccount(this.username, this.password);

  String toString() {
    return username + " " + password;
  }

  bool operator ==(other) {
    if (other is KolAccount) {
      return (username == other.username) && (password == other.password);
    } else
      return false;
  }

  int get hashCode {
    return username.length + password.length;
  }
}

class KolAccountManager {
  static const KEY_USERNAMES = "Kol_stored_usernames";
  static const KEY_PASSWORDS = "Kol_stored_passwords";

  SharedPreferences? prefs = null;

  /// gets all the kol accounts saved on disk
  Future<List<KolAccount>> getAllAccounts() async {
    var accounts = <KolAccount>[];
    await _getSharedPref();
    // god, this is laughably bad
    List<String>? usernames = prefs?.getStringList(KEY_USERNAMES);
    List<String>? passwords = prefs?.getStringList(KEY_PASSWORDS);
    if (usernames == null || passwords == null) {
      aj_print("no accounts on disk");
      return accounts;
    }

    int userCount = min(usernames.length, passwords.length);
    // join the 2 username+password arrays to make a KolAccount array
    for (int c = 0; c < userCount; c++) {
      KolAccount account = KolAccount(usernames[c].trim(), passwords[c]);
//      aj_print(account);
      accounts.add(account);
    }
    //  aj_print("getAllAccs: $userCount");
    return accounts;
  }

  /// saves one kol account to disk
  saveAccount(KolAccount account) async {
    await _getSharedPref();
    List<KolAccount> accounts = await getAllAccounts();
    //   aj_print("saving " + account.username + " " + account.password);
    if (accounts.contains(account)) {
      accounts.remove(account);
    }
    accounts.insert(0, account);
    saveAccounts(accounts);
  }

  /// saves all the passed in accounts to disk
  saveAccounts(List<KolAccount> accounts) async {
    var usernames = <String>[];
    var passwords = <String>[];
    for (var account in accounts) {
      usernames.add(account.username.trim());
      passwords.add(account.password);
    }
    await _getSharedPref();
    prefs?.setStringList(KEY_USERNAMES, usernames);
    prefs?.setStringList(KEY_PASSWORDS, passwords);
  }

  Future<SharedPreferences?> _getSharedPref() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
    return prefs;
  }
}
