const String _nameNode = 'name';
const String _uidNode = 'uid';
const String _scoreNode = 'score';
const String _winnerNode = 'winner';

/// One player's outcome in a finished game.
class GameResultPlayer {
  /// Creates a player outcome.
  const GameResultPlayer({
    required this.name,
    required this.score,
    required this.isWinner,
    this.uid = '',
  });

  /// Parses a player outcome stored under `table_results`.
  factory GameResultPlayer.fromValue(Object? value) {
    if (value is! Map) {
      return const GameResultPlayer(name: '', score: 0, isWinner: false);
    }
    final Object? name = value[_nameNode];
    final Object? uid = value[_uidNode];
    final Object? score = value[_scoreNode];
    return GameResultPlayer(
      name: name is String ? name : '',
      uid: uid is String ? uid : '',
      score: score is num ? score.toInt() : 0,
      isWinner: value[_winnerNode] == true,
    );
  }

  /// Name shown for the player at the table.
  final String name;

  /// Firebase account id, or empty for name-only players.
  final String uid;

  /// Final score; lower is better.
  final int score;

  /// Whether the player had the lowest score.
  final bool isWinner;

  /// Whether the player is linked to a Firebase account.
  bool get hasAccount => uid.isNotEmpty;

  /// Returns a copy linked to [accountUid].
  GameResultPlayer withUid(String accountUid) => GameResultPlayer(
    name: name,
    uid: accountUid,
    score: score,
    isWinner: isWinner,
  );

  /// Serializes the outcome for Firebase.
  Map<String, Object> toValue() => <String, Object>{
    _nameNode: name,
    _uidNode: uid,
    _scoreNode: score,
    _winnerNode: isWinner,
  };
}
