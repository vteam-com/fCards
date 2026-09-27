import 'package:cards/models/game/leaderboard_entry.dart';

/// A player's global leaderboard row and position.
class LeaderboardStanding {
  /// Creates a standing.
  const LeaderboardStanding({required this.entry, this.rank});

  /// The player's totals.
  final LeaderboardEntry entry;

  /// 1-based global position, or null when outside the loaded top rows.
  final int? rank;
}
