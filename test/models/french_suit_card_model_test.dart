import 'package:cards/models/base/golf_french_suit_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GolfFrenchSuitCardModel', () {
    test('fromJson creates correct card model', () {
      final json = {
        'suit': '♥️',
        'rank': 'A',
        'isRevealed': true,
      };

      final card = GolfFrenchSuitCardModel.fromJson(json);

      expect(card.suit, '♥️');
      expect(card.rank, 'A');
      expect(card.isRevealed, true);
    });

    test('toJson creates correct json representation', () {
      final card = GolfFrenchSuitCardModel(
        suit: '♦️',
        rank: 'K',
        value: 0,
        isRevealed: true,
      );

      final json = card.toJson();

      expect(json['suit'], '♦️');
      expect(json['rank'], 'K');
      expect(json['isRevealed'], true);
    });

    test('toJson omits isRevealed when false', () {
      final card = GolfFrenchSuitCardModel(
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
        expect(
          GolfFrenchSuitCardModel(suit: '♠️', rank: 'K', value: 0).value,
          0,
        );
        expect(
          GolfFrenchSuitCardModel(suit: '♠️', rank: 'Q', value: 12).value,
          12,
        );
        expect(
          GolfFrenchSuitCardModel(suit: '♠️', rank: 'J', value: 11).value,
          11,
        );
        expect(
          GolfFrenchSuitCardModel(suit: '♠️', rank: 'A', value: 1).value,
          1,
        );
      });

      test('returns correct values for number cards', () {
        expect(
          GolfFrenchSuitCardModel(suit: '♥️', rank: '2', value: 2).value,
          2,
        );
        expect(
          GolfFrenchSuitCardModel(suit: '♥️', rank: '5', value: 5).value,
          5,
        );
        expect(
          GolfFrenchSuitCardModel(suit: '♥️', rank: '10', value: 10).value,
          10,
        );
      });

      test('returns -2 for Joker', () {
        expect(
          GolfFrenchSuitCardModel(suit: '♠️', rank: '§', value: -2).value,
          -2,
        );
      });

      test('returns 0 for invalid rank', () {
        expect(
          GolfFrenchSuitCardModel(suit: '♠️', rank: 'Invalid', value: 0).value,
          0,
        );
      });
    });

    test('toString returns correct string representation', () {
      final card = GolfFrenchSuitCardModel(suit: '♠️', rank: 'A', value: 1);
      expect(card.toString(), 'A♠️1_ ');
    });

    test('suits list contains all required suits', () {
      expect(GolfFrenchSuitCardModel.suits, ['♥️', '♦️', '♣️', '♠️']);
    });

    test('ranks list contains all required ranks', () {
      expect(GolfFrenchSuitCardModel.ranks, [
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
