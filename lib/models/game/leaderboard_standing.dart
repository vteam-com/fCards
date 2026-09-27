import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/game/leaderboard_entry.dart';

/// A player's global leaderboard row and position for one game type.
class LeaderboardStanding {
  /// Creates a standing.
  const LeaderboardStanding({
    required this.gameType,
    required this.entry,
    this.rank,
  });

  /// Game type the totals are for.
  final GameStyles gameType;

  /// The player's totals.
  final LeaderboardEntry entry;

  /// 1-based global position, or null when outside the loaded top rows.
  final int? rank;
}
