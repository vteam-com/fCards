import 'package:cards/models/app/constants.dart';
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

    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: Constants.backgroundContainer,
        borderRadius: BorderRadius.all(Radius.circular(Constants.radiusM)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(Constants.sizeM),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: Constants.textM,
              ),
              decoration: InputDecoration(
                hintText: 'Search rooms...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.black.withAlpha(Constants.searchBoxFillAlpha),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Constants.radiusM),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Constants.sizeM,
                  vertical: Constants.sizeS,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              onSubmitted: (value) {
                // If search matches exactly one room, select it
                if (filteredRooms.length == 1) {
                  widget.onSelected(filteredRooms[0]);
                }
              },
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: Colors.white.withAlpha(Constants.dividerAlpha),
            thickness: 1,
          ),

          // Room List
          Expanded(
            child: filteredRooms.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final roomName = filteredRooms[index];
                      return _buildRoomItem(roomName);
                    },
                  ),
          ),

          // Search hint
          if (_searchText.isNotEmpty && filteredRooms.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Constants.sizeM),
              child: Text(
                'No rooms found matching "$_searchText"',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: Constants.textS,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.meeting_room,
            size: Constants.iconL,
            color: Colors.white70,
          ),
          const SizedBox(height: Constants.sizeM),
          Text(
            _searchText.isEmpty ? 'No rooms available' : 'No matching rooms',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: Constants.textM,
            ),
          ),
          if (_searchText.isNotEmpty)
            Text(
              'Try a different search term',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: Constants.textS,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomItem(String roomName) {
    final isSelected = roomName == widget.roomId;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Constants.sizeM,
        vertical: Constants.sizeXS,
      ),
      leading: SizedBox(
        width: Constants.roomItemLeadingWidth,
        child: isSelected
            ? Icon(Icons.check, color: Colors.green.shade400)
            : null,
      ),
      title: TextButton(
        onPressed: () => widget.onSelected(roomName),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: Constants.sizeS,
            horizontal: Constants.sizeM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.radiusS),
          ),
          backgroundColor: isSelected
              ? Colors.green.shade800.withAlpha(
                  Constants.selectedRoomBackgroundAlpha,
                )
              : Colors.transparent,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            roomName,
            style: TextStyle(
              color: Colors.white,
              fontSize: Constants.textM,
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
                color: Colors.red.shade300,
                size: Constants.iconS,
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
