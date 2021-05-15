import 'package:test/test.dart';
import 'package:kol_miner/mining/mine.dart';

// test with  flutter test test/mining/mine_test.dart
void main() {
  group('Empty mine tests', () {
    var mine = Mine([], true, 0);

    test('getNextMineableSquare is null if mine is list empty', () {
      expect(mine.getNextMineableSquare(), isNull);
    });

    test('Mine is null if mine is list empty and cant get next square', () {
      var getNextMineableSquare = Mine([], false, 0);
      expect(mine.getNextMineableSquare(), isNull);
    });

    test('getNextMineableSquare is null if mine is list empty and many squares mined', () {
      var mine = Mine([], true, 10);
      expect(mine.getNextMineableSquare(), isNull);
    });
  });

  group('Mine with no shinies', () {
    var mine = Mine([
      MineableSquare("", false, 1, 1),
      MineableSquare("", false, 2, 1),
      MineableSquare("", false, 3, 1)], true, 0);

    test('getNextMineableSquare is null if mine has no shinies', () {
      expect(mine.getNextMineableSquare(), isNull);
    });
  });


  group('Mine with shinies', () {
    test('getNextMineableSquare does not return shiny in 4th row if we can still mine in first 2 rows', () {
      var mine = Mine([
        MineableSquare("a", true, 1, 4),
        MineableSquare("b", true, 2, 5),
        MineableSquare("c", true, 3, 6)], true, 10);

      var square = mine.getNextMineableSquare();

      expect(square.url, equals("c"));
    });

    test('getNextMineableSquare does not return shiny in 5th row if we can still mine in 6th row', () {
      var mine = Mine([
        MineableSquare("b", true, 2, 5),
        MineableSquare("c", true, 3, 6)], true, 10);

      var square = mine.getNextMineableSquare();

      expect(square.url, equals("c"));
    });


    test('getNextMineableSquare does not return shiny in 4th row if we mined under 6 squares', () {
      var mine = Mine([
        MineableSquare("a", true, 1, 4)], true, 5);

      expect(mine.getNextMineableSquare(), isNull);
    });

    test('getNextMineableSquare does not return shiny in 4th row if we mined 0 squares', () {
      var mine = Mine([
        MineableSquare("a", true, 1, 4)], true, 0);

      expect(mine.getNextMineableSquare(), isNull);
    });

    test('getNextMineableSquare returns shiny in 6th row if we mined 0 squares', () {
      var mine = Mine([
        MineableSquare("a", true, 1, 6)], true, 0);

      var square = mine.getNextMineableSquare();
      expect(square.url, equals("a"));
    });

    test('getNextMineableSquare returns shiny in 6th row if we mined 10 squares', () {
      var mine = Mine([
        MineableSquare("a", true, 1, 6)], true, 10);

      var square = mine.getNextMineableSquare();
      expect(square.url, equals("a"));
    });

    test('getNextMineableSquare returns shiny in 6th row it is the only shiny', () {
      var mine = Mine([
        MineableSquare("a", false, 1, 6),
        MineableSquare("aa", false, 2, 6),
        MineableSquare("b", true, 3, 6),
        MineableSquare("c", false, 4, 6)
      ], true, 10);

      var square = mine.getNextMineableSquare();
      expect(square.url, equals("b"));
    });
  });

}
