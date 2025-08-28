import 'package:flutter/material.dart';

/// A widget for editing a player's name.
///
/// This widget displays the player's name. When the user taps on it, a dialog
/// appears to edit the name or remove the player.
class PlayerHeader extends StatefulWidget {
  /// Creates an [PlayerHeader] widget.
  const PlayerHeader({
    super.key,
    required this.playerName,
    required this.onNameChanged,
    required this.onPlayerRemoved,
    this.onPlayerAdded,
    this.playerIndex,
    required this.rank,
    required this.numberOfPlayers,
    required this.totalScore,
  });

  /// The name of the player.
  final String playerName;

  /// A callback that is called when the player's name is changed.
  final void Function(String) onNameChanged;

  /// A callback that is called when the player is removed.
  final void Function() onPlayerRemoved;

  /// A callback that is called when a new player should be added.
  final void Function()? onPlayerAdded;

  /// The index of the player.
  final int? playerIndex;

  /// The rank of the player.
  final int rank;

  /// The total number of players.
  final int numberOfPlayers;

  /// The total score of the player.
  final int totalScore;

  @override
  State<PlayerHeader> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends State<PlayerHeader> {
  Color _getScoreColor(int rank, int numberOfPlayers) {
    if (rank == 1) {
      return Colors.green.shade300;
    } else if (rank == numberOfPlayers) {
      return Colors.red.shade300;
    } else {
      return Colors.orange.shade300;
    }
  }

  Widget _buildWiningPosition(int rank, int numberOfPlayers) {
    if (rank == 1) {
      return Text(
        '👑',
        style: TextStyle(fontWeight: FontWeight.w900),
      );
    } else if (rank == numberOfPlayers) {
      return Text(
        'LAST',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
      );
    } else {
      return Text(
        '#$rank',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
      );
    }
  }

  void _showEditPlayerDialog() {
    final controller = TextEditingController(text: widget.playerName);
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: Colors.green.shade800,
            ),
          ),
          child: AlertDialog(
            title: Text(
              widget.playerIndex != null
                  ? 'Edit Name of Player #${widget.playerIndex! + 1}'
                  : 'Edit Player Name',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                  decoration: InputDecoration(
                    hintText: 'Player Name',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.black,
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  color: Colors.white,
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onPlayerAdded?.call();
                },
                child: const Text('Add another player'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showRemoveConfirmationDialog();
                },
                child: const Text(
                  'Remove this player',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    widget.onNameChanged(controller.text);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRemoveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Player'),
          content:
              Text('Are you sure you want to remove "${widget.playerName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onPlayerRemoved();
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showEditPlayerDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 0.0),
        decoration: BoxDecoration(
          color: _getScoreColor(widget.rank, widget.numberOfPlayers)
              .withAlpha(100),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            SizedBox(
              height: 24,
              child: Center(
                child: _buildWiningPosition(
                  widget.rank,
                  widget.numberOfPlayers,
                ),
              ),
            ),
            Text(
              widget.playerName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.totalScore.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: _getScoreColor(widget.rank, widget.numberOfPlayers),
                shadows: <Shadow>[
                  const Shadow(
                    color: Colors.white54,
                    offset: Offset(-1, -1),
                    blurRadius: 2,
                  ),
                  const Shadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
