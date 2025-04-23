import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'game_logic.dart';

class MangalaGamePage extends StatefulWidget {
  const MangalaGamePage({super.key});

  @override
  State<MangalaGamePage> createState() => _MangalaGamePageState();
}

class _MangalaGamePageState extends State<MangalaGamePage> {
  final MangalaGame game = MangalaGame();

  void _handlePlayerMove(int index) {
    setState(() {
      game.playMove(index);
    });

    if (game.isGameOver) {
      _showGameOverDialog();
      return;
    }

    if (!game.isPlayerTurn && !game.isGameOver) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          game.playAIMove();
          if (game.isGameOver) {
            _showGameOverDialog();
          }
        });
      });
    }
  }

  void _resetGame() {
    setState(() {
      game.resetGame();
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(" Oyun Bitti!"),
        content: Text(game.getWinner()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text(" Tekrar Oyna"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(" Ana Menüye Dön"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'lib/assets/masa.svg',
              fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildHazineKuyu(game.getStore2),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    Transform.translate(
                      offset: const Offset(5, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6 * 2 - 1, (i) {
                          if (i % 2 == 1) return const SizedBox(width: 30);
                          final index = i ~/ 2;
                          return buildKuyu(game.getPlayer2[5 - index], isTopRow: true);
                        }),
                      ),
                    ),
                    const SizedBox(height: 110),
                    Transform.translate(
                      offset: const Offset(5, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6 * 2 - 1, (i) {
                          if (i % 2 == 1) return const SizedBox(width: 30);
                          final index = i ~/ 2;
                          return buildKuyu(
                            game.getPlayer1[index],
                            onTap: game.isPlayerTurn &&
                                    !game.isGameOver &&
                                    game.getPlayer1[index] > 0
                                ? () => _handlePlayerMove(index)
                                : null,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      game.isGameOver
                          ? game.getWinner()
                          : game.isPlayerTurn
                              ? "Senin sıran "
                              : "Yapay zeka oynuyor...",
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
              buildHazineKuyu(game.getStore1), // Oyuncu - Sağ
            ],
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.brown[800],
        title: const Text("Mangala Oyunu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          )
        ],
      ),
    );
  }

  Widget buildKuyu(int tasSayisi, {VoidCallback? onTap, bool isTopRow = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: isTopRow
            ? [
                Text('$tasSayisi', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                buildTasKutusu(tasSayisi, onTap: onTap),
              ]
            : [
                buildTasKutusu(tasSayisi, onTap: onTap),
                const SizedBox(height: 5),
                Text('$tasSayisi', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
      ),
    );
  }

  Widget buildTasKutusu(int tasSayisi, {VoidCallback? onTap}) {
    return Container(
      width: 70,
      height: 175,
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 65),
        child: Wrap(
          spacing: -5,
          runSpacing: -3,
          alignment: WrapAlignment.center,
          children: List.generate(tasSayisi, (_) {
            return SizedBox(
              width: 22,
              height: 20,
              child: SvgPicture.asset('lib/assets/tas.svg'),
            );
          }),
        ),
      ),
    );
  }

  Widget buildHazineKuyu(int tasSayisi) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 85,
          height: 360,
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.brown[700]!.withOpacity(0.0),
            borderRadius: BorderRadius.circular(45),
          ),
          child: Center( 
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: List.generate(tasSayisi, (_) {
                  return SizedBox(
                    width: 18,
                    height: 18,
                    child: SvgPicture.asset('lib/assets/tas.svg'),
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$tasSayisi',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}