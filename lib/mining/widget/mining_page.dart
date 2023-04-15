import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kol_miner/SafeTextEditingController.dart';
import 'package:kol_miner/chat_commands/chat_widget.dart';
import 'package:kol_miner/common_widgets/platformui.dart';
import 'package:kol_miner/historical_mining_data/saved_miner_data.dart';
import 'package:kol_miner/lazy/lazy_widget.dart';
import 'package:kol_miner/lazy/preconfigured_actions_widget.dart';
import 'package:kol_miner/mining/miner.dart';
import 'package:kol_miner/mining/widget/mining_input.dart';
import 'package:kol_miner/mining/widget/mining_output.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:kol_miner/player_info/user_info_widget.dart';
import 'package:kol_miner/settings/settings.dart';
import 'package:kol_miner/settings/settings_page.dart';

import '../../Batching.dart';
import '../../constants.dart';
import '../../utils.dart';

/// This is the screen where the mining happens
class MiningPage extends StatefulWidget {
  const MiningPage(this.network, {Key? key, this.title = ""}) : super(key: key);

  final String title;
  final KolNetwork network;

  @override
  MiningPageState createState() => new MiningPageState();
}

class MiningPageState extends DisposableHostState<MiningPage>
    implements PreconfiguredActionsWidgetHost {
  // waiting until all mining is complete to refresh is ridic
  // This allows us to refresh the status ever n (10) turns for a somewhat responsive ui
  static const _REFRESH_STATUS_EVERY_N_TURNS = 10;
  final miningInputTextController = SafeTextEditingController();

  late final Miner miner;

  late final LazyUselessPersonWidget _lazyPersonWidget;
  late final UserInfoWidget _userInfoWidget;
  late final ChatWidget _chatWidget;
  late final StatusRequestBatcher _requestBatcher;

  int _goldCounter = 0;
  int _advsUsed = 0;

  // a 'session' is from mining started to mining done. A user can have multiple
  // mine sessions without exiting the app by tapping the mine button a lot
  int _goldCounterForSession = 0;
  int _advSpentCounterForSession = 0;

  bool didEncounterError = false;
  bool enableButton = true;

  Settings? settings;

  void _onMineClicked() {
    getMiningData().then((value) => aj_print(value.toString()));
    var advsToMine = int.tryParse(miningInputTextController.text);
    if (advsToMine == null) {
      // we couldn't figure out how many advs to mine for, so just stop
      return;
    }
    FocusScope.of(context).requestFocus(new FocusNode());
    // reset session counters since tapping button resets the session
    _goldCounterForSession = 0;
    _advSpentCounterForSession = 0;
    setState(() {
      // disable the mining ui
      enableButton = false;
    });
    mineNtimes(advsToMine);
  }

  /// Mines the specified number of times. Will stop if an error occurs.
  void mineNtimes(int n) async {
    String? volcOutfit = settings?.volcOutfitName?.name;
    if (volcOutfit != null && volcOutfit.isNotEmpty) {
      await _chatWidget.key.currentState?.sendChatAndWait("outfit $volcOutfit");
    }
    var startTime = new DateTime.now().millisecondsSinceEpoch;
    var counter = 0;
    while (counter < n && !didEncounterError) {
      if (!mounted) {
        // stop mining if the user has left the mining page
        return;
      }
      counter++;
      if (counter % _REFRESH_STATUS_EVERY_N_TURNS == 0) {
        _refreshPlayerData();
      }
      var response = await miner.mineNextSquare(
          shouldAutosellGold: settings?.shouldAutosellGold.data ?? true);
      onMineResponse(response);
    }
    var endTime = new DateTime.now().millisecondsSinceEpoch;
    // save this new data so we know how much we've mined since installation
    saveNewMiningData(new MiningSessionData(_goldCounterForSession,
        _advSpentCounterForSession, endTime - startTime));
    _refreshPlayerData();

    await _chatWidget.key.currentState?.sendChatAndWait("outfit roll");
    // update ui with good news: we've mined and now we can mine again (maybe)
    setState(() {
      enableButton = true;
    });
  }

  /// Checks the response of every mine operation and updates UI accordingly
  void onMineResponse(MiningResponse response) {
    if (response.isSuccess()) {
      if (response.foundGold) {
        _goldCounter++;
        _goldCounterForSession++;
      }
      if (mounted) {
        setState(() {
          _userInfoWidget.key.currentState?.adventureUsed();
          _advsUsed++;
          _advSpentCounterForSession++;
        });
      }
    } else {
      onError(response);
    }
  }

  /// What to do when we hit an error: back out to login page
  void onError(MiningResponse response) {
    String? roOutfit = settings?.roOutfitName?.name;
    if (roOutfit != null && roOutfit.isNotEmpty) {
      _chatWidget.key.currentState?.sendChat("outfit $roOutfit");
    }
    // on error: stop mining, pop the backstack to go back to login and show error dialog
    didEncounterError = true;
    String message = getErrorMessageForMiningResponse(response);
    Navigator.pop(context, MiningPageError(message));
    widget.network.logout();
  }

  late StreamSubscription<bool> batchedRequestSubscription;

  initState() {
    super.initState();
    miningInputTextController.register(this);
    _requestBatcher = new StatusRequestBatcher(_refreshPlayerData);
    _requestBatcher.register(this);
    _lazyPersonWidget = new LazyUselessPersonWidget(widget.network);
    _userInfoWidget = new UserInfoWidget(widget.network);
    _chatWidget = new ChatWidget(widget.network);
    _fetchSettings();
    miner = new Miner(widget.network);
  }

  void _batchedRefreshPlayerData() {
    _requestBatcher.addRequest();
  }

  void _refreshPlayerData() {
    _userInfoWidget.key.currentState
        ?.requestPlayerDataUpdateAndReturnValue()
        .then((request) {
      // This is a really bad way of hooking into "mp too high/hp too low" checks
      if (request != null) {
        if (settings?.autocastMaxMp?.name.isNotEmpty == true) {
          if (request.currentMp > (int.parse(settings!.autocastMaxMp!.name)) &&
              settings?.skill?.data != null) {
            aj_print("MP too high");
            _lazyPersonWidget.key.currentState?.lazyRequest
                .requestSkill(settings!.skill!.data);
          }
        }
        if (settings?.autohealMinHp?.name.isNotEmpty == true) {
          if (request.currentHp < (int.parse(settings!.autohealMinHp!.name))) {
            aj_print("HP too low");
            _lazyPersonWidget.key.currentState?.lazyRequest.requestNunHealing();
          }
        }
      }
    });
  }

  void _navigateToSettings() {
    final result = Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsPage()));
    result.whenComplete(() => _fetchSettings());
  }

  void _fetchSettings() {
    getSettings().then((value) {
      setState(() {
        settings = value;
      });
    });
  }

  PreferredSizeWidget? getAppBar() {
    if (USE_NEUMORPHISM) {
      return NeumorphicAppBar(
        actions: <Widget>[
          IconButton(
            onPressed: _refreshPlayerData,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh data",
          ),
          IconButton(
            onPressed: _navigateToSettings,
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
          ),
        ],
        title: new Text(widget.title),
      );
    }
    return new AppBar(
      actions: <Widget>[
        IconButton(
          onPressed: _refreshPlayerData,
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh data",
        ),
        IconButton(
          onPressed: _navigateToSettings,
          icon: const Icon(Icons.settings),
          tooltip: "Settings",
        ),
      ],
      title: new Text(widget.title),
    );
  }

  PreferredSizeWidget? getNeumorphicAppBar() {
    return new AppBar(
      actions: <Widget>[
        neumorphicButton(
          context,
          onPressed: _refreshPlayerData,
          child: const Icon(
            Icons.refresh,
            semanticLabel: "Refresh data",
          ),
        ),
        neumorphicButton(
          context,
          onPressed: _navigateToSettings,
          child: const Icon(
            Icons.settings,
            semanticLabel: "Settings",
          ),
        ),
      ],
      title: new Text(widget.title),
      elevation: 0.0,
      backgroundColor: _getBgcolor(),
    );
  }

  Color? _getBgcolor() {
    // if (USE_NEUMORPHISM) {
    //   return Color.fromARGB(240, 240, 240, 240);
    // }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _getScaffold();
    // if(USE_NEUMORPHISM) {
    // return
    // Neumorphic(
    //     style: NeumorphicStyle(
    //     shape: NeumorphicShape.concave,
    //     boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
    // depth: 8,
    // lightSource: LightSource.topLeft,
    // ),
    //   child : _getScaffold()
    // );
    // }
    // else {
    //   return _getScaffold();
    // }
  }

  Widget _getScaffold() {
    return new Scaffold(
      appBar: getAppBar(),
      body: getCenteredListView(),
      backgroundColor: _getBgcolor(),
//      floatingActionButton: enableButton? new FloatingActionButton(
//        onPressed: _onMineClicked,
//        tooltip: 'Mine',
//        child: new Icon(Icons.add),
//      ): null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// DOES NOT NEED TO BE IN THIS CLASS
  /// Gets human readable string for mining errors. Will be seen by end user
  String getErrorMessageForMiningResponse(MiningResponse response) {
    String message;
    // if this is a network issue then return a message about the network
    if (response.networkResponseCode != NetworkResponseCode.SUCCESS) {
      return getErrorMessageForNetworkResponse(response.networkResponseCode);
    }
    switch (response.miningResponseCode) {
      case MiningResponseCode.FAILURE:
        message = 'Unable to mine (0 HP? No hot res? Wrong outfit?) '
            'Log in via your browser, fix the issue, and log in again';
        break;
      case MiningResponseCode.NO_ACCESS:
        message = 'Unable to access the mine. Make sure you have used the '
            'charter/ticket and are wearing the mining outfit';
        break;
      case MiningResponseCode.SUCCESS:
        // success shouldn't show up in onError
        message =
            'Uhhh.... tell me if you see this message because it\'s another bug';
        break;
    }
    return message;
  }

  /// DOES NOT NEED TO BE IN THIS CLASS
  /// Gets human readable string for network errors. Will be seen by end user
  String getErrorMessageForNetworkResponse(NetworkResponseCode responseCode) {
    String message;
    switch (responseCode) {
      case NetworkResponseCode.ROLLOVER:
        message = 'Rollover is in progress. Try again when servers are back up';
        break;
      case NetworkResponseCode.EXPIRED_HASH:
        message = 'Did you log in via the browser while mining? Don\'t do that';
        break;
      case NetworkResponseCode.FAILURE:
        message =
            'Network call failed. Are you offline? Bad wifi? Get better wifi';
        break;
      case NetworkResponseCode.SUCCESS:
        // success shouldn't show up in onError
        message =
            'Uhhh.... tell me if you see this message because it\'s a bug';
    }
    return message;
  }

  /// Content to show to the user
  Widget getContent() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        raisedBorder(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _userInfoWidget,
                new MiningOutput(
                  _goldCounter,
                  _advsUsed,
                ),
              ],
            ),
            depth: 1.5,
            extraPadding: 7),
        new MiningInputFields(
          miningInputTextController,
          enableButton,
          _onMineClicked,
        ),
        _chatWidget,
        getPreconfiguredActions(),
        _lazyPersonWidget,
      ],
    );
  }

  Widget getPreconfiguredActions() {
    if (settings != null) {
      return new PreconfiguredActionsWidget(this, widget.network, settings!);
    } else {
      return Container();
    }
  }

  /// Gives us a padded and centered listview full of content
  Widget getCenteredListView() {
    return new ListView(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Center(
            child: getContent(),
          ),
        ),
      ],
    );
  }

  // SECTION PreConfiguredActionsWidgetHost start

  @override
  void onPreConfiguredActionsWidgetError() {
    // TODO this should use a more generic 'error' method than this
    onError(MiningResponse(
        NetworkResponseCode.FAILURE, MiningResponseCode.NO_ACCESS, false));
  }

  @override
  void onPreConfiguredActionsWidgetRequestsStatusUpdate() {
    _batchedRefreshPlayerData();
  }

  @override
  void onPreConfiguredActionsWidgetChatRequest(String chat) {
    _chatWidget.key.currentState?.sendChat(chat);
  }

  Future<String?> onPreConfiguredActionsWidgetChatRequestForResponse(
      String text) async {
    var chatWidgetState = _chatWidget.key.currentState;
    if (chatWidgetState == null) {
      return Future.value(null);
    } else {
      return chatWidgetState.sendChatAndWait(text);
    }
  }

// SECTION PreConfiguredActionsWidgetHost end
}

class MiningPageError {
  final String errorMessage;

  MiningPageError(this.errorMessage);
}
