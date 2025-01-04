import 'package:cards/models/card_model.dart';
import 'package:cards/models/card_model_french.dart';
import 'package:cards/models/game_style.dart';
export 'package:cards/models/card_model.dart';

/// Represents a deck of playing cards.
///
/// The [DeckModel] class manages a collection of playing cards, including the main deck pile and discarded cards.
/// It provides methods for shuffling the deck, adding cards, and converting the deck to and from JSON.
class DeckModel {
  /// Creates a [DeckModel] from a JSON map.
  ///
  /// The JSON map should contain the keys 'numberOfDecks', 'cardsDeckPile', and 'cardsDeckDiscarded'.
  /// If 'numberOfDecks' is not present, it defaults to 1.
  /// The 'cardsDeckPile' and 'cardsDeckDiscarded' are lists of card objects.
  ///
  /// @param json The JSON map representing the deck.
  /// @param gameStyle The game style to use for the deck.
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

  /// Creates a new [DeckModel].
  ///
  /// @param numberOfDecks The number of decks to include in this deck.
  /// @param gameStyle The game style to use for the deck.
  DeckModel({
    required this.numberOfDecks,
    required this.gameStyle,
  });

  /// The game style to use for the deck.
  GameStyles gameStyle;

  /// Loads the deck from a JSON map.
  ///
  /// This method populates the `cardsDeckPile` and `cardsDeckDiscarded` lists from the provided JSON data.
  ///
  /// @param json The JSON map containing the deck data.
  void loadFromJson(Map<String, dynamic> json) {
    cardsDeckPile = List<CardModel>.from(
      json['cardsDeckPile']?.map((card) => CardModel.fromJson(card)) ?? [],
    );

    cardsDeckDiscarded = List<CardModel>.from(
      json['cardsDeckDiscarded']?.map((card) => CardModel.fromJson(card)) ?? [],
    );
  }

  /// The number of decks included in this deck.
  int numberOfDecks = 0;

  /// The main pile of cards in the deck.
  List<CardModel> cardsDeckPile = [];

  /// The pile of discarded cards.
  List<CardModel> cardsDeckDiscarded = [];

  /// Shuffles the deck.
  ///
  /// This method clears the existing deck and discarded piles, generates the specified number of decks, and then shuffles the main deck pile.
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

  /// Adds cards to the deck based on the game style.
  ///
  /// If the game style is `skyJo`, it adds cards with values from -2 to 12.
  /// Otherwise, it calls `addCardsToDeckGolf()` to add cards for a standard French-suited deck.
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

  /// Adds cards for a standard French-suited deck.
  ///
  /// This method adds cards with suits and ranks from `CardModelFrench.suits` and `CardModelFrench.ranks`,
  /// and adds two Jokers to the deck.
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

  /// Converts the [DeckModel] to a JSON map.
  ///
  /// The JSON map includes the keys 'numberOfDecks', 'cardsDeckPile', and 'cardsDeckDiscarded'.
  ///
  /// @return A JSON map representing the deck.
  Map<String, dynamic> toJson() => {
        'numberOfDecks': numberOfDecks,
        'cardsDeckPile': cardsDeckPile.map((card) => card.toJson()).toList(),
        'cardsDeckDiscarded':
            cardsDeckDiscarded.map((card) => card.toJson()).toList(),
      };
}
