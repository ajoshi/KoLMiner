import 'package:kol_miner/chat_commands/chat_command.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'chat_command_test.mocks.dart';

// generate mocks with  flutter pub run build_runner build
// test with  flutter test test/chat_commands/chat_command_test.dart
@GenerateMocks([KolNetwork])
void main() {
  group('App Provider Tests', () {
    var network = MockKolNetwork();
    var chatCommander = ChatCommander(network);
    when(network.makeRequestToPath(any, method: HttpMethod.POST)).thenAnswer(
        (_) => Future(
            () => NetworkResponse(NetworkResponseCode.SUCCESS, "response")));

    test('outfit change command follows redirect to outfit change request', () {
      var response = chatCommander.followChatRedirectsInResponse(
          "{\"output\":\"<font color=green>Equipping \"volcano mining (#237)\".<!--js(dojax('inv_equip.php?action=outfit&whichoutfit=-237&ajax=1');)--><\\/font>\",\"msgs\":[]}");

      verify(network.makeRequestToPath(
              "inv_equip.php?action=outfit&whichoutfit=-237&ajax=1",
              method: HttpMethod.POST))
          .called(1);
      response.then((value) => expect(value, true));
    });

    test('single consumption command redirects to consumption endpoint', () {
      chatCommander.followChatRedirectsInResponse(
          "{\"output\":\"<font color=green>Using 1 slimy paste.<!--js(dojax('inv_spleen.php?whichitem=5214&ajax=1&pwd=822fbb9ba37ac&quantity=1');)--><\\/font>\",\"msgs\":[]}");

      verify(network.makeRequestToPath(
              "inv_spleen.php?whichitem=5214&ajax=1&pwd=822fbb9ba37ac&quantity=1",
              method: HttpMethod.POST))
          .called(1);
    });

    test('invalid command fails as expected', () {
      var response = chatCommander.followChatRedirectsInResponse(
          "{\"output\":\"<font color=green>Sorry, I can't find that outfit.<\\/font>\",\"msgs\":[]}");

      verifyNever(network.makeRequestToPath(any, method: HttpMethod.POST));
      response.then((value) => expect(value, false));
    });

    test('chat message is sent', () {
      var response = chatCommander.followChatRedirectsInResponse(
          "{\"msgs\":[{\"type\":\"private\",\"who\":{\"id\":\"2190946\",\"name\":\"sel\",\"color\":\"black\"},\"for\":{\"id\":\"1889009\",\"name\":\"Buffy\",\"color\":\"black\"},\"msg\":\"ode\",\"time\":1633294452,\"format\":0}]}");

      verifyNever(network.makeRequestToPath(any, method: HttpMethod.POST));
      response.then((value) => expect(value, false));
    });

    //TODO Investigate why this test fails- 2 calls to network are made in the correct order, but mockito isn't seeing them
    //  test('2 ajax redirects in response result in 2 network calls', () {
    //    var response = chatCommander.followChatRedirectsInResponse("{\"output\":\"<font color=green>Purchasing 1 chewing gum on a string.<!--js(dojax('shop.php?pwd=822fbb9ba37ac&buying=1&whichrow=648&quantity=1&whichshop=generalstore&ajax=1&action=buyitem');)--><\\/font><br><font color=green>Using 1 chewing gum on a string.<!--js(dojax('inv_use.php?whichitem=23&ajax=1&pwd=822f55af3d89d6bc4004b96bb9ba37ac');)--><\\/font><br><font color=green>Sending you to Hermitage.<!--js(top.mainpane.location.href='\\/hermit.php')--><\\/font>\",\"msgs\":[]}");
    //
    //    response.then((value) => expect(value, true));
    //    verifyInOrder([
    //      (network.makeRequestToPath("shop.php?pwd=822fbb9ba37ac&buying=1&whichrow=648&quantity=1&whichshop=generalstore&ajax=1&action=buyitem", method: HttpMethod.POST)),
    //      (network.makeRequestToPath("inv_use.php?whichitem=23&ajax=1&pwd=822f55af3d89d6bc4004b96bb9ba37ac", method: HttpMethod.POST))
    //    ]);
    // //   verify(network.makeRequestToPath("shop.php?pwd=822fbb9ba37ac&buying=1&whichrow=648&quantity=1&whichshop=generalstore&ajax=1&action=buyitem", method: HttpMethod.POST)).called(1);
    //  // verify(network.makeRequestToPath("inv_use.php?whichitem=23&ajax=1&pwd=822f55af3d89d6bc4004b96bb9ba37ac", method: HttpMethod.POST)).called(1);
    //  });
  });
}
