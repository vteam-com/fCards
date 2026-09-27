import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_history.dart';
import 'package:cards/models/game/game_result.dart';
import 'package:cards/models/game/leaderboard_entry.dart';
import 'package:cards/models/game/leaderboard_standing.dart';
import 'package:cards/models/game/leaderboard_table.dart';
import 'package:cards/utils/logger.dart';
import 'package:firebase_database/firebase_database.dart';

export 'package:cards/models/game/leaderboard_standing.dart';
export 'package:cards/models/game/leaderboard_table.dart';

const String _tableResultsNode = 'table_results';
const String _leaderboardNode = 'leaderboard';
const String _leaderboardGamesNode = 'leaderboard_games';
const String _leaderboardTablesNode = 'leaderboard_tables';
const String _tableNameNode = 'table_name';
const String _lastPlayedNode = 'last_played';

/// Maximum number of rows loaded for the global leaderboard (Fibonacci).
const int globalLeaderboardLimit = 89;

/// Records finished games and loads leaderboards from Firebase.
class LeaderboardService {
  /// Saves [result] to its table and adds it to each account player's totals.
  ///
  /// Safe to call repeatedly and from several devices for the same game: a
  /// create-only marker per player and game keeps totals from double counting.
  /// [avatarUrls] maps uids to profile photos. [recorderUid] also gets the
  /// table listed, so the host of a name-only score sheet can find it.
  static Future<void> recordResult(
    GameResult result, {
    Map<String, String> avatarUrls = const <String, String>{},
    String? recorderUid,
  }) async {
    if (isRunningOffLine || result.players.isEmpty) {
      return;
    }
    await useFirebase();
    if (!backendReady) {
      logger.e('recordResult: backend not ready');
      return;
    }

    try {
      await FirebaseDatabase.instance
          .ref('$_tableResultsNode/${result.tableKey}/${result.id}')
          .runTransaction((Object? value) {
            final GameResult merged = value == null
                ? result
                : GameResult.fromValue(
                    result.tableKey,
                    result.id,
                    value,
                  ).mergeAccounts(result);
            return Transaction.success(merged.toValue());
          });

      final Set<String> tableUids = <String>{
        for (final GameResultPlayer player in result.players)
          if (player.hasAccount) player.uid,
        if (recorderUid != null && recorderUid.isNotEmpty) recorderUid,
      };
      for (final String uid in tableUids) {
        await FirebaseDatabase.instance
            .ref('$_leaderboardTablesNode/$uid/${result.tableKey}')
            .set(<String, Object>{
              _tableNameNode: result.tableName,
              _lastPlayedNode: result.endedAt.millisecondsSinceEpoch,
            });
      }

      for (final GameResultPlayer player in result.players) {
        if (player.hasAccount) {
          await _addToTotals(result, player, avatarUrls[player.uid]);
        }
      }
    } catch (error) {
      logger.w('recordResult failed: $error');
    }
  }

  /// Loads the top global rows for [style], best first.
  static Future<List<LeaderboardEntry>> globalLeaderboard(String style) async {
    if (!await _ready()) {
      return <LeaderboardEntry>[];
    }
    try {
      final DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref('$_leaderboardNode/${firebaseSafeKey(style)}')
          .orderByChild(leaderboardWinsNode)
          .limitToLast(globalLeaderboardLimit)
          .get();
      final Object? value = snapshot.value;
      if (value is! Map) {
        return <LeaderboardEntry>[];
      }
      return LeaderboardEntry.rank(
        value.entries.map(
          (MapEntry<dynamic, dynamic> entry) =>
              LeaderboardEntry.fromValue(entry.key.toString(), entry.value),
        ),
      );
    } catch (error) {
      logger.w('globalLeaderboard failed: $error');
      return <LeaderboardEntry>[];
    }
  }

  /// Loads the ranked board for everyone who played at [tableKey].
  static Future<List<LeaderboardEntry>> tableLeaderboard(
    String tableKey, {
    String? style,
  }) async {
    return LeaderboardEntry.aggregate(
      await _tableResults(tableKey),
      style: style,
    );
  }

  /// Loads every result recorded at [tableKey].
  static Future<List<GameResult>> _tableResults(String tableKey) async {
    if (!await _ready() || tableKey.isEmpty) {
      return <GameResult>[];
    }
    final String key = firebaseSafeKey(tableKey);
    try {
      final DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref('$_tableResultsNode/$key')
          .get();
      final Object? value = snapshot.value;
      if (value is! Map) {
        return <GameResult>[];
      }
      return value.entries
          .map(
            (MapEntry<dynamic, dynamic> entry) =>
                GameResult.fromValue(key, entry.key.toString(), entry.value),
          )
          .toList();
    } catch (error) {
      logger.w('table results failed: $error');
      return <GameResult>[];
    }
  }

  /// Loads every win recorded at [roomName], one entry per winner.
  ///
  /// Feeds the in-game "games won" counters; ties give each winner a win.
  static Future<List<GameHistory>> roomWinHistory(String roomName) async {
    final List<GameResult> results = await _tableResults(roomName);
    return <GameHistory>[
      for (final GameResult result in results)
        for (final GameResultPlayer winner in result.winners)
          GameHistory()
            ..date = result.endedAt
            ..playersNames = <String>[winner.name],
    ];
  }

  /// Lists the tables [uid] has results at, most recent first.
  static Future<List<LeaderboardTable>> tablesForPlayer(String uid) async {
    if (!await _ready() || uid.isEmpty) {
      return <LeaderboardTable>[];
    }
    try {
      final DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref('$_leaderboardTablesNode/$uid')
          .get();
      final Object? value = snapshot.value;
      if (value is! Map) {
        return <LeaderboardTable>[];
      }
      return value.entries.map((MapEntry<dynamic, dynamic> entry) {
        final Object? table = entry.value;
        final Object? name = table is Map ? table[_tableNameNode] : null;
        final Object? lastPlayed = table is Map ? table[_lastPlayedNode] : null;
        return LeaderboardTable(
          key: entry.key.toString(),
          name: name is String && name.isNotEmpty ? name : entry.key.toString(),
          lastPlayed: DateTime.fromMillisecondsSinceEpoch(
            lastPlayed is num ? lastPlayed.toInt() : 0,
          ),
        );
      }).toList()..sort(
        (LeaderboardTable a, LeaderboardTable b) =>
            b.lastPlayed.compareTo(a.lastPlayed),
      );
    } catch (error) {
      logger.w('tablesForPlayer failed: $error');
      return <LeaderboardTable>[];
    }
  }

  /// Loads [uid]'s totals across every style and their global position.
  static Future<LeaderboardStanding?> standing(String uid) async {
    if (!await _ready() || uid.isEmpty) {
      return null;
    }
    try {
      final DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref('$_leaderboardNode/$allStylesKey/$uid')
          .get();
      if (!snapshot.exists) {
        return null;
      }
      final LeaderboardEntry entry = LeaderboardEntry.fromValue(
        uid,
        snapshot.value,
      );
      final List<LeaderboardEntry> top = await globalLeaderboard(allStylesKey);
      final int index = top.indexWhere(
        (LeaderboardEntry row) => row.playerKey == uid,
      );
      return LeaderboardStanding(
        entry: entry,
        rank: index < 0 ? null : index + 1,
      );
    } catch (error) {
      logger.w('leaderboard standing failed: $error');
      return null;
    }
  }

  /// Adds [player]'s outcome to their overall and per-style totals once.
  static Future<void> _addToTotals(
    GameResult result,
    GameResultPlayer player,
    String? avatarUrl,
  ) async {
    final TransactionResult claim = await FirebaseDatabase.instance
        .ref('$_leaderboardGamesNode/${player.uid}/${result.id}')
        .runTransaction(
          (Object? value) =>
              value == null ? Transaction.success(true) : Transaction.abort(),
        );
    if (!claim.committed) {
      return;
    }

    final Set<String> styles = <String>{
      allStylesKey,
      if (result.style.isNotEmpty) firebaseSafeKey(result.style),
    };
    for (final String style in styles) {
      await FirebaseDatabase.instance
          .ref('$_leaderboardNode/$style/${player.uid}')
          .runTransaction((Object? value) {
            final LeaderboardEntry current = LeaderboardEntry.fromValue(
              player.uid,
              value,
            );
            return Transaction.success(
              current
                  .withResult(player, result.endedAt, avatarUrl: avatarUrl)
                  .toValue(),
            );
          });
    }
  }

  static Future<bool> _ready() async {
    if (isRunningOffLine) {
      return false;
    }
    await useFirebase();
    return backendReady;
  }
}
