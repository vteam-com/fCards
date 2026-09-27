import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/game/game_result.dart';
import 'package:cards/models/game/leaderboard_service.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/dialog.dart';
import 'package:cards/widgets/helpers/my_text.dart';
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

  await _recordLeaderboardResult(gameModel);

  gameModel.roomHistory.clear();
  gameModel.roomHistory.addAll(
    await LeaderboardService.roomWinHistory(gameModel.tableId),
  );

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
                  style: const TextStyle(fontSize: ConstLayout.textS),
                ),
                MyText(
                  player.sumOfRevealedCards.toString(),
                  fontSize: ConstLayout.textM,
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
        MyButtonRectangle.primary(
          width: ConstLayout.dialogButtonWidth,
          height: ConstLayout.dialogButtonHeight,
          onTap: () {
            Navigator.of(context).pop();
            gameModel.initializeGame();
          },
          child: Text(localizations.playAgain),
        ),
        MyButtonRectangle.secondary(
          width: ConstLayout.dialogButtonWidth,
          height: ConstLayout.dialogButtonHeight,
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Text(localizations.exit),
        ),
      ],
    );
  }
}

/// Saves the finished game to the leaderboards.
///
/// Every device in the room calls this; each one links only its own signed-in
/// player to their account, and the service merges the reports.
Future<void> _recordLeaderboardResult(final GameModel gameModel) async {
  final String? uid = AuthService.currentUser?.uid;
  final List<String> names = gameModel.getPlayersNames();
  final GameResult result = GameResult.fromScores(
    id: '${gameModel.tableId}_${gameModel.gameStartDate.millisecondsSinceEpoch}',
    tableKey: gameModel.tableId,
    tableName: gameModel.tableName,
    style: gameModel.gameStyle,
    cards: CardMedium.virtual,
    endedAt: gameModel.endedOn.millisecondsSinceEpoch == 0
        ? DateTime.now()
        : gameModel.endedOn,
    names: names,
    scores: gameModel.players
        .map((PlayerModel player) => player.sumOfRevealedCards)
        .toList(),
    uids: names
        .map(
          (String name) =>
              uid != null && name == gameModel.loginUserName ? uid : '',
        )
        .toList(),
  );
  await LeaderboardService.recordResult(
    result,
    avatarUrls: <String, String>{?uid: AuthService.currentUser?.photoURL ?? ''},
  );
}
