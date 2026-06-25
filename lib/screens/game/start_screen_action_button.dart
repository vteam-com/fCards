import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:flutter/material.dart';

/// Main action button for joining or starting a game.
class StartScreenActionButton extends StatelessWidget {
  /// Creates a [StartScreenActionButton].
  const StartScreenActionButton({
    required this.playerName,
    required this.isPlayerInList,
    required this.playerCount,
    required this.isCreateRoomFlow,
    required this.onJoinGame,
    required this.onStartGame,
    super.key,
  });

  /// Whether this is the create-room flow.
  final bool isCreateRoomFlow;

  /// Whether the active player is already in the room.
  final bool isPlayerInList;

  /// Callback for joining the game.
  final VoidCallback onJoinGame;

  /// Callback for starting the game.
  final VoidCallback onStartGame;

  /// Current player count in the room.
  final int playerCount;

  /// Current player name.
  final String playerName;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (playerName.isEmpty) {
      return MyButtonRectangle(
        onTap: () {},
        width: double.infinity,
        height: ConstLayout.sizeXXL,
        child: Text(
          l10n.pleaseEnterYourName,
          style: TextStyle(
            fontSize: ConstLayout.textM,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    if (isPlayerInList && playerCount > 1) {
      return _buildButton(
        context: context,
        label: l10n.startGame,
        onTap: onStartGame,
      );
    }

    if (isPlayerInList) {
      return _buildButton(
        context: context,
        label: l10n.waitingForPlayers,
        onTap: () {},
      );
    }

    return _buildButton(
      context: context,
      label: isCreateRoomFlow ? l10n.joinTable : l10n.joinGame,
      onTap: onJoinGame,
    );
  }

  /// Builds the shared button shell used for each action state.
  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return MyButtonRectangle(
      onTap: onTap,
      width: double.infinity,
      height: ConstLayout.sizeXXL,
      child: Text(
        label,
        style: TextStyle(
          fontSize: ConstLayout.textM,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
