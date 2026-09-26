/// Shared Score Keeper state synchronized between QR-session participants.
class ScoreSessionState {
  /// Creates a normalized score-session snapshot.
  const ScoreSessionState({
    required this.playerIds,
    required this.playerNames,
    required this.scores,
  });

  /// Firebase user IDs in score-column order.
  final List<String> playerIds;

  /// Displayed player names in score-column order.
  final List<String> playerNames;

  /// Round scores, where each inner list follows [playerIds] order.
  final List<List<int>> scores;

  /// Parses a Firebase Realtime Database score-state value.
  factory ScoreSessionState.fromValue(Object? value) {
    if (value is! Map) {
      return const ScoreSessionState(
        playerIds: [],
        playerNames: [],
        scores: [],
      );
    }
    return ScoreSessionState(
      playerIds: _stringList(value['player_ids']),
      playerNames: _stringList(value['player_names']),
      scores: _scoreList(value['scores']),
    );
  }

  /// Serializes this state for Firebase Realtime Database.
  Map<String, Object> toValue() => <String, Object>{
    'player_ids': playerIds,
    'player_names': playerNames,
    'scores': scores,
  };

  static List<String> _stringList(Object? value) {
    if (value is! List) return <String>[];
    return value.whereType<String>().toList();
  }

  static List<List<int>> _scoreList(Object? value) {
    if (value is! List) return <List<int>>[];
    return value.whereType<List>().map((List<dynamic> round) {
      return round
          .map((dynamic score) => (score as num?)?.toInt() ?? 0)
          .toList();
    }).toList();
  }
}
