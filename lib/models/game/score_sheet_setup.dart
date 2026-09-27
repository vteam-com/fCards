import 'package:cards/models/game/game_styles.dart';

/// How a new physical-card score sheet starts.
class ScoreSheetSetup {
  /// Creates a setup for a new sheet.
  const ScoreSheetSetup({
    required this.gameType,
    required this.tableName,
    required this.players,
    this.sessionId,
  });

  /// Game being scored.
  final GameStyles gameType;

  /// Reopened table's name, or the proposed name of a new table.
  final String tableName;

  /// Starting player columns; empty keeps the default columns.
  final List<String> players;

  /// Shared sheet the players already joined, if any.
  final String? sessionId;
}
