import 'package:cards/models/card_model.dart';
import 'package:cards/models/card_model_french.dart';
import 'package:cards/widgets/cards/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardFaceFrenchWidget', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardWidget(
              card: CardModel(suit: '♣️', rank: 'A', value: 1),
              onDropped: null,
            ),
          ),
        ),
      );

      expect(find.byType(CardWidget), findsOneWidget);
    });

    testWidgets('has correct widget tree', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardWidget(
              card: CardModel(suit: '♣️', rank: 'A', value: 1),
              onDropped: null,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('handles tap events', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () => tapped = true,
              child: CardWidget(
                card: CardModel(suit: '♣️', rank: 'A', value: 1),
                onDropped: null,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CardWidget));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('renders different suits correctly',
        (WidgetTester tester) async {
      final List<String> suits = ['♣️', '♠️', '♥️', '♦️'];

      for (final String suit in suits) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CardWidget(
                card: CardModel(
                  suit: suit,
                  rank: 'A',
                  value: 1,
                  isRevealed: true,
                ),
                onDropped: null,
              ),
            ),
          ),
        );
        expect(find.text(suit), findsOneWidget);
      }
    });

    testWidgets('renders different ranks correctly',
        (WidgetTester tester) async {
      final List<String> ranks = [
        '§', // TODO
        'A',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        'X',
        'J',
        'Q',
        'K',
      ];

      for (final String rank in ranks) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 800,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CardWidget(
                    card: CardModel(
                      suit: '♣️',
                      rank: rank,
                      value: CardModelFrench.getValue(rank),
                      isRevealed: true,
                    ),
                    onDropped: null,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        if (rank == '§') {
          expect(find.text('Joker'), findsAtLeast(1));
        } else {
          expect(find.text(rank), findsAtLeast(1));
        }
      }
    });

    testWidgets('renders SkyJo', (WidgetTester tester) async {
      final ranks = [
        '-2',
        '-1',
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '10',
        '11',
        '12',
      ];
      for (final rank in ranks) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CardWidget(
                card: CardModel(
                  suit: '', // SkyJo has no suit
                  rank: rank,
                  value: int.tryParse(rank) ?? 0,
                  isRevealed: true,
                ),
                onDropped: null,
              ),
            ),
          ),
        );

        expect(find.text(rank), findsAtLeast(1));
      }
    });

    testWidgets('handles onDropped callback', (WidgetTester tester) async {
      bool dropped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                CardWidget(
                  card: CardModel(
                    suit: '♥️',
                    rank: 'A',
                    value: 1,
                    isRevealed: true,
                  )..isSelectable = true,
                  onDropped: (s, t) => dropped = true,
                ),
                CardWidget(
                  card: CardModel(
                    suit: '♣️',
                    rank: '2',
                    value: 2,
                    isRevealed: true,
                  )..isSelectable = true,
                  onDropped: (s, t) => dropped = true,
                ),
              ],
            ),
          ),
        ),
      );
      final Finder firstCard = find.byType(CardWidget).first;
      await tester.drag(firstCard, const Offset(100, 0));
      // await tester.pumpAndSettle();
      // ToDo
      expect(dropped, false);
    });
  });
}
