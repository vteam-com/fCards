import 'package:cards/models/backend_model.dart';
import 'package:cards/models/base/game_model.dart';
import 'package:cards/widgets/dialog.dart';
import 'package:flutter/material.dart';

void showGameOverDialog(
  final BuildContext context,
  final GameModel gameModel,
) async {
  // sort from lowest to hightest score
  gameModel.players.sort(
    (a, b) => a.sumOfRevealedCards.compareTo(b.sumOfRevealedCards),
  );

  gameModel.players.forEach((player) => player.isWinner = false);
  gameModel.players.first.isWinner = true;

  await recordPlayerWin(
    gameModel.roomName,
    gameModel.gameStartDate,
    gameModel.players.first.name,
  );

  gameModel.roomHistory.clear();
  gameModel.roomHistory.addAll(await getGameHistory(gameModel.roomName));

  Widget playerStats(player) {
    return SizedBox(
      width: 500,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gameModel.getWinsForPlayerName(player.name).length.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${player.sumOfRevealedCards}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  if (context.mounted) {
    myDialog(
      context: context,
      title: 'Game Over',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            gameModel.players.map((player) => playerStats(player)).toList(),
      ),
      buttons: <Widget>[
        ElevatedButton(
          child: const Text('Play Again'),
          onPressed: () {
            Navigator.of(context).pop();
            gameModel.initializeGame();
          },
        ),
        ElevatedButton(
          child: const Text('Exit'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
