import 'package:cards/models/card/hand_model.dart';
import 'package:flutter_test/flutter_test.dart';

// Card value constants matching Golf scoring rules
const int _valAce = 1;
const int _valJoker = -2;
const int _valKing = 0;
const int _valJack = 11;
const int _valQueen = 12;

CardModel _card(String rank, int value) =>
    CardModel(suit: '♠️', rank: rank, value: value, isRevealed: true);

CardModel _ace() => _card('A', _valAce);
CardModel _joker() => _card('§', _valJoker);
CardModel _king() => _card('K', _valKing);
CardModel _jack() => _card('J', _valJack);
CardModel _queen() => _card('Q', _valQueen);
CardModel _num(int n) => _card('$n', n);

/// Builds a 3×3 [HandModel] from a list of 9 cards ordered row-first:
/// [r0c0, r0c1, r0c2, r1c0, r1c1, r1c2, r2c0, r2c1, r2c2]
HandModel _hand3x3(List<CardModel> cards) {
  assert(cards.length == 9, 'Expected 9 cards for a 3x3 grid');
  return HandModel(3, 3, cards);
}

void main() {
  group('Golf score - benchmark image grids', () {
    /// cards_grid_open_a.jpeg
    ///   J  10  A
    ///   6   9  §
    ///   K   4  5
    /// No matching rows or columns → score = 11+10+1+6+9+(-2)+0+4+5 = 44
    test('cards_grid_open_a: score is 44', () {
      final hand = _hand3x3([
        _jack(),
        _num(10),
        _ace(),
        _num(6),
        _num(9),
        _joker(),
        _king(),
        _num(4),
        _num(5),
      ]);
      expect(hand.getSumOfCardsForGolf(), 44);
    });

    /// cards_grid_open_b.jpeg
    ///   A   2   3
    ///   4  10   J
    ///   Q   K   §
    /// No matching rows or columns → score = 1+2+3+4+10+11+12+0+(-2) = 41
    test('cards_grid_open_b: score is 41', () {
      final hand = _hand3x3([
        _ace(),
        _num(2),
        _num(3),
        _num(4),
        _num(10),
        _jack(),
        _queen(),
        _king(),
        _joker(),
      ]);
      expect(hand.getSumOfCardsForGolf(), 41);
    });

    /// cards_grid_open_c.jpeg
    ///   Q   2   3
    ///   Q  10   J
    ///   Q   K   §
    /// Column 1 (Q,Q,Q) → set = 0 → score = 0+2+3+0+10+11+0+0+(-2) = 24
    test('cards_grid_open_c: score is 24', () {
      final hand = _hand3x3([
        _queen(),
        _num(2),
        _num(3),
        _queen(),
        _num(10),
        _jack(),
        _queen(),
        _king(),
        _joker(),
      ]);
      expect(hand.getSumOfCardsForGolf(), 24);
    });

    /// cards_grid_1_to_9.jpeg
    ///   A   2   3
    ///   4   5   6
    ///   7   8   9
    /// No matching rows or columns → score = 1+2+3+4+5+6+7+8+9 = 45
    test('cards_grid_1_to_9: score is 45', () {
      final hand = _hand3x3([
        _ace(),
        _num(2),
        _num(3),
        _num(4),
        _num(5),
        _num(6),
        _num(7),
        _num(8),
        _num(9),
      ]);
      expect(hand.getSumOfCardsForGolf(), 45);
    });

    /// cards_grid_2_kings.jpeg
    ///   3   K   K
    ///   3   §  10
    ///   3   6   5
    /// Column 1 (3,3,3) → set = 0 → score = 0+0+(-2)+10+6+5 = 19
    test('cards_grid_2_kings: score is 19', () {
      final hand = _hand3x3([
        _num(3),
        _king(),
        _king(),
        _num(3),
        _joker(),
        _num(10),
        _num(3),
        _num(6),
        _num(5),
      ]);
      expect(hand.getSumOfCardsForGolf(), 19);
    });

    /// cards_grid_all_aces.jpeg
    ///   A   A   A
    ///   A   §   A
    ///   A   A   A
    /// Row 0 (A,A,A) → set → claims positions 0,1,2
    /// Row 2 (A,A,A) → set → claims positions 6,7,8
    /// Middle row: A,§,A — joker breaks rank match → not a set
    /// Col 0 [0,3,6]: position 0 already claimed → col skipped
    /// Col 1 [1,4,7]: position 1 already claimed → col skipped
    /// Col 2 [2,5,8]: position 2 already claimed → col skipped
    /// Remaining un-claimed cards: A(1) + §(-2) + A(1) = 0
    test('cards_grid_all_aces: score is 0', () {
      final hand = _hand3x3([
        _ace(),
        _ace(),
        _ace(),
        _ace(),
        _joker(),
        _ace(),
        _ace(),
        _ace(),
        _ace(),
      ]);
      expect(hand.getSumOfCardsForGolf(), 0);
    });

    /// cards_grid_zero.jpeg
    ///   K   K   K
    ///   J   J   J
    ///   6   6   6
    /// All three rows are matching sets → score = 0
    test('cards_grid_zero: score is 0', () {
      final hand = _hand3x3([
        _king(),
        _king(),
        _king(),
        _jack(),
        _jack(),
        _jack(),
        _num(6),
        _num(6),
        _num(6),
      ]);
      expect(hand.getSumOfCardsForGolf(), 0);
    });
  });

  group('Golf score – row/column overlap correctness', () {
    /// A card used in a row triple is unavailable for column checks.
    ///
    ///   Q   K   Q
    ///   Q   Q   Q   ← row set (claims positions 3,4,5)
    ///   Q   K   Q
    ///
    /// Col 0 [0,3,6]: position 3 already claimed → col skipped
    /// Col 2 [2,5,8]: position 5 already claimed → col skipped
    /// score = Q(12)+K(0)+Q(12) + 0+0+0 + Q(12)+K(0)+Q(12) = 48
    test('row set prevents overlapping column from being a set', () {
      final hand = _hand3x3([
        _queen(),
        _king(),
        _queen(),
        _queen(),
        _queen(),
        _queen(),
        _queen(),
        _king(),
        _queen(),
      ]);
      expect(hand.getSumOfCardsForGolf(), 48);
    });

    /// Variant with non-zero values to make the overlap rule explicit.
    ///
    ///   J   K   J
    ///   J   J   J   ← row set claims positions 3,4,5
    ///   J   K   J
    ///
    /// Col 0 [0,3,6]: position 3 claimed → col skipped
    /// Col 2 [2,5,8]: position 5 claimed → col skipped
    /// score = J(11)+K(0)+J(11) + 0+0+0 + J(11)+K(0)+J(11) = 44
    test('row set blocks column — jacks score 44 not 0', () {
      final hand = _hand3x3([
        _jack(),
        _king(),
        _jack(),
        _jack(),
        _jack(),
        _jack(),
        _jack(),
        _king(),
        _jack(),
      ]);
      expect(hand.getSumOfCardsForGolf(), 44);
    });

    /// Column-only set with no row matches.
    ///
    ///   A   2   3
    ///   A   5   6
    ///   A   8   9   ← col 0 = A,A,A → set
    ///
    /// score = 2+3+5+6+8+9 = 33
    test('column set leaves non-matching rows fully scored', () {
      final hand = _hand3x3([
        _ace(),
        _num(2),
        _num(3),
        _ace(),
        _num(5),
        _num(6),
        _ace(),
        _num(8),
        _num(9),
      ]);
      expect(hand.getSumOfCardsForGolf(), 33);
    });

    /// Three Jokers in a column must NOT cancel each other.
    ///
    ///   §   A   A
    ///   §   A   A
    ///   §   A   A
    ///
    /// col 0 is not a valid set because Jokers are excluded from zeroing.
    /// col 1 and col 2 are valid Ace sets. score = -2 + -2 + -2 = -6
    test('three jokers in a column score -6 not 0', () {
      final hand = _hand3x3([
        _joker(),
        _ace(),
        _ace(),
        _joker(),
        _ace(),
        _ace(),
        _joker(),
        _ace(),
        _ace(),
      ]);
      expect(hand.getSumOfCardsForGolf(), -6);
    });
  });

  group('Golf score – idempotency (stale partOfSet state)', () {
    /// Calling getSumOfCardsForGolf() multiple times on the same hand must
    /// return the same value each time.
    test('repeated calls on no-set hand return same score', () {
      final hand = _hand3x3([
        _jack(),
        _num(10),
        _ace(),
        _num(6),
        _num(9),
        _joker(),
        _king(),
        _num(4),
        _num(5),
      ]);
      final first = hand.getSumOfCardsForGolf();
      final second = hand.getSumOfCardsForGolf();
      expect(first, 44);
      expect(second, 44);
    });

    test('repeated calls on set-containing hand return same score', () {
      final hand = _hand3x3([
        _king(),
        _king(),
        _king(),
        _jack(),
        _jack(),
        _jack(),
        _num(6),
        _num(6),
        _num(6),
      ]);
      final first = hand.getSumOfCardsForGolf();
      final second = hand.getSumOfCardsForGolf();
      expect(first, 0);
      expect(second, 0);
    });
  });
}
