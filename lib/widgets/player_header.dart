// ignore: fcheck_magic_numbers

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

  /// The total number of players.
  final int numberOfPlayers;

  /// A callback that is called when the player's name is changed.
  final void Function(String) onNameChanged;

  /// A callback that is called when a new player should be added.
  final void Function()? onPlayerAdded;

  /// A callback that is called when the player is removed.
  final void Function() onPlayerRemoved;

  /// The index of the player.
  final int? playerIndex;

  /// The name of the player.
  final String playerName;

  /// The rank of the player.
  final int rank;

  /// The total score of the player.
  final int totalScore;

  @override
  State<PlayerHeader> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends State<PlayerHeader> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _getScoreColor(
          widget.rank,
          widget.numberOfPlayers,
        ).withAlpha(150),
      ),
      onPressed: _showEditPlayerDialog,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          //
          // Running place King,2,3,4,Last
          //
          SizedBox(
            height: 24,
            child: Center(
              child: _buildWiningPosition(widget.rank, widget.numberOfPlayers),
            ),
          ),

          //
          // Name of the Player
          //
          Text(
            widget.playerName,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),

          //
          // Score
          //
          SizedBox(
            height: 30,
            child: FittedBox(
              child: Text(
                widget.totalScore.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  // Make the score color brighter by blending with white
                  color: Color.alphaBlend(
                    Colors.white.withAlpha(200),
                    _getScoreColor(widget.rank, widget.numberOfPlayers),
                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWiningPosition(int rank, int numberOfPlayers) {
    if (rank == 1) {
      return Text('👑', style: TextStyle(fontWeight: FontWeight.w900));
    } else if (rank == numberOfPlayers) {
      return Opacity(
        opacity: 0.5,
        child: Text(
          'LAST',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
      );
    } else {
      return Opacity(
        opacity: 0.7,
        child: Text(
          '#$rank',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
      );
    }
  }

  Color _getScoreColor(int rank, int numberOfPlayers) {
    if (rank == 1) {
      return Colors.green.shade300;
    } else if (rank == numberOfPlayers) {
      return Colors.red.shade300;
    } else {
      return Colors.orange.shade300;
    }
  }

  void _showEditPlayerDialog() {
    final controller = TextEditingController(text: widget.playerName);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
    final focusNode = FocusNode();
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
            backgroundColor: Colors.green.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.green.shade300, width: 1),
            ),
            title: Text(
              widget.playerIndex != null
                  ? 'Name for Player #${widget.playerIndex! + 1}'
                  : 'Player Name',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  style: TextStyle(color: Colors.white, fontSize: 30),
                  decoration: InputDecoration(
                    hintText: 'Player Name',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.black,
                    border: const OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      widget.onNameChanged(controller.text);
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
                Divider(color: Colors.green),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onPlayerAdded?.call();
                      },
                      child: const Text(
                        'Add another player',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showRemoveConfirmationDialog();
                      },
                      child: Text(
                        'Remove this player',
                        style: TextStyle(color: Colors.red.shade200),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (mounted) {
      focusNode.requestFocus();
    }
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      }
    });
  }

  void _showRemoveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.green.shade600, width: 1),
          ),
          title: const Text('Remove Player'),
          content: Text(
            'Are you sure you want to remove "${widget.playerName}"?',
          ),
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
}
