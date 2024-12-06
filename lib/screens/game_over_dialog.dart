import 'package:cards/models/base/player_model.dart';
import 'package:flutter/material.dart';

void showGameOverDialog(
  BuildContext context,
  List<PlayerModel> players,
  VoidCallback initializeGame,
) {
  // sort from lowest to hightest score
  players.sort(
    (a, b) => a.sumOfRevealedCards.compareTo(b.sumOfRevealedCards),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Game Over', style: TextStyle(fontSize: 30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: players
              .map(
                (player) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${player.sumOfRevealedCards}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Play Again'),
            onPressed: () {
              Navigator.of(context).pop();
              initializeGame();
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
    },
  );
}
