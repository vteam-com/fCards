import 'dart:math';

import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/card_medium.dart';
import 'package:cards/models/game/firebase_table_store.dart';
import 'package:cards/models/game/game_lobby.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/game/game_table.dart';
import 'package:cards/models/game/memory_table_store.dart';
import 'package:cards/models/game/table_names.dart';
import 'package:cards/models/game/table_rename_result.dart';
import 'package:cards/models/game/table_store.dart';
import 'package:cards/utils/logger.dart';

export 'package:cards/models/game/card_medium.dart';
export 'package:cards/models/game/game_lobby.dart';
export 'package:cards/models/game/game_table.dart';
export 'package:cards/models/game/table_rename_result.dart';

const String _tablesNode = 'tables';
const String _lobbiesNode = 'lobbies';
const String _playerTablesNode = 'player_tables';
const String _nameChild = 'name';
const String _tableIdChild = 'table_id';
const String _createdAtChild = 'created_at';
const String _lastPlayedChild = 'last_played';
const int _nameAttempts = 13;
const int _recentLobbyLimit = 34;
const int _idRadix = 36;
const int _idRandomRange = 1296;

/// Finds, creates, and renames tables and the lobbies that lead to them.
class TableService {
  static TableStore? _store;

  /// Storage used by the service; in memory while running offline.
  static TableStore get store =>
      _store ??= isRunningOffLine ? MemoryTableStore() : FirebaseTableStore();

  /// Replaces the storage, for tests.
  static set store(TableStore value) => _store = value;

  /// Loads the table with [id], or null.
  static Future<GameTable?> getTable(String id) async {
    try {
      return GameTable.fromValue(id, await store.read('$_tablesNode/$id'));
    } catch (error) {
      logger.w('getTable failed: $error');
      return null;
    }
  }

  /// Finds the table where exactly [players] play [gameType], or null.
  static Future<GameTable?> findTable(
    GameStyles gameType,
    Iterable<String> players,
  ) {
    if (GameTable.normalizePlayers(players).isEmpty) {
      return Future<GameTable?>.value();
    }
    return getTable(GameTable.idFor(gameType, players));
  }

  /// Returns the table for [gameType] and exactly [players], creating it with
  /// [proposedName] (or a fresh name when that one is taken) if it is new.
  static Future<GameTable> resolveTable({
    required GameStyles gameType,
    required Iterable<String> players,
    String proposedName = '',
  }) async {
    final String id = GameTable.idFor(gameType, players);
    final GameTable? existing = await getTable(id);
    if (existing != null) {
      return existing;
    }
    final String wanted = GameTable.normalizeName(proposedName);
    final String name = wanted.isNotEmpty && !await _isTableNameTaken(wanted)
        ? wanted
        : await proposeName();
    final GameTable table = GameTable(
      id: id,
      name: name,
      gameType: gameType,
      players: GameTable.normalizePlayers(players),
      createdAt: DateTime.now(),
    );
    try {
      final Object? stored = await store.createIfAbsent(
        '$_tablesNode/$id',
        table.toValue(),
      );
      return GameTable.fromValue(id, stored) ?? table;
    } catch (error) {
      logger.w('resolveTable failed: $error');
      return table;
    }
  }

  /// Renames table [id]; names are unique among tables.
  static Future<TableRenameResult> renameTable(String id, String name) async {
    final String normalized = GameTable.normalizeName(name);
    if (normalized.isEmpty) {
      return TableRenameResult.invalid;
    }
    if (await _isTableNameTaken(normalized, exceptTableId: id)) {
      return TableRenameResult.taken;
    }
    await store.write('$_tablesNode/$id/$_nameChild', normalized);
    return TableRenameResult.renamed;
  }

  /// Checks a name typed for a table that does not exist yet.
  static Future<TableRenameResult> checkNewName(String name) async {
    final String normalized = GameTable.normalizeName(name);
    if (normalized.isEmpty) {
      return TableRenameResult.invalid;
    }
    return await _isTableNameTaken(normalized)
        ? TableRenameResult.taken
        : TableRenameResult.renamed;
  }

  /// Returns an unused two-word table name.
  static Future<String> proposeName() async {
    String name = TableNames.generate();
    for (int attempt = 0; attempt < _nameAttempts; attempt++) {
      if (!await _isTableNameTaken(name) && !await _isLobbyNameTaken(name)) {
        return name;
      }
      name = TableNames.generate();
    }
    return name;
  }

  /// Opens a lobby for [gameType] and [cards], reopening [table] when given.
  static Future<GameLobby> openLobby({
    required GameStyles gameType,
    required CardMedium cards,
    GameTable? table,
    String? name,
  }) async {
    final GameLobby lobby = GameLobby(
      id: _newId(),
      name: table?.name ?? GameTable.normalizeName(name ?? await proposeName()),
      gameType: gameType,
      cards: cards,
      tableId: table?.id,
      createdAt: DateTime.now(),
    );
    try {
      await store.write('$_lobbiesNode/${lobby.id}', lobby.toValue());
    } catch (error) {
      logger.w('openLobby failed: $error');
    }
    return lobby;
  }

  /// Loads the lobby with [id], or null.
  static Future<GameLobby?> getLobby(String id) async {
    try {
      return GameLobby.fromValue(id, await store.read('$_lobbiesNode/$id'));
    } catch (error) {
      logger.w('getLobby failed: $error');
      return null;
    }
  }

  /// Emits the lobby with [id] now and whenever it changes.
  static Stream<GameLobby?> watchLobby(String id) => store
      .watch('$_lobbiesNode/$id')
      .map((Object? value) => GameLobby.fromValue(id, value));

  /// Renames [lobby]; the name must not belong to another table.
  static Future<TableRenameResult> renameLobby(
    GameLobby lobby,
    String name,
  ) async {
    final String normalized = GameTable.normalizeName(name);
    if (normalized.isEmpty) {
      return TableRenameResult.invalid;
    }
    if (await _isTableNameTaken(normalized, exceptTableId: lobby.tableId)) {
      return TableRenameResult.taken;
    }
    await store.write('$_lobbiesNode/${lobby.id}/$_nameChild', normalized);
    return TableRenameResult.renamed;
  }

  /// Points [lobby] at the [table] its players were matched to, so people
  /// searching for the table's name find this lobby.
  static Future<void> attachLobby(GameLobby lobby, GameTable table) async {
    try {
      await store.write('$_lobbiesNode/${lobby.id}/$_nameChild', table.name);
      await store.write('$_lobbiesNode/${lobby.id}/$_tableIdChild', table.id);
    } catch (error) {
      logger.w('attachLobby failed: $error');
    }
  }

  /// Lobbies named [name] using [cards], most recent first.
  static Future<List<GameLobby>> findLobbies(
    String name, {
    required CardMedium cards,
  }) async {
    try {
      final Map<String, Object?> found = await store.whereEquals(
        _lobbiesNode,
        _nameChild,
        GameTable.normalizeName(name),
      );
      return _sortedLobbies(found, cards);
    } catch (error) {
      logger.w('findLobbies failed: $error');
      return <GameLobby>[];
    }
  }

  /// Most recently opened lobbies using [cards].
  static Future<List<GameLobby>> recentLobbies({
    required CardMedium cards,
  }) async {
    try {
      return _sortedLobbies(
        await store.latest(_lobbiesNode, _createdAtChild, _recentLobbyLimit),
        cards,
      );
    } catch (error) {
      logger.w('recentLobbies failed: $error');
      return <GameLobby>[];
    }
  }

  /// Tables [uid] has played at, most recent first, optionally of one type.
  static Future<List<GameTable>> tablesForPlayer(
    String uid, {
    GameStyles? gameType,
  }) async {
    if (uid.isEmpty) {
      return <GameTable>[];
    }
    try {
      final Object? value = await store.read('$_playerTablesNode/$uid');
      if (value is! Map) {
        return <GameTable>[];
      }
      final List<GameTable?> tables = await Future.wait(
        value.keys.map((Object? id) => getTable('$id')),
      );
      return tables
          .whereType<GameTable>()
          .where(
            (GameTable table) => gameType == null || table.gameType == gameType,
          )
          .toList()
        ..sort(
          (GameTable a, GameTable b) => (b.lastPlayed ?? b.createdAt).compareTo(
            a.lastPlayed ?? a.createdAt,
          ),
        );
    } catch (error) {
      logger.w('tablesForPlayer failed: $error');
      return <GameTable>[];
    }
  }

  /// Records that a game finished at [tableId] and lists it for [uids].
  static Future<void> markPlayed(
    String tableId,
    DateTime at, {
    Iterable<String> uids = const <String>[],
  }) async {
    final int millis = at.millisecondsSinceEpoch;
    try {
      await store.write('$_tablesNode/$tableId/$_lastPlayedChild', millis);
      for (final String uid in uids.where((String uid) => uid.isNotEmpty)) {
        await store.write('$_playerTablesNode/$uid/$tableId', millis);
      }
    } catch (error) {
      logger.w('markPlayed failed: $error');
    }
  }

  /// Whether a table other than [exceptTableId] is named [name].
  static Future<bool> _isTableNameTaken(
    String name, {
    String? exceptTableId,
  }) async {
    try {
      final Map<String, Object?> found = await store.whereEquals(
        _tablesNode,
        _nameChild,
        name,
      );
      return found.keys.any((String id) => id != exceptTableId);
    } catch (error) {
      logger.w('table name lookup failed: $error');
      return false;
    }
  }

  /// Whether any lobby is named [name], so a proposal doesn't clash with a
  /// group that is still gathering.
  static Future<bool> _isLobbyNameTaken(String name) async {
    try {
      return (await store.whereEquals(
        _lobbiesNode,
        _nameChild,
        name,
      )).isNotEmpty;
    } catch (error) {
      logger.w('lobby name lookup failed: $error');
      return false;
    }
  }

  static List<GameLobby> _sortedLobbies(
    Map<String, Object?> values,
    CardMedium cards,
  ) =>
      values.entries
          .map(
            (MapEntry<String, Object?> entry) =>
                GameLobby.fromValue(entry.key, entry.value),
          )
          .whereType<GameLobby>()
          .where((GameLobby lobby) => lobby.cards == cards)
          .toList()
        ..sort(
          (GameLobby a, GameLobby b) => b.createdAt.compareTo(a.createdAt),
        );

  static String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(_idRadix)}'
      '${Random.secure().nextInt(_idRandomRange).toRadixString(_idRadix)}';
}
