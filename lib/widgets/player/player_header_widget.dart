import 'package:cards/widgets/helpers/misc.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/widgets/helpers/date_importance.dart';
import 'package:cards/widgets/helpers/dialog.dart';
import 'package:cards/widgets/player/status_picker.dart';
import 'package:flutter/material.dart';
import 'package:cards/models/app/constants.dart';

///
class PlayerHeaderWidget extends StatelessWidget {
  ///
  const PlayerHeaderWidget({
    super.key,
    required this.gameModel,
    required this.player,
    required this.onStatusChanged,
    required this.sumOfRevealedCards,
  });

  ///
  final GameModel gameModel;

  ///
  final Function(PlayerStatus) onStatusChanged;

  ///
  final PlayerModel player;

  ///
  final int sumOfRevealedCards;

  @override
  Widget build(BuildContext context) {
    final List<DateTime> listOfWinsForThisPlayer = gameModel
        .getWinsForPlayerName(player.name);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Tooltip(
            message: listOfWinsForThisPlayer.length.toString(),
            child: TextButton(
              onPressed: () {
                showHistory(context, listOfWinsForThisPlayer);
              },
              child: TextSize(
                player.name,
                Constants.textM,
                color: Colors.white,
                bold: true,
              ),
            ),
          ),
        ),

        StatusPicker(status: player.status, onStatusChanged: onStatusChanged),

        TextSize(
          sumOfRevealedCards.toString(),
          Constants.textM,
          align: TextAlign.end,
          color: Colors.white.withAlpha(Constants.golfJokerValue),
          bold: true,
        ),
      ],
    );
  }

  ///
  void showHistory(
    final BuildContext context,
    final List<DateTime> listOfWinsForThisPlayer,
  ) {
    myDialog(
      context: context,
      title:
          '${player.name} won ${listOfWinsForThisPlayer.length} times in the ${gameModel.roomName} room',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: listOfWinsForThisPlayer
            .map((date) => DateTimeWidget(dateTime: date))
            .toList(),
      ),
    );
  }
}
