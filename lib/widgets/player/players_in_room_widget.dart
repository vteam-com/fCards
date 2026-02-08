import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/my_text.dart';
import 'package:flutter/material.dart';

///
class PlayersInRoomWidget extends StatelessWidget {
  /// Constructs a [PlayersInRoomWidget] with the given parameters.
  ///
  /// The [activePlayerName] parameter represents the name of the currently active player.
  /// The [playerNames] parameter is a list of player names.
  /// The [onPlayerSelected] parameter is a callback function that is called when a player is selected.
  /// The [onRemovePlayer] parameter is a callback function that is called when a player is removed.
  const PlayersInRoomWidget({
    super.key,
    required this.activePlayerName,
    required this.playerNames,
    required this.onPlayerSelected,
    required this.onRemovePlayer,
  });

  /// The name of the currently active player.
  final String activePlayerName;

  /// Callback function that is called when a player is selected.
  /// Takes the selected player's name as a parameter.
  final Function(String) onPlayerSelected;

  /// Callback function that is called when a player is removed.
  /// Takes the removed player's name as a parameter.
  final Function(String) onRemovePlayer;

  /// List of all player names in the room.
  final List<String> playerNames;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: ConstLayout.joinGamePlayerListMaxWidth,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.panelInputZone,
                borderRadius: BorderRadius.all(
                  Radius.circular(ConstLayout.radiusM),
                ),
              ),
              child: ListView.builder(
                itemCount: playerNames.length,
                itemBuilder: (BuildContext _, int index) {
                  String nameToDisplay = playerNames[index];
                  return ListTile(
                    title: TextButton(
                      onPressed: () => onPlayerSelected(playerNames[index]),
                      child: MyText(nameToDisplay, fontSize: ConstLayout.textM),
                    ),
                    leading: SizedBox(
                      width: ConstLayout.sizeXL,
                      child: MyText(
                        nameToDisplay == activePlayerName ? 'YOU>' : '',
                        fontSize: ConstLayout.textS,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: colorScheme.error),
                      onPressed: () => onRemovePlayer(playerNames[index]),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
