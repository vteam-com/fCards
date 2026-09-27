import 'package:cards/models/game/game_result.dart';

const String _nameNode = 'name';
const String _avatarUrlNode = 'avatar_url';
const String _gamesPlayedNode = 'games_played';
const String _winsNode = 'wins';
const String _totalScoreNode = 'total_score';
const String _bestScoreNode = 'best_score';
const String _lastPlayedNode = 'last_played';

/// Firebase child ordered on when querying the global leaderboard.
const String leaderboardWinsNode = _winsNode;

/// Prefix for table-board keys of players without an account.
const String _namePlayerKeyPrefix = 'name:';

/// A player's accumulated results on a leaderboard.
class LeaderboardEntry {
  /// Creates a leaderboard row.
  const LeaderboardEntry({
    required this.playerKey,
    required this.name,
    this.avatarUrl = '',
    this.gamesPlayed = 0,
    this.wins = 0,
    this.totalScore = 0,
    this.bestScore,
    this.lastPlayed,
  });

  /// Parses a row stored at `leaderboard/{style}/{uid}`.
  factory LeaderboardEntry.fromValue(String playerKey, Object? value) {
    if (value is! Map) {
      return LeaderboardEntry(playerKey: playerKey, name: '');
    }
    final Object? name = value[_nameNode];
    final Object? avatarUrl = value[_avatarUrlNode];
    final Object? bestScore = value[_bestScoreNode];
    final Object? lastPlayed = value[_lastPlayedNode];
    return LeaderboardEntry(
      playerKey: playerKey,
      name: name is String ? name : '',
      avatarUrl: avatarUrl is String ? avatarUrl : '',
      gamesPlayed: _intValue(value[_gamesPlayedNode]),
      wins: _intValue(value[_winsNode]),
      totalScore: _intValue(value[_totalScoreNode]),
      bestScore: bestScore is num ? bestScore.toInt() : null,
      lastPlayed: lastPlayed is num
          ? DateTime.fromMillisecondsSinceEpoch(lastPlayed.toInt())
          : null,
    );
  }

  /// Account uid, or `name:NAME` for name-only players on a table board.
  final String playerKey;

  /// Name shown on the leaderboard.
  final String name;

  /// Profile photo URL, when the account shares one.
  final String avatarUrl;

  /// Number of games finished.
  final int gamesPlayed;

  /// Number of games finished with the lowest score.
  final int wins;

  /// Sum of every final score.
  final int totalScore;

  /// Lowest final score, or null before the first game.
  final int? bestScore;

  /// When the player last finished a game.
  final DateTime? lastPlayed;

  /// Share of games won, from 0 to 1.
  double get winRate => gamesPlayed == 0 ? 0 : wins / gamesPlayed;

  /// Mean final score, or null before the first game.
  double? get averageScore =>
      gamesPlayed == 0 ? null : totalScore / gamesPlayed;

  /// Returns this entry updated with one more finished game.
  LeaderboardEntry withResult(
    GameResultPlayer player,
    DateTime endedAt, {
    String? avatarUrl,
  }) {
    final int? best = bestScore;
    final DateTime? last = lastPlayed;
    final bool isLatest = last == null || !endedAt.isBefore(last);
    return LeaderboardEntry(
      playerKey: playerKey,
      name: isLatest || name.isEmpty ? player.name : name,
      avatarUrl: avatarUrl != null && avatarUrl.isNotEmpty
          ? avatarUrl
          : this.avatarUrl,
      gamesPlayed: gamesPlayed + 1,
      wins: wins + (player.isWinner ? 1 : 0),
      totalScore: totalScore + player.score,
      bestScore: best == null || player.score < best ? player.score : best,
      lastPlayed: isLatest ? endedAt : last,
    );
  }

  /// Serializes the entry for Firebase.
  Map<String, Object> toValue() => <String, Object>{
    _nameNode: name,
    _avatarUrlNode: avatarUrl,
    _gamesPlayedNode: gamesPlayed,
    _winsNode: wins,
    _totalScoreNode: totalScore,
    _bestScoreNode: ?bestScore,
    _lastPlayedNode: ?lastPlayed?.millisecondsSinceEpoch,
  };

  /// Sorts [entries] best first: most wins, then win rate, games played,
  /// lowest average, and name.
  static List<LeaderboardEntry> rank(Iterable<LeaderboardEntry> entries) {
    return entries
        .where((LeaderboardEntry entry) => entry.gamesPlayed > 0)
        .toList()
      ..sort((LeaderboardEntry a, LeaderboardEntry b) {
        int order = b.wins.compareTo(a.wins);
        if (order != 0) return order;
        order = b.winRate.compareTo(a.winRate);
        if (order != 0) return order;
        order = b.gamesPlayed.compareTo(a.gamesPlayed);
        if (order != 0) return order;
        order = (a.averageScore ?? 0).compareTo(b.averageScore ?? 0);
        if (order != 0) return order;
        return a.name.compareTo(b.name);
      });
  }

  /// Builds a ranked table board from [results].
  ///
  /// Account players are grouped by uid; name-only players by upper-cased
  /// name, so the same person typing their name each game still adds up.
  static List<LeaderboardEntry> aggregate(Iterable<GameResult> results) {
    final Map<String, LeaderboardEntry> entries = <String, LeaderboardEntry>{};
    for (final GameResult result in results) {
      for (final GameResultPlayer player in result.players) {
        final String key = player.hasAccount
            ? player.uid
            : '$_namePlayerKeyPrefix${player.name.trim().toUpperCase()}';
        final LeaderboardEntry current =
            entries[key] ?? LeaderboardEntry(playerKey: key, name: player.name);
        entries[key] = current.withResult(player, result.endedAt);
      }
    }
    return rank(entries.values);
  }

  static int _intValue(Object? value) => value is num ? value.toInt() : 0;
}
