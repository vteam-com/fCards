import 'package:cards/models/app/constants_card_value.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/my_text.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/widgets/helpers/date_importance.dart';
import 'package:cards/widgets/helpers/dialog.dart';
import 'package:cards/widgets/player/status_picker.dart';
import 'package:flutter/material.dart';

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
              child: MyText(
                player.name,
                fontSize: ConstLayout.textM,
                color: Colors.white,
                bold: true,
              ),
            ),
          ),
        ),

        StatusPicker(status: player.status, onStatusChanged: onStatusChanged),

        MyText(
          sumOfRevealedCards.toString(),
          fontSize: ConstLayout.textM,
          align: TextAlign.end,
          color: Colors.white.withAlpha(ConstCardValue.cardValueJoker),
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
          '${player.name} won ${listOfWinsForThisPlayer.length} times at table ${gameModel.roomName}',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: listOfWinsForThisPlayer
            .map((date) => DateTimeWidget(dateTime: date))
            .toList(),
      ),
    );
  }
}
