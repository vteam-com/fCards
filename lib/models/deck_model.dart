import 'package:cards/models/card_model.dart';
export 'package:cards/models/card_model.dart';

class DeckModel {
  DeckModel(this.numberOfDecks);

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(json['numberOfDecks'] ?? 1)
      ..cardsDeckPile = List<CardModel>.from(
        json['cardsDeckPile']?.map((card) => CardModel.fromJson(card)) ?? [],
      )
      ..cardsDeckDiscarded = List<CardModel>.from(
        json['cardsDeckDiscarded']?.map((card) => CardModel.fromJson(card)) ??
            [],
      );
  }
  int numberOfDecks = 0;

  List<CardModel> cardsDeckPile = [];
  List<CardModel> cardsDeckDiscarded = [];

  void shuffle({required final int numberOfDecks}) {
    this.numberOfDecks = numberOfDecks;
    cardsDeckPile = [];
    cardsDeckDiscarded = [];

    // Generate the specified number of decks
    for (int deckCount = 0; deckCount < numberOfDecks; deckCount++) {
      addSingle54CardsDeckToDecks();
    }

    cardsDeckPile.shuffle();
  }

  void addSingle54CardsDeckToDecks() {
    for (String suit in CardModel.suits) {
      for (String rank in CardModel.ranks) {
        cardsDeckPile.add(
          CardModel(
            suit: suit,
            rank: rank,
          ),
        );
      }
    }
    // Add 2 Jokers to each deck
    cardsDeckPile.addAll([
      CardModel(suit: '*', rank: '§'),
      CardModel(suit: '*', rank: '§'),
    ]);
  }

  Map<String, dynamic> toJson() => {
        'numberOfDecks': numberOfDecks,
        'cardsDeckPile': cardsDeckPile.map((card) => card.toJson()).toList(),
        'cardsDeckDiscarded':
            cardsDeckDiscarded.map((card) => card.toJson()).toList(),
      };
}
