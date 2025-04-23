
class MangalaGame {
  List<int> player1 = List.filled(6, 4);
  List<int> player2 = List.filled(6, 4);
  int store1 = 0;
  int store2 = 0;
  bool isPlayerTurn = true;
  bool isGameOver = false;

  List<int> get getPlayer1 => List.from(player1);
  List<int> get getPlayer2 => List.from(player2);
  int get getStore1 => store1;
  int get getStore2 => store2;

  void playMove(int index) {
    if (isGameOver || !isPlayerTurn || player1[index] == 0) return;

    print(" Oyuncu $index. kuyuyu oynadı");
    bool again = _playTurn(player1, player2, index, true);
    _checkGameEnd();
    if (!again) isPlayerTurn = false;
  }

  void playAIMove() {
    if (isGameOver || isPlayerTurn) return;

    final validMoves = List.generate(6, (i) => i).where((i) => player2[i] > 0).toList();

    if (validMoves.isEmpty) {
      print(" Yapay zekanın oynayacak taşı kalmadı.");
      _checkGameEnd();
      isPlayerTurn = true;
      return;
    }

    int bestScore = -99999;
    int bestMove = validMoves.first;

    for (int i in validMoves) {
      var cloned = _cloneState();
      bool again = cloned._playTurn(cloned.player2, cloned.player1, i, false);
      int score = _alphaBeta(cloned, 6, -10000, 10000, true);
      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }

    print(" Yapay zeka $bestMove. kuyuyu oynadı");
    bool again = _playTurn(player2, player1, bestMove, false);
    _checkGameEnd();

    if (!isGameOver && again) {
      playAIMove();
    } else {
      isPlayerTurn = true;
    }
  }

  bool _playTurn(List<int> own, List<int> enemy, int startIndex, bool isPlayer1) {
    int stones = own[startIndex];
    own[startIndex] = 0;

    int pos = (stones == 1) ? startIndex : startIndex - 1;
    bool onOwnSide = true;

    while (stones > 0) {
      pos++;

      if (onOwnSide && pos < 6) {
        own[pos]++;
        stones--;

        if (stones == 0 && own[pos] == 1 && enemy[5 - pos] > 0) {
          int kazanilan = enemy[5 - pos] + 1;
          if (isPlayer1) {
            store1 += kazanilan;
            print(" Oyuncu taş topladı! +$kazanilan taş");
          } else {
            store2 += kazanilan;
            print(" Yapay zeka taş topladı! +$kazanilan taş");
          }
          own[pos] = 0;
          enemy[5 - pos] = 0;
        }

      } else if (onOwnSide && pos == 6) {
        if (isPlayer1) {
          store1++;
          print(" Oyuncu hazinesine taş attı");
        } else {
          store2++;
          print(" Yapay zeka hazinesine taş attı");
        }
        stones--;

        if (stones == 0) {
          print(" Son taş hazineye! Tekrar sıra sende.");
          return true;
        }

        onOwnSide = false;
        pos = -1;

      } else if (!onOwnSide && pos < 6) {
        enemy[pos]++;
        stones--;

        if (stones == 0 && enemy[pos] % 2 == 0 && enemy[pos] > 0) {
          int alinan = enemy[pos];
          if (isPlayer1) {
            store1 += alinan;
            print(" Oyuncu çiftleme yaptı! +$alinan taş");
          } else {
            store2 += alinan;
            print(" Yapay zeka çiftleme yaptı! +$alinan taş");
          }
          enemy[pos] = 0;
        }

      } else if (!onOwnSide && pos >= 6) {
        onOwnSide = true;
        List<int> temp = own;
        own = enemy;
        enemy = temp;
        isPlayer1 = !isPlayer1;
        pos = -1;
      }
    }

    return false;
  }

  void _checkGameEnd() {
    if (player1.every((e) => e == 0)) {
      int kalan = player2.reduce((a, b) => a + b);
      store1 += kalan;
      player2 = List.filled(6, 0);
      isGameOver = true;
      print(" Oyun bitti! Oyuncu kalan $kalan taşı aldı.");
      print(" ${getWinner()}");
    } else if (player2.every((e) => e == 0)) {
      int kalan = player1.reduce((a, b) => a + b);
      store2 += kalan;
      player1 = List.filled(6, 0);
      isGameOver = true;
      print(" Oyun bitti! Yapay zeka kalan $kalan taşı aldı.");
      print(" ${getWinner()}");
    }
  }

  String getWinner() {
    if (!isGameOver) return "";
    if (store1 > store2) return "Kazanan: Oyuncu ";
    if (store2 > store1) return "Kazanan: Yapay Zeka ";
    return "Berabere ";
  }

  void resetGame() {
    player1 = List.filled(6, 4);
    player2 = List.filled(6, 4);
    store1 = 0;
    store2 = 0;
    isPlayerTurn = true;
    isGameOver = false;
    print("Oyun sıfırlandı.");
  }

  int _alphaBeta(MangalaGame state, int depth, int alpha, int beta, bool maximizing) {
    if (depth == 0 || state.isGameOver) {
      return state.store2 - state.store1;
    }

    final validMoves = List.generate(6, (i) => i).where((i) => maximizing ? state.player2[i] > 0 : state.player1[i] > 0).toList();
    if (validMoves.isEmpty) return state.store2 - state.store1;

    if (maximizing) {
      int maxEval = -9999;
      for (int i in validMoves) {
        var cloned = state._cloneState();
        cloned._playTurn(cloned.player2, cloned.player1, i, false);
        int eval = _alphaBeta(cloned, depth - 1, alpha, beta, false);
        maxEval = maxEval > eval ? maxEval : eval;
        alpha = alpha > eval ? alpha : eval;
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 9999;
      for (int i in validMoves) {
        var cloned = state._cloneState();
        cloned._playTurn(cloned.player1, cloned.player2, i, true);
        int eval = _alphaBeta(cloned, depth - 1, alpha, beta, true);
        minEval = minEval < eval ? minEval : eval;
        beta = beta < eval ? beta : eval;
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  MangalaGame _cloneState() {
    var clone = MangalaGame();
    clone.player1 = List.from(player1);
    clone.player2 = List.from(player2);
    clone.store1 = store1;
    clone.store2 = store2;
    clone.isPlayerTurn = isPlayerTurn;
    clone.isGameOver = isGameOver;
    return clone;
  }
}