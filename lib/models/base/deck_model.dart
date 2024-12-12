import 'package:cards/models/base/game_model.dart';
import 'package:cards/models/base/golf_french_suit_card_model.dart';
export 'package:cards/models/base/card_model.dart';

class DeckModel {
  factory DeckModel.fromJson(Map<String, dynamic> json, String gameMode) {
    final DeckModel newDeck = DeckModel(
      numberOfDecks: json['numberOfDecks'] ?? 1,
      gameMode: gameMode,
    );
    newDeck.loadFromJson(json);
    return newDeck;
  }
  DeckModel({required this.numberOfDecks, this.gameMode = ''});

  String gameMode;

  void loadFromJson(Map<String, dynamic> json) {
    cardsDeckPile = List<CardModel>.from(
      json['cardsDeckPile']?.map((card) => CardModel.fromJson(card)) ?? [],
    );

    cardsDeckDiscarded = List<CardModel>.from(
      json['cardsDeckDiscarded']?.map((card) => CardModel.fromJson(card)) ?? [],
    );
  }

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

  void addCardsToDeck() {
    if (gameMode == gameModeSkyJo) {
      for (int i = -2; i <= 12; i++) {
        int count = i == 0
            ? 15
            : i == -2
                ? 5
                : 10;
        for (int j = 0; j < count; j++) {
          cardsDeckPile.add(
            CardModel(
              suit: '',
              rank: i.toString(),
              value: i,
            ),
          );
        }
      }
    } else {
      addCardsToDeckGolf();
    }
  }

  void addCardsToDeckGolf() {
    for (String suit in GolfFrenchSuitCardModel.suits) {
      for (String rank in GolfFrenchSuitCardModel.ranks) {
        cardsDeckPile.add(
          GolfFrenchSuitCardModel(
            suit: suit,
            rank: rank,
            value: GolfFrenchSuitCardModel.getValue(rank),
          ),
        );
      }
    }
    // Add 2 Jokers to each deck
    cardsDeckPile.addAll([
      CardModel(suit: '*', rank: '§', value: -2),
      CardModel(suit: '*', rank: '§', value: -2),
    ]);
  }

  Map<String, dynamic> toJson() => {
        'numberOfDecks': numberOfDecks,
        'cardsDeckPile': cardsDeckPile.map((card) => card.toJson()).toList(),
        'cardsDeckDiscarded':
            cardsDeckDiscarded.map((card) => card.toJson()).toList(),
      };
}
