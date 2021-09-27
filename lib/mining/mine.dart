
import '../constants.dart';
import '../utils.dart';

/// An instance of a mine. Contains a list of minable squares
class Mine {
  final List<MineableSquare> squares;
  final bool canGetNewMine;
  final int minedSquares;

  /// constructor takes in a list of initial mineable/clickable squares
  /// [squares]
  Mine(this.squares, this.canGetNewMine, this.minedSquares);

  void addSquare(MineableSquare square) {
    squares.add(square);
  }

  /// algorithm:
  /// check exposed shinies. If found, click
  /// if no shinies, click anywhere once. If shiny found, click. Else newmine
  MineableSquare getNextMineableSquare() {
    squares.sort((a, b) => b.priority() - a.priority());
    // mine visible shiny squares asap (unless they're in 3rd row)
    MineableSquare squareToMine;
    squareToMine = squares.firstWhere((square) => _isSquareWorthMining(square, minedSquares),
        orElse: () => squareToMine = null);
    if (squareToMine == null) {
      aj_print("need a new mine");
      // need a new mine
      return null;
    }
    return squareToMine;
  }

  /// Returns a list of all shiny squares
  /// can be used to send multiple mine requests if multiple shinies are exposed
  /// Might not be worth using ever
  Iterable<MineableSquare> _getAllMineableSquares(int minedSquares) {
    // mine visible shiny squares asap (unless they're in 3rd row)
    Iterable<MineableSquare> squaresToMine;
    squares.sort((a, b) => a.priority().compareTo(b.priority()));
    squaresToMine = squares.where((square) => _isSquareWorthMining(square, minedSquares));
    if (squaresToMine == null) {
      aj_print("need a new mine");
      // need a new mine
      return null;
    }
    return squaresToMine;
  }

  /// true if this square has an 'acceptable' probability of being worthwhile
  bool _isSquareWorthMining(MineableSquare square, int minedSquares) {
    var isHighPriority = square.isHighPriority();
    if(isHighPriority) {
      return true;
    }
    // since this is called via the stream api, the order of evaluation might be wrong. It might be better
    // to check for all high pri squares and then see if low ones are needed
    return USE_NEW_ALGORITHM && minedSquares >= 6 && square.isLowPriority();
  }

  // If we see no shinies, we need a new mine. But a new mine can't be
  // requested until we've mined at least once.
  /// This method gives us a square we can mine that has a high-ish prob of
  /// exposing a shiny. Else we can just ask for a new mine.
  MineableSquare getThrowawayMineSquare() {
    return squares.firstWhere((square) => square.x != 01 && square.x != 6);
  }

  String toString() {
    String value = "";
    for (MineableSquare sq in squares) {
      value = value + sq.toString() + "\n";
    }
    return value + ", Mined $minedSquares";
  }
}

/// A square in the mining grid
class MineableSquare {
  final String url;
  final bool isShiny;
  final bool _isFirstTwoRows;
  final int x;
  final int y;

  MineableSquare(this.url, this.isShiny, this.x, this.y):
        _isFirstTwoRows = y == 5 || y == 6 ;

  int priority() {
    // we can't mine too deep
    if (!_isFirstTwoRows) return 0;
    // only shiny squares get a nonzero priority- nonshiny are trash
    // We also want to mine row 5 before 6, so pri is essentially the y and then x
    return (6-y)*10 + (6-x);
  }

  bool isHighPriority() {
    return _isFirstTwoRows && isShiny;
  }

  /// If we have mined a lot, it becomes more worthwhile to mine the third row
  bool isLowPriority() {
    return isShiny && y == 4;
  }

  String toString() {
    return "at ($x,$y). shiny? $isShiny isFront? $_isFirstTwoRows pri: ${priority()}";
  }
}