import 'package:cards/models/deck_model.dart';
import 'package:cards/models/game_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeckModel', () {
    test('shuffle should clear the previous state', () {
      DeckModel deck = DeckModel(
        numberOfDecks: 2,
        gameStyle: GameStyles.frenchCards9,
      );

      deck.shuffle();
      deck.cardsDeckDiscarded.add(deck.cardsDeckPile.removeLast());
      deck.shuffle();
      expect(deck.cardsDeckDiscarded.length, 0);
      expect(deck.cardsDeckPile.length, 108);
    });
  });
}
