import 'package:cards/models/base/player_status.dart';
import 'package:cards/widgets/player/status_picker.dart';
import 'package:flutter/material.dart';

class PlayerHeaderWidget extends StatelessWidget {
  const PlayerHeaderWidget({
    super.key,
    required this.name,
    required this.status,
    required this.sumOfRevealedCards,
    required this.onStatusChanged,
  });

  final String name;
  final PlayerStatus status;
  final Function(PlayerStatus) onStatusChanged;
  final int sumOfRevealedCards;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        StatusPicker(
          status: status,
          onStatusChanged: onStatusChanged,
        ),
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
