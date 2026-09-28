import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/game/golf_score_model.dart';
import 'package:cards/models/game/memory_table_store.dart';
import 'package:cards/models/game/score_sheet_setup.dart';
import 'package:cards/models/game/table_service.dart';
import 'package:cards/screens/keepscore/golf_score_screen.dart';
import 'package:cards/widgets/helpers/input_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  tearDown(() => isRunningOffLine = false);

  testWidgets('adding a round selects its first cell for typing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const GolfScoreScreen(
          setup: ScoreSheetSetup(
            gameType: GameStyles.frenchCards9,
            tableName: 'LUCKY FOX',
            players: <String>['BOB', 'SUE'],
          ),
        ),
      ),
    );
    await _settle(tester);
    expect(find.byType(InputKeyboard), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await _settle(tester);

    expect(find.byType(InputKeyboard), findsOneWidget);
    await tester.tap(find.text('7'));
    await _settle(tester);

    final GolfScoreModel saved = await GolfScoreModel.load();
    expect(saved.scores, <List<int>>[
      <int>[0, 0],
      <int>[7, 0],
    ]);
  });
}
