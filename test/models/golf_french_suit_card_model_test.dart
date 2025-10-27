import 'package:cards/models/card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardModel', () {
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
  });
}
