import 'package:cards/models/card_model.dart';
export 'package:cards/models/card_model.dart';

abstract class DeckModel {
  DeckModel({required this.numberOfDecks});

  int numberOfDecks = 0;

  List<CardModel> cardsDeckPile = [];
  List<CardModel> cardsDeckDiscarded = [];

  void shuffle() {
    this.numberOfDecks = numberOfDecks;
    cardsDeckPile = [];
    cardsDeckDiscarded = [];

    // Generate the specified number of decks
    for (int deckCount = 0; deckCount < numberOfDecks; deckCount++) {
      addCardsToDeck();
    }

    cardsDeckPile.shuffle();
  }

  void addCardsToDeck();

  Map<String, dynamic> toJson() => {
        'numberOfDecks': numberOfDecks,
        'cardsDeckPile': cardsDeckPile.map((card) => card.toJson()).toList(),
        'cardsDeckDiscarded':
            cardsDeckDiscarded.map((card) => card.toJson()).toList(),
      };
}
