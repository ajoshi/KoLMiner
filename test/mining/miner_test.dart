import 'package:kol_miner/mining/miner.dart';
import 'package:kol_miner/network/kol_network.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'miner_test.mocks.dart';

// generate mocks with  flutter pub run build_runner build
// test with  flutter test test/mining/miner_test.dart
@GenerateMocks([KolNetwork])
void main() {
  group('App Provider Tests', () {
    var miner = Miner(MockKolNetwork());

    test('Miner should mine', () {
      //   miner.mineNextSquare();
      //    expect(miner.currentMine.minedSquares, equals(0));
    });
  });
}
