import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:flutter/material.dart';

/// A widget that displays a list of rooms, allowing the user to select a room and optionally remove a room.
/// Includes a search box to filter rooms by name.
class RoomsWidget extends StatefulWidget {
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
  State<RoomsWidget> createState() => _RoomsWidgetState();
}

class _RoomsWidgetState extends State<RoomsWidget> {
  late TextEditingController _searchController;

  late String _searchText;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchText = '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRooms = _getFilteredRooms();

    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;

    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.all(Radius.circular(ConstLayout.radiusM)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(ConstLayout.sizeM),
            child: EditBox(
              controller: _searchController,
              onSubmitted: () {
                // If search matches exactly one room, select it
                if (filteredRooms.length == 1) {
                  widget.onSelected(filteredRooms[0]);
                }
              },
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              errorStatus: '',
              rightSideChild: const SizedBox.shrink(),
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.onSurfaceHint,
                size: ConstLayout.iconM,
              ),
            ),
          ),

          // Divider
          Divider(),

          // Room List
          Expanded(
            child: filteredRooms.isEmpty
                ? _buildEmptyState(colorScheme)
                : ListView.builder(
                    itemCount: filteredRooms.length,
                    itemBuilder: (BuildContext _, int index) {
                      final roomName = filteredRooms[index];
                      return _buildRoomItem(roomName);
                    },
                  ),
          ),

          // Search hint
          if (_searchText.isNotEmpty && filteredRooms.isEmpty)
            Padding(
              padding: const EdgeInsets.all(ConstLayout.sizeM),
              child: Text(
                'No rooms found matching "$_searchText"',
                style: TextStyle(
                  color: AppTheme.onSurfaceHint,
                  fontSize: ConstLayout.textS,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme _) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.meeting_room,
            size: ConstLayout.iconL,
            color: AppTheme.panelInputZone,
          ),
          const SizedBox(height: ConstLayout.sizeM),
          Text(
            _searchText.isEmpty ? 'No rooms available' : 'No matching rooms',
            style: TextStyle(
              color: AppTheme.onSurfaceHint,
              fontSize: ConstLayout.textM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomItem(String roomName) {
    final isSelected = roomName == widget.roomId;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ConstLayout.sizeM,
        vertical: ConstLayout.sizeXS,
      ),
      leading: SizedBox(
        width: ConstLayout.sizeXL,
        child: isSelected
            ? Icon(Icons.check, color: colorScheme.tertiary)
            : null,
      ),
      title: TextButton(
        onPressed: () => widget.onSelected(roomName),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: ConstLayout.sizeS,
            horizontal: ConstLayout.sizeM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ConstLayout.radiusS),
          ),
          backgroundColor: isSelected
              ? colorScheme.primaryContainer.withAlpha(
                  ConstLayout.selectedRoomBackgroundAlpha,
                )
              : colorScheme.surface.withAlpha(0),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            roomName,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: ConstLayout.textM,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
      trailing: widget.onRemoveRoom == null
          ? null
          : IconButton(
              icon: Icon(
                Icons.remove_circle,
                color: colorScheme.error,
                size: ConstLayout.iconS,
              ),
              onPressed: () => widget.onRemoveRoom!(roomName),
            ),
    );
  }

  List<String> _getFilteredRooms() {
    if (_searchText.isEmpty) {
      return widget.rooms;
    }

    return widget.rooms
        .where((room) => room.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
  }
}
