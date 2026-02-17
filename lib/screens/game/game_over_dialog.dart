import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/my_text.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/widgets/helpers/dialog.dart';
import 'package:cards/gen/l10n/app_localizations.dart';

import 'package:flutter/material.dart';

/// Displays a game over dialog with the final game results and options to play again or exit.
/// The function sorts the players from lowest to highest score, marks the player with the lowest score as the winner, records the win, and updates the game history. It then creates a dialog with the player stats and buttons to play again or exit the game.
void showGameOverDialog(
  final BuildContext context,
  final GameModel gameModel,
) async {
  // sort from lowest to hightest score
  gameModel.players.sort(
    (a, b) => a.sumOfRevealedCards.compareTo(b.sumOfRevealedCards),
  );

  for (var player in gameModel.players) {
    player.isWinner = false;
  }
  gameModel.players.first.isWinner = true;

  await recordPlayerWin(
    gameModel.roomName,
    gameModel.gameStartDate,
    gameModel.players.first.name,
  );

  gameModel.roomHistory.clear();
  gameModel.roomHistory.addAll(await getGameHistory(gameModel.roomName));

  Widget columnHeaders(AppLocalizations localizations) {
    return SizedBox(
      width: ConstLayout.gameOverDialogWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: Text(localizations.players)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localizations.gamesWon),
                Text(localizations.thisGame),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget playerStats(player) {
    return SizedBox(
      width: ConstLayout.gameOverDialogWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(fontSize: ConstLayout.textM),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gameModel.getWinsForPlayerName(player.name).length.toString(),
                  style: const TextStyle(fontSize: ConstLayout.textXS),
                ),
                MyText(
                  player.sumOfRevealedCards.toString(),
                  fontSize: ConstLayout.textM.toInt(),
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  if (context.mounted) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    myDialog(
      context: context,
      title: localizations.gameOver,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          columnHeaders(localizations),
          Divider(),
          ...gameModel.players.map((player) => playerStats(player)),
        ],
      ),
      buttons: <Widget>[
        ElevatedButton(
          child: Text(localizations.playAgain),
          onPressed: () {
            Navigator.of(context).pop();
            gameModel.initializeGame();
          },
        ),
        ElevatedButton(
          child: Text(localizations.exit),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
