import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';

enum NetworkResponseCode {
  SUCCESS,
  FAILURE,
  ROLLOVER,
  EXPIRED_HASH,
}

const String BASE_URL = "https://www.kingdomofloathing.com/";
const String LOGIN_POSTFIX = "login.php";
const String MAINT_POSTFIX = "maint.php";

class KolNetwork {
  String _username;
  String _password;
  String _awsAlb;
  String _phpsessid;
  bool _isLoggedIn = false;

  Future<NetworkResponseCode> login(
    String username,
    String password,
  ) async {
    _username = username;
    _password = password;

    print("logging in $_username");
    Uri firstLoginUrl = Uri.parse(BASE_URL + LOGIN_POSTFIX);
    var httpClient = new HttpClient();

    var loginPageRequest = await httpClient.getUrl(firstLoginUrl);
    var initialLoginPageResponse = await loginPageRequest.close();
    var realLoginPageUrl = initialLoginPageResponse.redirects[0].location;
    if (realLoginPageUrl != null &&
        !realLoginPageUrl.toString().startsWith("/")) {
      return NetworkResponseCode.ROLLOVER;
    }

    var loginUrl = BASE_URL + realLoginPageUrl.toString();
    loginUrl = loginUrl +
        "&loggingin=Yup."
        "&promo="
        "&mrstore="
        "&secure=1"
        "&loginname=$_username/q"
        "&password=$_password"
        "&submitbutton=Log+In";

    Uri tempUri = Uri.parse(loginUrl);

    var realLoginRequest = await httpClient.postUrl(tempUri);
    var realResponse = await realLoginRequest.close();

    updateCookies(realResponse.cookies);
    httpClient.close(force: false);

    if (_phpsessid == null) {
      return NetworkResponseCode.FAILURE;
    }

    _isLoggedIn = true;
    // tell the consumer we logged in
    return NetworkResponseCode.SUCCESS;
  }

  /// Call this with the server cookie reponse so we can update our cookies
  void updateCookies(List<Cookie> cookies) {
    for (var cook in cookies) {
      if (cook.name == "PHPSESSID") {
        _phpsessid = cook.value;
      }
      if (cook.name == "AWSALB") {
        _awsAlb = cook.value;
      }
    }
  }

  Future<NetworkResponse> makeRequest(String path) async {
    var httpClient = new HttpClient();
    var headerCookie = "PHPSESSID=$_phpsessid; AWSALB=$_awsAlb";
    var testRequest = await httpClient.getUrl(Uri.parse(BASE_URL + path));
    testRequest.headers
      ..add("PHPSESSID", _phpsessid)
      ..add("AWSALB", _awsAlb)
      ..add("cookie", headerCookie);

    var resp = await testRequest.close();

    if (resp.redirects != null && resp.redirects.isNotEmpty) {
      var redirectUrl = resp.redirects[0].location;
      if (redirectUrl != null &&
          redirectUrl.toString().contains(MAINT_POSTFIX)) {
        return NetworkResponse(NetworkResponseCode.ROLLOVER, "");
      }
      if (redirectUrl != null) {
        return NetworkResponse(NetworkResponseCode.EXPIRED_HASH, "");
      }
    }

    // login.php?invalid=1

    updateCookies(resp.cookies);

    //  TODO handle network failures while making request
    return new NetworkResponse(
        NetworkResponseCode.SUCCESS, await resp.transform(utf8.decoder).single);
  }

  bool isLoggedIn() {
    return _isLoggedIn;
  }

  void logout() {
    _isLoggedIn = false;
    _username = null;
    _password = null;
    _phpsessid = null;
    _awsAlb = null;
  }
}

class NetworkResponse {
  final NetworkResponseCode responseCode;
  final String response;

  NetworkResponse(this.responseCode, this.response);
}

// TODO  autosell https://www.kingdomofloathing.com/sellstuff_ugly.php POST maybe?
// might not be worth doing- we don't want to detract from web too much

// autosell: pwd=<pwdhash>&action=sell&mode=3&quantity=<quantity>&item8424=8424
// response: <body>
//<center><table  width=95%  cellspacing=0 cellpadding=0><tr><td style="color: white;"
// align=center bgcolor=blue><b>Results:</b></td></tr><tr><td style="padding: 5px;
// border: 1px solid blue;"><center><table><tr><td>
// <blockquote>You sell your 11 nuggets of 1,970 carat gold to a mechanic named Mike for 216,700 Meat.</blockquote>
// </td></tr></table></center></td></tr><tr><td height=4></td></tr></table>
// <form style='display: inline' name=f action=sellstuff_ugly.php method=post>
// <input type=hidden name=pwd value="shhh">
// <input type=hidden name=action value=sell><table  width=95%  cellspacing=0 cellpadding=0>
// <tr><td style="color: white;" align=center bgcolor=blue><b>Sell Stuff:</b></td></tr><tr>
// <td style="padding: 5px; border: 1px solid blue;"><center><table><tr><td><center>
//With selected:<br>
