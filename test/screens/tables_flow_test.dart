import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/game/memory_table_store.dart';
import 'package:cards/models/game/score_sheet_setup.dart';
import 'package:cards/models/game/table_service.dart';
import 'package:cards/screens/leaderboard/leaderboard_screen.dart';
import 'package:cards/screens/tables/lobby_screen.dart';
import 'package:cards/screens/tables/start_table_screen.dart';
import 'package:cards/widgets/helpers/wizard_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Players the offline backend reports in every room.
const List<String> _demoPlayers = <String>['BOB', 'SUE', 'JOHN', 'MARY'];

Widget _app(Widget home, {List<ScoreSheetSetup>? openedSheets}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
  onGenerateRoute: (RouteSettings settings) {
    final Object? arguments = settings.arguments;
    if (arguments is ScoreSheetSetup) {
      openedSheets?.add(arguments);
    }
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext _) => const Scaffold(body: Text('sheet')),
    );
  },
);

/// Walks the physical-card start flow for [gameType] with [others] added.
Future<void> _startInPerson(
  WidgetTester tester,
  GameStyles gameType,
  List<String> others,
) async {
  await tester.tap(find.byKey(Key('gameType.${gameType.name}')));
  await tester.tap(find.text('Next'));
  await _settle(tester);
  expect(find.text('Who is playing?'), findsOneWidget);
  await tester.enterText(
    find.descendant(
      of: find.byKey(const Key('startTable.playerField')),
      matching: find.byType(TextField),
    ),
    others.join(','),
  );
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await _settle(tester);
  await tester.tap(
    find.descendant(
      of: find.byType(WizardFooter),
      matching: find.text('Start a Score Sheet'),
    ),
  );
  await _settle(tester);
}

/// Lets async work finish; the tabletop background animates forever, so
/// pumpAndSettle would never return.
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() {
    isRunningOffLine = true;
    TableService.store = MemoryTableStore();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'guest_initials': 'JP',
    });
  });
  tearDown(() => isRunningOffLine = false);

  testWidgets('starting a new virtual table opens its lobby', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(const StartTableScreen(cards: CardMedium.virtual)),
    );
    await _settle(tester);

    await tester.tap(find.byKey(const Key('gameType.skyjo')));
    await tester.tap(find.text('Next'));
    await _settle(tester);
    expect(find.text('You have no tables for this game yet.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('startTable.newTable')));
    await _settle(tester);

    expect(find.byType(LobbyScreen), findsOneWidget);
    expect(find.text('Skyjo'), findsOneWidget);
    expect(
      find.text('New table for this group. Its name is yours to change.'),
      findsOneWidget,
    );
    for (final String player in <String>[..._demoPlayers, 'JP']) {
      expect(find.text(player), findsWidgets);
    }
  });

  testWidgets('a lobby shows the table this exact group already plays at', (
    WidgetTester tester,
  ) async {
    await TableService.resolveTable(
      gameType: GameStyles.frenchCards9,
      players: <String>[..._demoPlayers, 'JP'],
      proposedName: 'LUCKY FOX',
    );
    final GameLobby lobby = await TableService.openLobby(
      gameType: GameStyles.frenchCards9,
      cards: CardMedium.virtual,
      name: 'PROPOSED NAME',
    );

    await tester.pumpWidget(_app(LobbyScreen(lobbyId: lobby.id)));
    await _settle(tester);

    expect(find.text('LUCKY FOX'), findsOneWidget);
    expect(find.text('PROPOSED NAME'), findsNothing);
    expect(
      find.text('This group already plays at this table.'),
      findsOneWidget,
    );
  });

  testWidgets('in person, a new group gets a new table for its players', (
    WidgetTester tester,
  ) async {
    final List<ScoreSheetSetup> opened = <ScoreSheetSetup>[];
    await tester.pumpWidget(
      _app(
        const StartTableScreen(cards: CardMedium.physical),
        openedSheets: opened,
      ),
    );
    await _settle(tester);

    await _startInPerson(tester, GameStyles.skyjo, <String>['bob', 'SUE']);

    expect(opened, hasLength(1));
    expect(opened.single.gameType, GameStyles.skyjo);
    expect(opened.single.players, <String>['JP', 'BOB', 'SUE']);
    final GameTable? table = await TableService.findTable(
      GameStyles.skyjo,
      <String>['JP', 'BOB', 'SUE'],
    );
    expect(table, isNotNull);
    expect(opened.single.tableName, table!.name);
  });

  testWidgets('in person, a known group reopens its existing table', (
    WidgetTester tester,
  ) async {
    await TableService.resolveTable(
      gameType: GameStyles.frenchCards9,
      players: <String>['JP', 'BOB'],
      proposedName: 'LUCKY FOX',
    );
    final List<ScoreSheetSetup> opened = <ScoreSheetSetup>[];
    await tester.pumpWidget(
      _app(
        const StartTableScreen(cards: CardMedium.physical),
        openedSheets: opened,
      ),
    );
    await _settle(tester);

    await _startInPerson(tester, GameStyles.frenchCards9, <String>['BOB']);

    expect(opened.single.tableName, 'LUCKY FOX');
  });

  testWidgets('the leaderboard is always one game type, no "All Games"', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(const LeaderboardScreen()));
    await _settle(tester);

    for (final GameStyles gameType in GameStyles.values) {
      expect(
        find.byKey(Key('leaderboard.gameType.${gameType.name}')),
        findsOneWidget,
      );
    }
    expect(find.text('All Games'), findsNothing);
  });

  testWidgets(
    'who is playing: typed players show as pills and can be removed',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _app(const StartTableScreen(cards: CardMedium.physical)),
      );
      await _settle(tester);
      await tester.tap(find.text('Next'));
      await _settle(tester);
      expect(find.text('1 player'), findsOneWidget);
      expect(find.byKey(const Key('startTable.qrCode')), findsNothing);

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('startTable.playerField')),
          matching: find.byType(TextField),
        ),
        'BOB',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);
      expect(find.text('2 players'), findsOneWidget);
      expect(find.byKey(const Key('playerPill.remove.JP')), findsNothing);

      await tester.tap(find.byKey(const Key('playerPill.remove.BOB')));
      await _settle(tester);
      expect(find.text('1 player'), findsOneWidget);
      expect(find.text('BOB'), findsNothing);
    },
  );
}
