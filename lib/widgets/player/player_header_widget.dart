import 'package:cards/models/base/game_model.dart';
import 'package:cards/widgets/date_importance.dart';
import 'package:cards/widgets/dialog.dart';
import 'package:cards/widgets/player/status_picker.dart';
import 'package:flutter/material.dart';

class PlayerHeaderWidget extends StatelessWidget {
  const PlayerHeaderWidget({
    super.key,
    required this.gameModel,
    required this.player,
    required this.onStatusChanged,
    required this.sumOfRevealedCards,
  });

  final GameModel gameModel;
  final PlayerModel player;
  final Function(PlayerStatus) onStatusChanged;
  final int sumOfRevealedCards;

  @override
  Widget build(BuildContext context) {
    final List<DateTime> listOfWinsForThisPlayer =
        gameModel.getWinsForPlayerName(player.name);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 80,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Tooltip(
              message: listOfWinsForThisPlayer.length.toString(),
              child: TextButton(
                onPressed: () {
                  showHistory(context, listOfWinsForThisPlayer);
                },
                child: Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: StatusPicker(
            status: player.status,
            onStatusChanged: onStatusChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            sumOfRevealedCards.toString(),
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void showHistory(
    final BuildContext context,
    final List<DateTime> listOfWinsForThisPlayer,
  ) {
    myDialog(
      context: context,
      title: 'History',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: listOfWinsForThisPlayer
            .map(
              (date) => DateTimeWidget(
                dateTime: date,
              ),
            )
            .toList(),
      ),
    );
  }
}
