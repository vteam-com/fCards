import 'package:cards/models/golf/french_suit_deck_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'DeckModel',
    () {
      test(
        'shuffle should clear the previous state',
        () {
          FrenchSuitDeckModel deck = FrenchSuitDeckModel(numberOfDecks: 2);

          deck.shuffle();
          deck.cardsDeckDiscarded.add(deck.cardsDeckPile.removeLast());
          deck.shuffle();
          expect(deck.cardsDeckDiscarded.length, 0);
          expect(deck.cardsDeckPile.length, 108);
        },
      );
    },
  );
}
