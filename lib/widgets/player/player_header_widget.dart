import 'package:cards/widgets/misc.dart';
import 'package:cards/models/game_model.dart';
import 'package:cards/widgets/date_importance.dart';
import 'package:cards/widgets/dialog.dart';
import 'package:cards/widgets/player/status_picker.dart';
import 'package:flutter/material.dart';
import 'package:cards/models/constants.dart';

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
        SizedBox(
          width: Constants.playerDisplayPaddingWidth.toDouble(),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Tooltip(
              message: listOfWinsForThisPlayer.length.toString(),
              child: TextButton(
                onPressed: () {
                  showHistory(context, listOfWinsForThisPlayer);
                },
                child: TextSize(
                  player.name,
                  Constants.textSizeX1,
                  color: Colors.white,
                  bold: true,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.spacing),
          child: StatusPicker(
            status: player.status,
            onStatusChanged: onStatusChanged,
          ),
        ),
        SizedBox(
          width: Constants.cardDisplayPaddingWidth.toDouble(),
          child: TextSize(
            sumOfRevealedCards.toString(),
            Constants.textSizeX1,
            align: TextAlign.end,
            color: Colors.white.withAlpha(Constants.golfJokerValue),
            bold: true,
          ),
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
