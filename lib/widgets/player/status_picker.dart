import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/my_text.dart';
import 'package:cards/models/player/player_status.dart';
import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

///
class StatusPicker extends StatefulWidget {
  ///
  const StatusPicker({
    super.key,
    required this.status,
    required this.onStatusChanged,
  });

  /// Callback function that is called when the player's status changes
  final Function(PlayerStatus) onStatusChanged;

  /// The current status of the player
  final PlayerStatus status;

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
    final AppLocalizations localizations = AppLocalizations.of(context);
    return DropdownButton<PlayerStatus>(
      value: selectedStatus,
      hint: Text(localizations.selectAStatus),
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
            spacing: ConstLayout.sizeS,
            children: [
              MyText(
                status.emoji,
                fontSize: ConstLayout.sizeM,
                color: Colors.yellow,
                bold: true,
              ),

              MyText(
                status.phrase,
                fontSize: ConstLayout.sizeM,
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
