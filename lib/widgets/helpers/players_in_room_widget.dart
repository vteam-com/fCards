// ignore: fcheck_magic_numbers
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
    return Container(
      constraints: BoxConstraints(maxHeight: 250),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              '${playerNames.length} players',
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: ListView.builder(
                itemCount: playerNames.length,
                itemBuilder: (context, index) {
                  String nameToDisplay = playerNames[index];
                  return ListTile(
                    title: TextButton(
                      onPressed: () => onPlayerSelected(playerNames[index]),
                      child: Text(
                        nameToDisplay,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    leading: SizedBox(
                      width: 40,
                      child: nameToDisplay == activePlayerName
                          ? Text('(YOU)')
                          : null,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.remove_circle,
                        color: Colors.red.shade300,
                      ),
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
