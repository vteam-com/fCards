import 'package:cards/models/card_model.dart';
import 'package:cards/models/card_model_french.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardModel', () {
    test('fromJson creates correct card model', () {
      final json = {'suit': '♥️', 'rank': 'A', 'value': 1, 'isRevealed': true};

      final card = CardModel.fromJson(json);

      expect(card.suit, '♥️');
      expect(card.rank, 'A');
      expect(card.isRevealed, true);
    });

    test('toJson creates correct json representation', () {
      final card = CardModel(suit: '♦️', rank: 'K', value: 0, isRevealed: true);

      final json = card.toJson();

      expect(json['suit'], '♦️');
      expect(json['rank'], 'K');
      expect(json['isRevealed'], true);
    });

    test('toJson omits isRevealed when false', () {
      final card = CardModel(
        suit: '♣️',
        rank: '10',
        value: 10,
        isRevealed: false,
      );

      final json = card.toJson();

      expect(json['isRevealed'], null);
    });

    group('value getter', () {
      test('returns correct values for face cards', () {
        expect(CardModel(suit: '♠️', rank: 'K', value: 0).value, 0);
        expect(CardModel(suit: '♠️', rank: 'Q', value: 12).value, 12);
        expect(CardModel(suit: '♠️', rank: 'J', value: 11).value, 11);
        expect(CardModel(suit: '♠️', rank: 'A', value: 1).value, 1);
      });

      test('returns correct values for number cards', () {
        expect(CardModel(suit: '♥️', rank: '2', value: 2).value, 2);
        expect(CardModel(suit: '♥️', rank: '5', value: 5).value, 5);
        expect(CardModel(suit: '♥️', rank: '10', value: 10).value, 10);
      });

      test('returns -2 for Joker', () {
        expect(CardModel(suit: '♠️', rank: '§', value: -2).value, -2);
      });

      test('returns 0 for invalid rank', () {
        expect(CardModel(suit: '♠️', rank: 'Invalid', value: 0).value, 0);
      });
    });

    test('toString returns correct string representation', () {
      final card = CardModel(suit: '♠️', rank: 'A', value: 1);
      expect(card.toString(), 'A♠️ 1v ');
    });

    test('suits list contains all required suits', () {
      expect(CardModelFrench.suits, ['♠️', '♥️', '♣️', '♦️']);
    });

    test('ranks list contains all required ranks', () {
      expect(CardModelFrench.ranks, [
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
