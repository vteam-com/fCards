import 'package:cards/screens/game/game_style.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/widgets/cards/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameStyles', () {
    test('has correct number of values', () {
      expect(GameStyles.values.length, equals(4));
    });

    test('contains expected values', () {
      expect(GameStyles.values, contains(GameStyles.frenchCards9));
      expect(GameStyles.values, contains(GameStyles.skyJo));
      expect(GameStyles.values, contains(GameStyles.miniPut));
      expect(GameStyles.values, contains(GameStyles.custom));
    });

    test('values are in expected order', () {
      expect(GameStyles.values[0], equals(GameStyles.frenchCards9));
      expect(GameStyles.values[1], equals(GameStyles.skyJo));
      expect(GameStyles.values[2], equals(GameStyles.miniPut));
      expect(GameStyles.values[3], equals(GameStyles.custom));
    });

    test('can compare enum values', () {
      expect(GameStyles.frenchCards9 == GameStyles.frenchCards9, isTrue);
      expect(GameStyles.frenchCards9 == GameStyles.skyJo, isFalse);
    });

    test('can convert to string', () {
      expect(GameStyles.frenchCards9.toString(), contains('frenchCards9'));
      expect(GameStyles.skyJo.toString(), contains('skyJo'));
      expect(GameStyles.miniPut.toString(), contains('miniPut'));
      expect(GameStyles.custom.toString(), contains('custom'));
    });

    test('Number of Cards', () {
      expect(numberOfCards(GameStyles.frenchCards9), 9);
      expect(numberOfCards(GameStyles.skyJo), 12);
      expect(numberOfCards(GameStyles.miniPut), 4);
      expect(numberOfCards(GameStyles.custom), 9);
    });

    test('Number of Decks', () {
      expect(numberOfDecks(GameStyles.frenchCards9, 1), 1);
      expect(numberOfDecks(GameStyles.frenchCards9, 2), 1);
      expect(numberOfDecks(GameStyles.frenchCards9, 3), 2);
      expect(numberOfDecks(GameStyles.frenchCards9, 4), 2);
      expect(numberOfDecks(GameStyles.skyJo, 1), 1);
      expect(numberOfDecks(GameStyles.miniPut, 1), 1);
      expect(numberOfDecks(GameStyles.custom, 1), 1);
    });

    test('numberOfCardsToRevealOnStartup', () {
      expect(numberOfCardsToRevealOnStartup(GameStyles.frenchCards9), 2);
      expect(numberOfCardsToRevealOnStartup(GameStyles.skyJo), 2);
      expect(numberOfCardsToRevealOnStartup(GameStyles.miniPut), 1);
      expect(numberOfCardsToRevealOnStartup(GameStyles.custom), 0);
    });

    test('Instructions', () {
      expect(gameInstructions(GameStyles.frenchCards9).isEmpty, false);
      expect(gameInstructions(GameStyles.skyJo).isEmpty, false);
      expect(gameInstructions(GameStyles.miniPut).isEmpty, false);
      expect(gameInstructions(GameStyles.custom).isEmpty, false);
    });

    test('from Json', () {
      expect(intToGameStyles(-1), GameStyles.frenchCards9);
      expect(intToGameStyles(0), GameStyles.frenchCards9);
      expect(intToGameStyles(1), GameStyles.skyJo);
      expect(intToGameStyles(2), GameStyles.miniPut);
      expect(intToGameStyles(3), GameStyles.custom);
      expect(intToGameStyles(99), GameStyles.frenchCards9);
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
  testWidgets('GameStyle SkyJo widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: GameStyle(style: GameStyles.skyJo)),
    );

    // Verify Markdown widget is present
    expect(find.byType(Markdown), findsOneWidget);

    // Verify cards are displayed
    expect(find.byType(CardWidget), findsWidgets);
  });
  testWidgets('GameStyle French MiniPut 4 widget test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: GameStyle(style: GameStyles.miniPut)),
    );

    // Verify Markdown widget is present
    expect(find.byType(Markdown), findsOneWidget);

    // Verify cards are displayed
    expect(find.byType(CardWidget), findsWidgets);
  });
  testWidgets('GameStyle Custom widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: GameStyle(style: GameStyles.custom)),
    );

    // Verify Markdown widget is present
    expect(find.byType(Markdown), findsOneWidget);

    // Verify cards are displayed
    expect(find.byType(CardWidget), findsWidgets);
  });
}
