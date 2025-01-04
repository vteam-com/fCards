import 'package:cards/misc.dart';
import 'package:cards/models/player_status.dart';
import 'package:flutter/material.dart';

///
class StatusPicker extends StatefulWidget {
  ///
  const StatusPicker({
    super.key,
    required this.status,
    required this.onStatusChanged,
  });

  /// The current status of the player
  final PlayerStatus status;

  /// Callback function that is called when the player's status changes
  final Function(PlayerStatus) onStatusChanged;

  @override
  State<StatusPicker> createState() => _StatusPickerState();
}

class _StatusPickerState extends State<StatusPicker> {
  late PlayerStatus selectedStatus = findMatchingPlayerStatusInstance(
    widget.status.emoji,
    widget.status.phrase,
  );

  @override
  Widget build(BuildContext context) {
    return DropdownButton<PlayerStatus>(
      value: selectedStatus,
      hint: const Text('Select a status'),
      onChanged: (PlayerStatus? newValue) {
        setState(() {
          selectedStatus = newValue!;
        });
        if (newValue != null) {
          widget.onStatusChanged(newValue);
        }
      },
      items: playersStatuses.map((status) {
        return DropdownMenuItem<PlayerStatus>(
          value: status,
          onTap: () {
            setState(() {
              selectedStatus = status;
            });
            widget.onStatusChanged(status);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextSize(
                status.emoji,
                20,
                color: Colors.yellow,
                bold: true,
              ),
              SizedBox(width: 8),
              TextSize(
                status.phrase,
                16,
                color: Colors.yellow,
                bold: true,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
