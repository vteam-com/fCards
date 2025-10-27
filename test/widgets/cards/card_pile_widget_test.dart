import 'package:cards/models/card_model.dart';
import 'package:cards/widgets/cards/card_pile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardPileWidget', () {
    testWidgets('initializes with required parameters', (
      WidgetTester tester,
    ) async {
      final cards = [
        CardModel(suit: '♥️', rank: 'A', value: 1),
        CardModel(suit: '♦️', rank: 'K', value: 13),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CardPileWidget(
            cards: cards,
            cardsAreHidden: true,
            wiggleTopCard: false,
            revealTopDeckCard: false,
            isDragSource: false,
            isDropTarget: false,
            onDragDropped: (_, _) {},
            scale: 1.0,
          ),
        ),
      );

      expect(find.byType(CardPileWidget), findsOneWidget);
    });

    testWidgets('handles null onDraw callback', (WidgetTester tester) async {
      final cards = [CardModel(suit: '♥️', rank: 'A', value: 1)];

      await tester.pumpWidget(
        MaterialApp(
          home: CardPileWidget(
            cards: cards,
            cardsAreHidden: false,
            wiggleTopCard: true,
            revealTopDeckCard: true,
            isDragSource: true,
            isDropTarget: true,
            onDragDropped: (_, _) {},
            scale: 0.8,
          ),
        ),
      );

      expect(find.byType(CardPileWidget), findsOneWidget);
    });

    testWidgets('handles empty card list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardPileWidget(
            cards: [],
            cardsAreHidden: false,
            wiggleTopCard: false,
            revealTopDeckCard: true,
            isDragSource: true,
            isDropTarget: true,
            onDragDropped: (_, _) {},
            scale: 1.2,
          ),
        ),
      );

      expect(find.byType(CardPileWidget), findsOneWidget);
    });
  });
}
