import 'package:cards/misc.dart';
import 'package:cards/models/card_model.dart';
import 'package:cards/models/card_model_french.dart';
export 'package:cards/models/card_model.dart';

enum GameStyles {
  frenchCards9,
  skyJo,
  custom,
}

GameStyles intToGameStyles(final int gameStyleIndex) {
  // Validate that the index is within the valid range of GameStyles values.
  if (gameStyleIndex >= 0 && gameStyleIndex < GameStyles.values.length) {
    return GameStyles.values[gameStyleIndex];
  } else {
    // Handle the error case where the index is out of range.
    // You can throw an exception, return a default value, or log an error.
    // Here, we return a default value and log an error message.
    debugLog('Invalid gameStyleIndex: $gameStyleIndex');
    return GameStyles.frenchCards9; // Or whatever your default GameStyle is
  }
}

class DeckModel {
  factory DeckModel.fromJson(
    final Map<String, dynamic> json,
    final GameStyles gameStyle,
  ) {
    final DeckModel newDeck = DeckModel(
      numberOfDecks: json['numberOfDecks'] ?? 1,
      gameStyle: gameStyle,
    );
    newDeck.loadFromJson(json);
    return newDeck;
  }
  DeckModel({
    required this.numberOfDecks,
    required this.gameStyle,
  });

  GameStyles gameStyle;

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
    if (gameStyle == GameStyles.skyJo) {
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
    for (String suit in CardModelFrench.suits) {
      for (String rank in CardModelFrench.ranks) {
        cardsDeckPile.add(
          CardModel(
            suit: suit,
            rank: rank,
            value: CardModelFrench.getValue(rank),
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
