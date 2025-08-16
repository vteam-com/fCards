import 'package:flutter/material.dart';

/// A widget for editing a player's name.
///
/// This widget displays a text field with the player's name. When the user
/// taps on the text field, it becomes editable. If the user clears the text
/// field and it loses focus, a confirmation dialog is shown to confirm the
/// removal of the player.
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
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late String _originalName;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.playerName);
    _originalName = widget.playerName;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      if (_controller.text.isEmpty) {
        _showConfirmationDialog();
      } else {
        widget.onNameChanged(_controller.text);
      }
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Player'),
          content: Text('Are you sure you want to remove "$_originalName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Remove'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onPlayerRemoved();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.text,
      focusNode: _focusNode,
      decoration: InputDecoration(
        fillColor: widget.color,
        hintText: 'Enter player name',
      ),
      onSubmitted: (value) {
        widget.onNameChanged(value);
      },
    );
  }
}
