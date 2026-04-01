import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/screens/game/join_game_screen.dart';
import 'package:flutter/material.dart';

/// Table lookup data for create-table validation.
class TableNameLookupResult {
  ///
  const TableNameLookupResult({required this.exists, required this.rooms});

  /// Whether the provided table already exists.
  final bool exists;

  /// Current backend room list.
  final List<String> rooms;
}

/// Loads room names and checks if [normalizedTableName] already exists.
Future<TableNameLookupResult> lookupTableNameAvailability(
  String normalizedTableName,
) async {
  if (isRunningOffLine) {
    return const TableNameLookupResult(exists: false, rooms: <String>[]);
  }

  await useFirebase();
  final List<String> rooms = await getAllRooms();
  return TableNameLookupResult(
    exists: rooms.contains(normalizedTableName),
    rooms: rooms,
  );
}

/// Opens the join flow for [tableName] and selected [gameStyle].
void openJoinFlowForTable({
  required BuildContext context,
  required String tableName,
  required GameStyles gameStyle,
}) {
  if (tableName.isEmpty) {
    return;
  }
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (BuildContext _) =>
          JoinGameScreen(initialRoom: tableName, gameStyle: gameStyle),
    ),
  );
}
