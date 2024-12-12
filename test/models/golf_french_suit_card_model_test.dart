import 'package:cards/models/base/golf_french_suit_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GolfFrenchSuitCardModel', () {
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
  });
}
