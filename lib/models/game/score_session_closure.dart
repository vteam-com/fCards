const String _gameIdNode = 'game_id';
const String _winnerNameNode = 'winner_name';
const String _endedAtNode = 'ended_at';

/// Announces to everyone at a shared score sheet that a game was closed.
class ScoreSessionClosure {
  /// Creates a closure announcement.
  const ScoreSessionClosure({
    required this.gameId,
    required this.winnerName,
    required this.endedAt,
  });

  /// Parses the `closed_game` value of a score session, or null when absent.
  static ScoreSessionClosure? fromValue(Object? value) {
    if (value is! Map) {
      return null;
    }
    final Object? gameId = value[_gameIdNode];
    final Object? winnerName = value[_winnerNameNode];
    final Object? endedAt = value[_endedAtNode];
    if (gameId is! String || gameId.isEmpty || winnerName is! String) {
      return null;
    }
    return ScoreSessionClosure(
      gameId: gameId,
      winnerName: winnerName,
      endedAt: DateTime.fromMillisecondsSinceEpoch(
        endedAt is num ? endedAt.toInt() : 0,
      ),
    );
  }

  /// Leaderboard game id of the closed game.
  final String gameId;

  /// The single winner confirmed by the host.
  final String winnerName;

  /// When the host closed the game.
  final DateTime endedAt;

  /// Serializes the announcement for Firebase.
  Map<String, Object> toValue() => <String, Object>{
    _gameIdNode: gameId,
    _winnerNameNode: winnerName,
    _endedAtNode: endedAt.millisecondsSinceEpoch,
  };
}
