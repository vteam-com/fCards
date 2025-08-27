import 'package:flutter/material.dart';

/// A widget for editing a player's name.
///
/// This widget displays the player's name. When the user taps on it, a dialog
/// appears to edit the name or remove the player.
class EditablePlayerName extends StatefulWidget {
  /// Creates an [EditablePlayerName] widget.
  const EditablePlayerName({
    super.key,
    required this.playerName,
    required this.color,
    required this.onNameChanged,
    required this.onPlayerRemoved,
  });

  /// The name of the player.
  final String playerName;

  /// Background color
  final Color color;

  /// A callback that is called when the player's name is changed.
  final void Function(String) onNameChanged;

  /// A callback that is called when the player is removed.
  final void Function() onPlayerRemoved;

  @override
  State<EditablePlayerName> createState() => _EditablePlayerNameState();
}

class _EditablePlayerNameState extends State<EditablePlayerName> {
  void _showEditPlayerDialog() {
    final controller = TextEditingController(text: widget.playerName);
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Player Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Player Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showRemoveConfirmationDialog();
              },
              child: const Text('Remove Player'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          widget.playerName,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
