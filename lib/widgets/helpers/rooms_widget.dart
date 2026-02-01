// ignore: fcheck_magic_numbers

import 'package:flutter/material.dart';

/// A widget that displays a list of rooms, allowing the user to select a room and optionally remove a room.
class RoomsWidget extends StatelessWidget {
  /// Constructs a [RoomsWidget] with the given parameters.
  ///
  /// The [roomId], [rooms], [onSelected], and [onRemoveRoom] parameters are required.
  const RoomsWidget({
    super.key,
    required this.roomId,
    required this.rooms,
    required this.onSelected,
    required this.onRemoveRoom,
  });

  /// Optional callback function called when a room is removed.
  /// Takes the room name to remove as a parameter.
  /// If null, room removal functionality will be disabled.
  final Function(String)? onRemoveRoom;

  /// Callback function called when a room is selected.
  /// Takes the selected room's name as a parameter.
  final Function(String) onSelected;

  /// The ID of the currently selected room.
  final String roomId;

  /// The list of room names to display.
  final List<String> rooms;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          String nameToDisplay = rooms[index];
          return ListTile(
            title: TextButton(
              onPressed: () => onSelected(rooms[index]),
              child: Text(nameToDisplay, style: const TextStyle(fontSize: 20)),
            ),
            leading: SizedBox(
              width: 40,
              child: nameToDisplay == roomId ? Icon(Icons.check) : null,
            ),
            trailing: onRemoveRoom == null
                ? null
                : IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red.shade300),
                    onPressed: () => onRemoveRoom!(rooms[index]),
                  ),
          );
        },
      ),
    );
  }
}
