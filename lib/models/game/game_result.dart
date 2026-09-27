import 'package:cards/models/game/game_result_player.dart';

export 'package:cards/models/game/game_result_player.dart';

const String _tableNameNode = 'table_name';
const String _styleNode = 'style';
const String _endedAtNode = 'ended_at';
const String _playersNode = 'players';

/// Leaderboard style key for Score Keeper sheets.
const String scoreKeeperStyleKey = 'scoreKeeper';

/// Characters Firebase Realtime Database does not allow in keys.
final RegExp _invalidKeyCharacters = RegExp(r'[.#$\[\]/]');

/// Converts [value] into a string usable as a Realtime Database key.
String firebaseSafeKey(String value) =>
    value.trim().replaceAll(_invalidKeyCharacters, '_');

/// A finished game, as recorded for the leaderboards.
class GameResult {
  /// Creates a finished game result.
  const GameResult({
    required this.id,
    required this.tableKey,
    required this.tableName,
    required this.style,
    required this.endedAt,
    required this.players,
  });

  /// Builds a result from final scores; every lowest score is a win unless
  /// [winnerIndex] names the single winner (for example, a host-broken tie).
  ///
  /// [uids] follows [names] order; a missing or empty entry marks a
  /// name-only player.
  factory GameResult.fromScores({
    required String id,
    required String tableKey,
    required String tableName,
    required String style,
    required DateTime endedAt,
    required List<String> names,
    required List<int> scores,
    List<String> uids = const <String>[],
    int? winnerIndex,
  }) {
    final int count = names.length < scores.length
        ? names.length
        : scores.length;
    final int? lowest = count == 0
        ? null
        : scores.take(count).reduce((int a, int b) => a < b ? a : b);
    return GameResult(
      id: firebaseSafeKey(id),
      tableKey: firebaseSafeKey(tableKey),
      tableName: tableName,
      style: style,
      endedAt: endedAt,
      players: List<GameResultPlayer>.generate(
        count,
        (int index) => GameResultPlayer(
          name: names[index],
          uid: index < uids.length ? uids[index] : '',
          score: scores[index],
          isWinner: winnerIndex == null
              ? scores[index] == lowest
              : index == winnerIndex,
        ),
      ),
    );
  }

  /// Parses a result stored at `table_results/{tableKey}/{id}`.
  factory GameResult.fromValue(String tableKey, String id, Object? value) {
    if (value is! Map) {
      return GameResult(
        id: id,
        tableKey: tableKey,
        tableName: tableKey,
        style: '',
        endedAt: DateTime.fromMillisecondsSinceEpoch(0),
        players: const <GameResultPlayer>[],
      );
    }
    final Object? tableName = value[_tableNameNode];
    final Object? style = value[_styleNode];
    final Object? endedAt = value[_endedAtNode];
    final Object? players = value[_playersNode];
    final Iterable<Object?> playerValues = players is List
        ? players
        : players is Map
        ? players.values
        : const <Object?>[];
    return GameResult(
      id: id,
      tableKey: tableKey,
      tableName: tableName is String ? tableName : tableKey,
      style: style is String ? style : '',
      endedAt: DateTime.fromMillisecondsSinceEpoch(
        endedAt is num ? endedAt.toInt() : 0,
      ),
      players: playerValues
          .where((Object? player) => player != null)
          .map(GameResultPlayer.fromValue)
          .where((GameResultPlayer player) => player.name.isNotEmpty)
          .toList(),
    );
  }

  /// Unique game id, shared by every device that saw the game.
  final String id;

  /// Firebase-safe key of the room or score sheet.
  final String tableKey;

  /// Human-readable room or score sheet name.
  final String tableName;

  /// Game style key, such as `skyjo` or [scoreKeeperStyleKey].
  final String style;

  /// When the game finished.
  final DateTime endedAt;

  /// Every player's outcome, in seat order.
  final List<GameResultPlayer> players;

  /// Players who finished with the lowest score.
  Iterable<GameResultPlayer> get winners =>
      players.where((GameResultPlayer player) => player.isWinner);

  /// Returns this result with account ids from [other] filled in where this
  /// copy only knows the player's name.
  ///
  /// Each device of an online game only knows its own player's account, so
  /// results are merged as devices report in.
  GameResult mergeAccounts(GameResult other) {
    final Map<String, String> uidsByName = <String, String>{
      for (final GameResultPlayer player in other.players)
        if (player.hasAccount) player.name: player.uid,
    };
    return GameResult(
      id: id,
      tableKey: tableKey,
      tableName: tableName,
      style: style,
      endedAt: endedAt,
      players: players.map((GameResultPlayer player) {
        final String? uid = uidsByName[player.name];
        return player.hasAccount || uid == null ? player : player.withUid(uid);
      }).toList(),
    );
  }

  /// Serializes the result for Firebase.
  Map<String, Object> toValue() => <String, Object>{
    _tableNameNode: tableName,
    _styleNode: style,
    _endedAtNode: endedAt.millisecondsSinceEpoch,
    _playersNode: players
        .map((GameResultPlayer player) => player.toValue())
        .toList(),
  };
}
