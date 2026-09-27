/// A room or score sheet a player has leaderboard results at.
class LeaderboardTable {
  /// Creates a table reference.
  const LeaderboardTable({
    required this.key,
    required this.name,
    required this.lastPlayed,
  });

  /// Firebase-safe table key.
  final String key;

  /// Human-readable table name.
  final String name;

  /// When the player last finished a game at this table.
  final DateTime lastPlayed;
}
