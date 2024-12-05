import 'package:cards/models/french_suit_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FrenchSuitCardModel', () {
    test('fromJson creates correct card model', () {
      final json = {
        'suit': '♥️',
        'rank': 'A',
        'isRevealed': true,
      };

      final card = FrenchSuitCardModel.fromJson(json);

      expect(card.suit, '♥️');
      expect(card.rank, 'A');
      expect(card.isRevealed, true);
    });

    test('toJson creates correct json representation', () {
      final card = FrenchSuitCardModel(
        suit: '♦️',
        rank: 'K',
        isRevealed: true,
      );

      final json = card.toJson();

      expect(json['suit'], '♦️');
      expect(json['rank'], 'K');
      expect(json['isRevealed'], true);
    });

    test('toJson omits isRevealed when false', () {
      final card = FrenchSuitCardModel(
        suit: '♣️',
        rank: '10',
        isRevealed: false,
      );

      final json = card.toJson();

      expect(json['isRevealed'], null);
    });

    group('value getter', () {
      test('returns correct values for face cards', () {
        expect(FrenchSuitCardModel(suit: '♠️', rank: 'K').value, 10);
        expect(FrenchSuitCardModel(suit: '♠️', rank: 'Q').value, 10);
        expect(FrenchSuitCardModel(suit: '♠️', rank: 'J').value, 10);
        expect(FrenchSuitCardModel(suit: '♠️', rank: 'A').value, 1);
      });

      test('returns correct values for number cards', () {
        expect(FrenchSuitCardModel(suit: '♥️', rank: '2').value, 2);
        expect(FrenchSuitCardModel(suit: '♥️', rank: '5').value, 5);
        expect(FrenchSuitCardModel(suit: '♥️', rank: '10').value, 10);
      });

      test('returns -2 for Joker', () {
        expect(FrenchSuitCardModel(suit: '♠️', rank: '§').value, 50);
      });

      test('returns 0 for invalid rank', () {
        expect(FrenchSuitCardModel(suit: '♠️', rank: 'Invalid').value, 0);
      });
    });

    test('toString returns correct string representation', () {
      final card = FrenchSuitCardModel(suit: '♠️', rank: 'A');
      expect(card.toString(), 'A♠️_ ');
    });

    test('suits list contains all required suits', () {
      expect(FrenchSuitCardModel.suits, ['♥️', '♦️', '♣️', '♠️']);
    });

    test('ranks list contains all required ranks', () {
      expect(FrenchSuitCardModel.ranks, [
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
        // '§', // Joker is a special case
      ]);
    });
  });
}
