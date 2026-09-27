import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_history.dart';
import 'package:cards/models/game/game_result.dart';
import 'package:cards/models/game/leaderboard_entry.dart';
import 'package:cards/models/game/leaderboard_standing.dart';
import 'package:cards/models/game/table_service.dart';
import 'package:cards/utils/logger.dart';
import 'package:firebase_database/firebase_database.dart';

export 'package:cards/models/game/leaderboard_standing.dart';

const String _tableResultsNode = 'table_results';
const String _leaderboardNode = 'leaderboard';
const String _leaderboardGamesNode = 'leaderboard_games';

/// Maximum number of rows loaded for the global leaderboard (Fibonacci).
const int globalLeaderboardLimit = 89;

/// Records finished games and loads leaderboards from Firebase.
class LeaderboardService {
  /// Saves [result] to its table and adds it to each account player's totals.
  ///
  /// Safe to call repeatedly and from several devices for the same game: a
  /// create-only marker per player and game keeps totals from double counting.
  /// [avatarUrls] maps uids to profile photos. [recorderUid] also gets the
  /// table in their "My tables", so the host of a name-only score sheet can
  /// find it.
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
      await TableService.markPlayed(
        result.tableKey,
        result.endedAt,
        uids: tableUids,
      );

      for (final GameResultPlayer player in result.players) {
        if (player.hasAccount) {
          await _addToTotals(result, player, avatarUrls[player.uid]);
        }
      }
    } catch (error) {
      logger.w('recordResult failed: $error');
    }
  }

  /// Loads the top global rows for [gameType], best first.
  static Future<List<LeaderboardEntry>> globalLeaderboard(
    GameStyles gameType,
  ) async {
    if (!await _ready()) {
      return <LeaderboardEntry>[];
    }
    try {
      final DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref('$_leaderboardNode/${gameType.name}')
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
    String tableKey,
  ) async => LeaderboardEntry.aggregate(await _tableResults(tableKey));

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

  /// Loads [uid]'s totals and global position for each game type they
  /// played, in game type order.
  static Future<List<LeaderboardStanding>> standings(String uid) async {
    if (!await _ready() || uid.isEmpty) {
      return <LeaderboardStanding>[];
    }
    final List<LeaderboardStanding> standings = <LeaderboardStanding>[];
    for (final GameStyles gameType in GameStyles.values) {
      try {
        final DataSnapshot snapshot = await FirebaseDatabase.instance
            .ref('$_leaderboardNode/${gameType.name}/$uid')
            .get();
        if (!snapshot.exists) {
          continue;
        }
        final List<LeaderboardEntry> top = await globalLeaderboard(gameType);
        final int index = top.indexWhere(
          (LeaderboardEntry row) => row.playerKey == uid,
        );
        standings.add(
          LeaderboardStanding(
            gameType: gameType,
            entry: LeaderboardEntry.fromValue(uid, snapshot.value),
            rank: index < 0 ? null : index + 1,
          ),
        );
      } catch (error) {
        logger.w('leaderboard standing failed: $error');
      }
    }
    return standings;
  }

  /// Adds [player]'s outcome to their totals for the game type, once.
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

    await FirebaseDatabase.instance
        .ref('$_leaderboardNode/${result.style.name}/${player.uid}')
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

  static Future<bool> _ready() async {
    if (isRunningOffLine) {
      return false;
    }
    await useFirebase();
    return backendReady;
  }
}
