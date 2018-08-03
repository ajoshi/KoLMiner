import 'dart:async';
import 'dart:convert';
import 'dart:io';

class KolNetwork {
  static const String BASE_URL = "https://www.kingdomofloathing.com/";

  static const String LOGIN_POSTFIX = "login.php";
  static const String MAINT_POSTFIX = "maint.php";

  static const String APP_NAME = "ajoshiMiningApp";
  static const String FOR_APP_NAME = "for=$APP_NAME";

  String _username;
  String _password;
  String _awsAlb;
  String _phpsessid;
  bool _isLoggedIn = false;
  String _charPwd = "";
  String _playerId;
  String _pwdHash;

  bool isLoggedIn() {
    return _isLoggedIn;
  }

  Future<NetworkResponseCode> login(
    String username,
    String password,
  ) async {
    _username = username;
    _password = password;
    try {
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
          "&submitbutton=Log+In&$FOR_APP_NAME";

      Uri tempUri = Uri.parse(loginUrl);

      var realLoginRequest = await httpClient.postUrl(tempUri);
      var realResponse = await realLoginRequest.close();

      updateCookies(realResponse.cookies);
      httpClient.close(force: false);

      if (_phpsessid == null) {
        return NetworkResponseCode.FAILURE;
      }

      // get the charpwd as well so we can make arbitrary requests
      await getPlayerData();

      _isLoggedIn = true;
      // tell the consumer we logged in
      return NetworkResponseCode.SUCCESS;
    } on IOException catch (_) {
      // not sure what we can do here.
      return NetworkResponseCode.FAILURE;
    }
  }

  /// Logging in doesn't get us all the player data, but hitting the charpane does
  /// So we check the charpane for the pwdhash (and get the player id just in case)
  Future<bool> getPlayerData() async {
    var response = await makeRequest("charpane.php?$FOR_APP_NAME");
    if(response.responseCode == NetworkResponseCode.SUCCESS) {
      var charInfoHtml = response.response;
      _playerId = _getBetween2Strings(charInfoHtml, "playerid = ", ";");
      _pwdHash = _getBetween2Strings(charInfoHtml, "pwdhash = \"", "\"");

      _charPwd = _getBetween2Strings(charInfoHtml, "setCookie('charpwd', winW, ", ",");
      return true;
    }
    return false;
  }

  /// Given a bigString, finds the substring between the two passed in Strings
  String _getBetween2Strings(String bigString, String startString, String endString) {
    var startIndex = bigString.indexOf(startString);
    if (startIndex != -1) {
      startIndex = startIndex + startString.length;
      var endIndex = bigString.indexOf(endString, startIndex);
      return bigString.substring(startIndex, endIndex);
    }
    return "";
  }

  /// not really logging out- just null out fields so they can't be used
  void logout() {
    _isLoggedIn = false;
    _username = null;
    _password = null;
    _phpsessid = null;
    _awsAlb = null;
    _charPwd = null;
    _pwdHash = null;
  }

  /// Make a network request for the given url and the urlParams. Params do not
  /// start with & or ?. Eg. "which=1&b=2"
  /// The 'for' param is added automatically.
  /// Performs GET requests by default, but can also perform PUTs
  Future<NetworkResponse> makeRequestWithQueryParams(String baseUrl, String params, {HttpMethod method}) async {
    return makeRequest("$baseUrl?$FOR_APP_NAME&pwd=$_pwdHash&$params", method: method);
  }

  /// Make a network request for a given url. Defaults to GET, but can make PUT requests as well
  Future<NetworkResponse> makeRequest(String url, {HttpMethod method = HttpMethod.GET}) async {
    try {
      var httpClient = new HttpClient();
      var headerCookie = "PHPSESSID=$_phpsessid; AWSALB=$_awsAlb; charPwd=$_charPwd";
      HttpClientRequest httpRequest;
      if(method == HttpMethod.POST) {
        // post if requested
        httpRequest = await httpClient.postUrl(Uri.parse(BASE_URL + url));
      } else {
        // else default is get
        httpRequest = await httpClient.getUrl(Uri.parse(BASE_URL + url));
      }
      httpRequest.headers
        ..add("PHPSESSID", _phpsessid)
        ..add("AWSALB", _awsAlb)
        ..add("cookie", headerCookie);

      var resp = await httpRequest.close();

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
      try {
        return new NetworkResponse(NetworkResponseCode.SUCCESS,
            await resp
                .transform(utf8.decoder)
                .single);
      } catch(_) {
        // couldn't parse the response. Send back empty string?
        return new NetworkResponse(NetworkResponseCode.SUCCESS, "");
      }
    } on IOException catch (_) {
      return NetworkResponse(NetworkResponseCode.FAILURE, "");
    }
  }

  /// Call this with the server cookie response so we can update our cookies
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
}

class NetworkResponse {
  final NetworkResponseCode responseCode;
  final String response;

  NetworkResponse(this.responseCode, this.response);
}

enum NetworkResponseCode {
  SUCCESS,
  FAILURE,
  ROLLOVER,
  EXPIRED_HASH,
}

enum HttpMethod {
  // I only care about these two
  GET,
  POST,
}
