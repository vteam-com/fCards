import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:cards/widgets/helpers/table_widget.dart';
import 'package:flutter/material.dart';

/// Room selection and create-table section.
class StartScreenRoomSection extends StatelessWidget {
  /// Creates a [StartScreenRoomSection].
  const StartScreenRoomSection({
    required this.roomController,
    required this.isCreateTableNameStep,
    required this.isCheckingCreateTableName,
    required this.isExpandedRooms,
    required this.availableRooms,
    required this.doesTableNameExist,
    required this.onRoomChanged,
    required this.onRoomSubmitted,
    required this.onShowRoomsToggle,
    required this.onRoomSelected,
    required this.onContinuePressed,
    required this.onJoinExistingTable,
    required this.isCreateRoomFlow,
    required this.playerName,
    required this.roomName,
    this.errorStatus = '',
    this.onRemoveRoom,
    super.key,
  });

  /// List of available rooms.
  /// Builds the shortcut UI for redirecting to the join flow when a table exists.
  final List<String> availableRooms;

  /// Whether the entered table already exists.
  final bool doesTableNameExist;

  /// Optional error text.
  final String errorStatus;

  /// Whether a table availability lookup is in progress.
  final bool isCheckingCreateTableName;

  /// Whether this is the create-room flow.
  final bool isCreateRoomFlow;

  /// Whether the screen is currently on the table-name-only step.
  final bool isCreateTableNameStep;

  /// Whether the room list dropdown is expanded.
  final bool isExpandedRooms;

  /// Continue callback for the create flow.
  final VoidCallback onContinuePressed;

  /// Join callback when the checked table already exists.
  final VoidCallback onJoinExistingTable;

  /// Optional remove-room callback.
  final ValueChanged<String>? onRemoveRoom;

  /// Callback for room text changes.
  final ValueChanged<String> onRoomChanged;

  /// Callback when a room is chosen from the list.
  final ValueChanged<String> onRoomSelected;

  /// Callback when the room field is submitted.
  final VoidCallback onRoomSubmitted;

  /// Callback for expanding the room list.
  final VoidCallback onShowRoomsToggle;

  /// Active player name.
  final String playerName;

  /// Room controller.
  final TextEditingController roomController;

  /// Current normalized room name.
  final String roomName;
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      children: [
        if (isCreateTableNameStep)
          Padding(
            padding: const EdgeInsets.all(ConstLayout.paddingS),
            child: Text(
              l10n.enterTableName,
              style: TextStyle(
                fontSize: ConstLayout.textS,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: ConstLayout.sizeM),
        if (!isCreateRoomFlow || isCreateTableNameStep)
          Row(
            children: [
              Expanded(
                child: EditBox(
                  label: l10n.table,
                  controller: roomController,
                  onSubmitted: onRoomSubmitted,
                  onChanged: onRoomChanged,
                  errorStatus: errorStatus,
                  rightSideChild: isCreateRoomFlow
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: onShowRoomsToggle,
                          icon: Icon(
                            isExpandedRooms
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                ),
              ),
            ],
          ),
        if (isCreateRoomFlow && !isCreateTableNameStep)
          Padding(
            padding: const EdgeInsets.all(ConstLayout.paddingS),
            child: Text(
              l10n.tableLabel(roomName),
              style: TextStyle(
                fontSize: ConstLayout.textM,
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (!isCreateRoomFlow && isExpandedRooms)
          TableWidget(
            roomId: roomName,
            rooms: availableRooms,
            onSelected: onRoomSelected,
            onRemoveRoom: playerName == 'JP' ? onRemoveRoom : null,
          ),
        if (isCreateTableNameStep && isCheckingCreateTableName)
          const Padding(
            padding: EdgeInsets.all(ConstLayout.paddingS),
            child: SizedBox(
              width: ConstLayout.sizeXXL,
              height: ConstLayout.sizeXXL,
              child: CircularProgressIndicator(),
            ),
          ),
        if (_showJoinShortcut) _buildJoinExistingTableSection(context, l10n),
        if (isCreateTableNameStep && _canContinueToPlayerSetup)
          Padding(
            padding: const EdgeInsets.only(top: ConstLayout.paddingS),
            child: MyButtonRectangle(
              width: double.infinity,
              onTap: onContinuePressed,
              child: Text(
                l10n.next,
                style: TextStyle(
                  fontSize: ConstLayout.textM,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the shortcut UI for redirecting to the join flow when a table exists.
  Widget _buildJoinExistingTableSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        const SizedBox(height: ConstLayout.sizeM),
        Padding(
          padding: const EdgeInsets.all(ConstLayout.paddingS),
          child: Text(
            l10n.thisTableAlreadyHasPlayers,
            style: TextStyle(
              fontSize: ConstLayout.textS,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        MyButtonRectangle(
          width: double.infinity,
          onTap: onJoinExistingTable,
          child: Text(
            l10n.joinThisTable,
            style: TextStyle(
              fontSize: ConstLayout.textS,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(ConstLayout.paddingS),
          child: Text(
            l10n.enterTableName,
            style: TextStyle(
              fontSize: ConstLayout.textS,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  bool get _canContinueToPlayerSetup =>
      !doesTableNameExist && roomName.isNotEmpty && !isCheckingCreateTableName;
  bool get _showJoinShortcut =>
      isCreateTableNameStep &&
      doesTableNameExist &&
      roomName.isNotEmpty &&
      !isCheckingCreateTableName;
}
