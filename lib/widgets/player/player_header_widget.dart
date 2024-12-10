import 'package:cards/models/base/player_model.dart';
import 'package:cards/widgets/player/status_picker.dart';
import 'package:flutter/material.dart';

class PlayerHeaderWidget extends StatelessWidget {
  const PlayerHeaderWidget({
    super.key,
    required this.player,
    required this.onStatusChanged,
    required this.sumOfRevealedCards,
  });

  final PlayerModel player;
  final Function(PlayerStatus) onStatusChanged;
  final int sumOfRevealedCards;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          player.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        StatusPicker(
          status: player.status,
          onStatusChanged: onStatusChanged,
        ),
        // TextButton(
        //   onPressed: () {
        //     // ToDo
        //   },
        //   child: Text(
        //     player.wins.length.toString(),
        //     style: TextStyle(
        //       color: Colors.white.withAlpha(150),
        //       fontSize: 20.0,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),
        Text(
          sumOfRevealedCards.toString(),
          style: TextStyle(
            color: Colors.white.withAlpha(150),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
