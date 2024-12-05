import 'package:cards/models/game_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'DeckModel',
    () {
      test(
        'shuffle should clear the previous state',
        () {
          DeckModel deck = DeckModel(2);

          deck.shuffle(numberOfDecks: 2);
          deck.cardsDeckDiscarded.add(deck.cardsDeckPile.removeLast());
          deck.shuffle(numberOfDecks: 2);
          expect(deck.cardsDeckDiscarded.length, 0);
          expect(deck.cardsDeckPile.length, 108);
        },
      );
    },
  );
}
