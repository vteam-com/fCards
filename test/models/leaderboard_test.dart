import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/game/game_result.dart';
import 'package:cards/models/game/leaderboard_entry.dart';
import 'package:cards/models/game/leaderboard_service.dart';
import 'package:flutter_test/flutter_test.dart';

GameResult _result({
  required String id,
  required List<String> names,
  required List<int> scores,
  List<String> uids = const <String>[],
  GameStyles style = GameStyles.skyjo,
  CardMedium cards = CardMedium.virtual,
  int endedAt = 1000,
}) => GameResult.fromScores(
  id: id,
  tableKey: 'ROOM',
  tableName: 'ROOM',
  style: style,
  cards: cards,
  endedAt: DateTime.fromMillisecondsSinceEpoch(endedAt),
  names: names,
  scores: scores,
  uids: uids,
);

void main() {
  group('GameResult', () {
    test('marks every lowest score as a win', () {
      final GameResult result = _result(
        id: 'g1',
        names: <String>['BOB', 'SUE', 'JOHN'],
        scores: <int>[5, 12, 5],
      );

      expect(
        result.players.map((GameResultPlayer p) => p.isWinner).toList(),
        <bool>[true, false, true],
      );
    });

    test('links uids by seat and leaves missing ones name-only', () {
      final GameResult result = _result(
        id: 'g1',
        names: <String>['BOB', 'SUE'],
        scores: <int>[1, 2],
        uids: <String>['uid-bob'],
      );

      expect(result.players[0].uid, 'uid-bob');
      expect(result.players[1].hasAccount, isFalse);
    });

    test('sanitizes Firebase keys', () {
      final GameResult result = GameResult.fromScores(
        id: 'a.b#c',
        tableKey: 'my/room\$',
        tableName: 'my/room\$',
        style: GameStyles.skyjo,
        cards: CardMedium.virtual,
        endedAt: DateTime.fromMillisecondsSinceEpoch(0),
        names: <String>['BOB'],
        scores: <int>[0],
      );

      expect(result.id, 'a_b_c');
      expect(result.tableKey, 'my_room_');
      expect(result.tableName, 'my/room\$');
    });

    test('round-trips through Firebase values', () {
      final GameResult original = _result(
        id: 'g1',
        names: <String>['BOB', 'SUE'],
        scores: <int>[3, 8],
        uids: <String>['', 'uid-sue'],
      );
      final GameResult parsed = GameResult.fromValue(
        'ROOM',
        'g1',
        original.toValue(),
      );

      expect(parsed.style, GameStyles.skyjo);
      expect(parsed.cards, CardMedium.virtual);
      expect(parsed.endedAt, original.endedAt);
      expect(parsed.players.map((GameResultPlayer p) => p.name), <String>[
        'BOB',
        'SUE',
      ]);
      expect(parsed.players[1].uid, 'uid-sue');
      expect(parsed.players[0].isWinner, isTrue);
    });

    test('merges account ids reported by other devices by name', () {
      final GameResult fromBob = _result(
        id: 'g1',
        names: <String>['BOB', 'SUE'],
        scores: <int>[3, 3],
        uids: <String>['uid-bob', ''],
      );
      final GameResult fromSue = _result(
        id: 'g1',
        names: <String>['SUE', 'BOB'],
        scores: <int>[3, 3],
        uids: <String>['uid-sue', ''],
      );

      final GameResult merged = fromBob.mergeAccounts(fromSue);

      expect(merged.players.map((GameResultPlayer p) => p.uid), <String>[
        'uid-bob',
        'uid-sue',
      ]);
    });
  });

  group('LeaderboardEntry', () {
    test('accumulates games, wins, best and average scores', () {
      const LeaderboardEntry empty = LeaderboardEntry(
        playerKey: 'uid',
        name: '',
      );
      final LeaderboardEntry entry = empty
          .withResult(
            const GameResultPlayer(name: 'BOB', score: 10, isWinner: false),
            DateTime.fromMillisecondsSinceEpoch(1),
          )
          .withResult(
            const GameResultPlayer(name: 'BOBBY', score: 4, isWinner: true),
            DateTime.fromMillisecondsSinceEpoch(2),
            avatarUrl: 'https://example.com/a.png',
          );

      expect(entry.name, 'BOBBY');
      expect(entry.gamesPlayed, 2);
      expect(entry.wins, 1);
      expect(entry.bestScore, 4);
      expect(entry.averageScore, 7);
      expect(entry.winRate, 0.5);
      expect(entry.avatarUrl, 'https://example.com/a.png');
    });

    test('keeps the latest name when an older game arrives late', () {
      final LeaderboardEntry entry =
          const LeaderboardEntry(playerKey: 'uid', name: '')
              .withResult(
                const GameResultPlayer(name: 'NEW', score: 1, isWinner: true),
                DateTime.fromMillisecondsSinceEpoch(2),
              )
              .withResult(
                const GameResultPlayer(name: 'OLD', score: 1, isWinner: true),
                DateTime.fromMillisecondsSinceEpoch(1),
              );

      expect(entry.name, 'NEW');
      expect(entry.lastPlayed, DateTime.fromMillisecondsSinceEpoch(2));
    });

    test('round-trips through Firebase values', () {
      final LeaderboardEntry entry = LeaderboardEntry(
        playerKey: 'uid',
        name: 'BOB',
        gamesPlayed: 3,
        wins: 2,
        totalScore: 21,
        bestScore: 2,
        lastPlayed: DateTime.fromMillisecondsSinceEpoch(5),
      );
      final LeaderboardEntry parsed = LeaderboardEntry.fromValue(
        'uid',
        entry.toValue(),
      );

      expect(parsed.gamesPlayed, 3);
      expect(parsed.wins, 2);
      expect(parsed.totalScore, 21);
      expect(parsed.bestScore, 2);
      expect(parsed.lastPlayed, entry.lastPlayed);
    });

    test('ranks by wins, then win rate, then games played', () {
      const List<LeaderboardEntry> entries = <LeaderboardEntry>[
        LeaderboardEntry(playerKey: 'a', name: 'A', gamesPlayed: 4, wins: 2),
        LeaderboardEntry(playerKey: 'b', name: 'B', gamesPlayed: 2, wins: 2),
        LeaderboardEntry(playerKey: 'c', name: 'C', gamesPlayed: 9, wins: 3),
        LeaderboardEntry(playerKey: 'd', name: 'D'),
      ];

      expect(
        LeaderboardEntry.rank(
          entries,
        ).map((LeaderboardEntry entry) => entry.playerKey),
        <String>['c', 'b', 'a'],
      );
    });

    test(
      'aggregates a table by uid or name, across physical and virtual cards',
      () {
        final List<GameResult> results = <GameResult>[
          _result(
            id: 'g1',
            names: <String>['BOB', 'sue'],
            scores: <int>[2, 9],
            uids: <String>['uid-bob', ''],
          ),
          _result(
            id: 'g2',
            names: <String>['ROBERT', 'SUE'],
            scores: <int>[7, 1],
            uids: <String>['uid-bob', ''],
            endedAt: 2000,
          ),
          _result(
            id: 'g3',
            names: <String>['SUE'],
            scores: <int>[4],
            cards: CardMedium.physical,
          ),
        ];

        final List<LeaderboardEntry> all = LeaderboardEntry.aggregate(results);
        expect(all.map((LeaderboardEntry e) => e.name), <String>[
          'SUE',
          'ROBERT',
        ]);
        expect(all.first.gamesPlayed, 3);
        expect(all.first.wins, 2);
        expect(all.last.playerKey, 'uid-bob');
        expect(all.last.gamesPlayed, 2);
      },
    );
  });

  group('LeaderboardService offline', () {
    setUp(() => isRunningOffLine = true);
    tearDown(() => isRunningOffLine = false);

    test('returns empty boards without touching Firebase', () async {
      for (final GameStyles gameType in GameStyles.values) {
        expect(await LeaderboardService.globalLeaderboard(gameType), isEmpty);
      }
      expect(await LeaderboardService.tableLeaderboard('ROOM'), isEmpty);
      expect(await LeaderboardService.standings('uid'), isEmpty);
      expect(await LeaderboardService.roomWinHistory('ROOM'), isEmpty);
      await LeaderboardService.recordResult(
        _result(id: 'g1', names: <String>['BOB'], scores: <int>[0]),
      );
    });
  });

  group('GameModel start date sync', () {
    test('shares the host start time so devices derive one game id', () {
      GameModel newModel() => GameModel(
        gameStyle: GameStyles.frenchCards9,
        roomName: 'ROOM',
        roomHistory: [],
        loginUserName: 'BOB',
        names: <String>['BOB', 'SUE'],
        cardsToDeal: 9,
        deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.frenchCards9),
      );
      final GameModel host = newModel()
        ..gameStartDate = DateTime.fromMillisecondsSinceEpoch(42);
      final GameModel guest = newModel()..fromJson(host.toJson());

      expect(guest.gameStartDate, host.gameStartDate);
    });
  });
}
