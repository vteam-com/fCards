import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/game/game_result.dart';
import 'package:cards/models/game/golf_score_model.dart';
import 'package:cards/models/game/score_sheet_setup.dart';
import 'package:cards/models/game/score_session_closure.dart';
import 'package:cards/screens/keepscore/close_game_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

GolfScoreModel _model(List<String> names, List<List<int>> scores) =>
    GolfScoreModel(playerNames: names, scores: scores, persistChanges: false);

Future<List<int?>> _openSheet(
  WidgetTester tester, {
  required List<String> names,
  required List<int> totals,
  required List<int> leaders,
}) async {
  final List<int?> picked = <int?>[];
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async => picked.add(
              await showCloseGameSheet(
                context: context,
                names: names,
                totals: totals,
                leaders: leaders,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return picked;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test(
    'a new sheet takes the setup and is saved with its game and table',
    () async {
      final GolfScoreModel sheet = GolfScoreModel(
        playerNames: <String>['OLD'],
        scores: <List<int>>[
          <int>[9],
        ],
      );
      await sheet.startNew(
        const ScoreSheetSetup(
          gameType: GameStyles.skyjo,
          tableName: 'LUCKY FOX',
          players: <String>['BOB', 'SUE'],
        ),
      );

      expect(sheet.playerNames, <String>['BOB', 'SUE']);
      expect(sheet.scores, <List<int>>[
        <int>[0, 0],
      ]);

      final GolfScoreModel reloaded = await GolfScoreModel.load();
      expect(reloaded.gameType, GameStyles.skyjo);
      expect(reloaded.tableName, 'LUCKY FOX');
      expect(reloaded.playerNames, <String>['BOB', 'SUE']);
    },
  );

  group('GolfScoreModel closing', () {
    test('needs two players and at least one score', () {
      expect(
        _model(
          <String>['A'],
          <List<int>>[
            <int>[3],
          ],
        ).canClose,
        isFalse,
      );
      expect(
        _model(
          <String>['A', 'B'],
          <List<int>>[
            <int>[0, 0],
          ],
        ).canClose,
        isFalse,
      );
      expect(
        _model(
          <String>['A', 'B'],
          <List<int>>[
            <int>[0, 4],
          ],
        ).canClose,
        isTrue,
      );
    });

    test('lists every player tied for the lowest total', () {
      final GolfScoreModel model = _model(
        <String>['A', 'B', 'C'],
        <List<int>>[
          <int>[5, 3, 3],
          <int>[1, 2, 2],
        ],
      );

      expect(model.leaderIndexes(), <int>[1, 2]);
    });
  });

  test('a picked winner is the only winner of a tied result', () {
    final GameResult result = GameResult.fromScores(
      id: 'g1',
      tableKey: 'T',
      tableName: 'T',
      style: GameStyles.frenchCards9,
      cards: CardMedium.physical,
      endedAt: DateTime.fromMillisecondsSinceEpoch(0),
      names: <String>['A', 'B', 'C'],
      scores: <int>[5, 5, 9],
      winnerIndex: 1,
    );

    expect(result.winners.map((GameResultPlayer p) => p.name), <String>['B']);
  });

  test('closure announcements round-trip', () {
    final ScoreSessionClosure closure = ScoreSessionClosure(
      gameId: 'g1',
      winnerName: 'BRETT',
      endedAt: DateTime.fromMillisecondsSinceEpoch(7),
    );
    final ScoreSessionClosure? parsed = ScoreSessionClosure.fromValue(
      closure.toValue(),
    );

    expect(parsed?.gameId, 'g1');
    expect(parsed?.winnerName, 'BRETT');
    expect(parsed?.endedAt, closure.endedAt);
    expect(ScoreSessionClosure.fromValue(null), isNull);
  });

  group('CloseGameSheet', () {
    testWidgets('confirms the single leader as winner', (
      WidgetTester tester,
    ) async {
      final List<int?> picked = await _openSheet(
        tester,
        names: <String>['A', 'B'],
        totals: <int>[9, 4],
        leaders: <int>[1],
      );

      await tester.tap(find.text('Close Game'));
      await tester.pumpAndSettle();

      expect(picked, <int?>[1]);
    });

    testWidgets('a tie needs the host to pick the winner first', (
      WidgetTester tester,
    ) async {
      final List<int?> picked = await _openSheet(
        tester,
        names: <String>['A', 'B', 'C'],
        totals: <int>[4, 9, 4],
        leaders: <int>[0, 2],
      );
      expect(
        find.text('Tied for the lowest score. Tap the winner.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Close Game'));
      await tester.pumpAndSettle();
      expect(picked, isEmpty);

      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close Game'));
      await tester.pumpAndSettle();

      expect(picked, <int?>[2]);
    });

    testWidgets('cancel closes nothing', (WidgetTester tester) async {
      final List<int?> picked = await _openSheet(
        tester,
        names: <String>['A', 'B'],
        totals: <int>[1, 2],
        leaders: <int>[0],
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(picked, <int?>[null]);
    });
  });
}
