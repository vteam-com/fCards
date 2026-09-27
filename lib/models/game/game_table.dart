import 'package:cards/models/game/game_result.dart';

const String _nameNode = 'name';
const String _gameTypeNode = 'game_type';
const String _playersNode = 'players';
const String _createdAtNode = 'created_at';
const String _lastPlayedNode = 'last_played';
const String _idSeparator = '|';

/// A group of players who play one game type together.
///
/// A table is identified by its game type and its exact set of players, so a
/// different group is always a different table. The [name] is generated when
/// the table is created and can be edited to make it easy to find again.
class GameTable {
  /// Creates a table.
  const GameTable({
    required this.id,
    required this.name,
    required this.gameType,
    required this.players,
    required this.createdAt,
    this.lastPlayed,
  });

  /// Parses a table stored at `tables/{id}`, or null when absent.
  static GameTable? fromValue(String id, Object? value) {
    if (value is! Map) {
      return null;
    }
    final Object? name = value[_nameNode];
    final GameStyles? gameType = GameStyles.values
        .asNameMap()[value[_gameTypeNode]];
    final Object? players = value[_playersNode];
    final Object? createdAt = value[_createdAtNode];
    final Object? lastPlayed = value[_lastPlayedNode];
    if (name is! String || gameType == null) {
      return null;
    }
    return GameTable(
      id: id,
      name: name,
      gameType: gameType,
      players: players is List
          ? players.whereType<String>().toList()
          : const <String>[],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        createdAt is num ? createdAt.toInt() : 0,
      ),
      lastPlayed: lastPlayed is num
          ? DateTime.fromMillisecondsSinceEpoch(lastPlayed.toInt())
          : null,
    );
  }

  /// Derived from [gameType] and [players]; see [idFor].
  final String id;

  /// Editable display name, unique among tables.
  final String name;

  /// The one game played at this table.
  final GameStyles gameType;

  /// Normalized player names; see [normalizePlayers].
  final List<String> players;

  /// When the table was created.
  final DateTime createdAt;

  /// When a game last finished at this table.
  final DateTime? lastPlayed;

  /// Trims, upper-cases, de-duplicates, and sorts player names.
  static List<String> normalizePlayers(Iterable<String> players) =>
      players
          .map((String player) => player.trim().toUpperCase())
          .where((String player) => player.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  /// Normalizes a table name typed by a player.
  static String normalizeName(String name) =>
      name.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');

  /// The id of the table for [gameType] played by exactly [players].
  static String idFor(GameStyles gameType, Iterable<String> players) =>
      firebaseSafeKey(
        <String>[
          gameType.name,
          ...normalizePlayers(players),
        ].join(_idSeparator),
      );

  /// Serializes the table for Firebase.
  Map<String, Object> toValue() => <String, Object>{
    _nameNode: name,
    _gameTypeNode: gameType.name,
    _playersNode: players,
    _createdAtNode: createdAt.millisecondsSinceEpoch,
    _lastPlayedNode: ?lastPlayed?.millisecondsSinceEpoch,
  };
}
