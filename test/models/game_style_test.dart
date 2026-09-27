import 'package:cards/screens/game/game_style.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/gen/l10n/app_localizations_en.dart';
import 'package:cards/widgets/cards/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameStyles', () {
    test('has correct number of values', () {
      expect(GameStyles.values.length, equals(2));
    });

    test('contains expected values', () {
      expect(GameStyles.values, contains(GameStyles.frenchCards9));
      expect(GameStyles.values, contains(GameStyles.skyjo));
    });

    test('values are in expected order', () {
      expect(GameStyles.values[0], equals(GameStyles.frenchCards9));
      expect(GameStyles.values[1], equals(GameStyles.skyjo));
    });

    test('can compare enum values', () {
      expect(GameStyles.frenchCards9 == GameStyles.frenchCards9, isTrue);
      expect(GameStyles.frenchCards9 == GameStyles.skyjo, isFalse);
    });

    test('can convert to string', () {
      expect(GameStyles.frenchCards9.toString(), contains('frenchCards9'));
      expect(GameStyles.skyjo.toString(), contains('skyjo'));
    });

    test('Instructions', () {
      final AppLocalizationsEn localizations = AppLocalizationsEn();
      expect(
        gameInstructions(GameStyles.frenchCards9, localizations).isEmpty,
        false,
      );
      expect(gameInstructions(GameStyles.skyjo, localizations).isEmpty, false);
    });
  });

  testWidgets('GameStyle French Cards 9 widget test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: GameStyle(style: GameStyles.frenchCards9)),
    );

    // Verify Markdown widget is present
    expect(find.byType(Markdown), findsOneWidget);

    // Verify cards are displayed
    expect(find.byType(CardWidget), findsWidgets);
  });
  testWidgets('GameStyle Skyjo widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: GameStyle(style: GameStyles.skyjo)),
    );

    // Verify Markdown widget is present
    expect(find.byType(Markdown), findsOneWidget);

    // Verify cards are displayed
    expect(find.byType(CardWidget), findsWidgets);
  });
}
