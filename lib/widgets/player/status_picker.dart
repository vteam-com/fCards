import 'package:cards/models/base/player_status.dart';
import 'package:flutter/material.dart';

class StatusPicker extends StatefulWidget {
  const StatusPicker({
    super.key,
    required this.status,
    required this.onStatusChanged,
  });
  final PlayerStatus status;
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
            children: [
              Text(
                status.emoji,
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                status.phrase,
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
