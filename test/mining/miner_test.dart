import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kol_miner/mining/miner.dart';

// generate mocks with  flutter pub run build_runner build
// test with  flutter test test/mining/miner_test.dart
@GenerateMocks([Miner])
void main() {
  group('App Provider Tests', () {
    var miner = Miner(null);

    test('Miner should mine', () {
      miner.mineNextSquare();
      expect(miner.currentMine.minedSquares, equals(0));
    });
  });
}
