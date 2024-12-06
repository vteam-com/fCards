import 'package:cards/models/base/card_model.dart';
export 'package:cards/models/base/card_model.dart';

class PlayerModel {
  /// Creates a `PlayerModel` from a JSON map.
  ///
  /// This factory constructor takes a JSON map representing a player and
  /// constructs a `PlayerModel` instance.  It parses the player's name, hand,
  /// and card visibility from the JSON data.
  ///
  /// Args:
  ///   json (Map<String, dynamic>): The JSON map representing the player.
  ///       This map should contain the keys 'name', 'hand', and
  ///       'cardVisibility'.  The 'hand' value should be a list of JSON maps
  ///       representing cards, and the 'cardVisibility' value should be a list
  ///       of booleans.
  ///
  /// Returns:
  ///   PlayerModel: A new `PlayerModel` instance initialized with the data from
  ///       the JSON map.
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    // Create a list of CardModel objects from the 'hand' JSON data.
    final hand = (json['hand'] as List<dynamic>)
        .map((cardJson) => CardModel.fromJson(cardJson as Map<String, dynamic>))
        .toList();

    // Create a new PlayerModel instance with the parsed data.
    return PlayerModel(
      name: json['name'] as String,
    )..hand = hand;
  }

  ///
  /// Creates a `PlayerModel` with the given name.
  ///
  PlayerModel({required this.name});

  /// Properties
  int id = -1;
  final String name;
  bool isActivePlayer = false;
  int get sumOfRevealedCards => getSumOfCardsInHand();
  List<CardModel> hand = [];

  void reset() {
    hand = [];
  }

  bool areAllCardsRevealed() {
    return hand.every((card) => card.isRevealed);
  }

  void addCardToHand(CardModel card) {
    hand.add(card);
  }

  void revealInitialCards() {
    hand[3].isRevealed = true;
    hand[5].isRevealed = true;
  }

  int getSumOfCardsInHand() {
    int score = 0;
    for (final CardModel card in hand) {
      if (card.isRevealed) {
        score += card.value;
      }
    }

    return score;
  }

  bool areAllTheSameRankAndNotAlreadyUsed(
    CardModel card1,
    CardModel card2,
    CardModel card3,
  ) {
    return !(card1.partOfSet || card2.partOfSet || card3.partOfSet) &&
        areAllTheSameRank(card1.rank, card2.rank, card3.rank);
  }

  bool areAllTheSameRank(String rank1, String rank2, String rank3) {
    return rank1 == rank2 && rank2 == rank3;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hand': hand.map((CardModel card) => card.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Player[$id] ${name.padRight(10)} ${isActivePlayer ? "* " : '  '} ${hand.join(" ")} ${sumOfRevealedCards.toString().padLeft(3)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PlayerModel &&
        other.id == id &&
        other.name == name &&
        other.isActivePlayer == isActivePlayer &&
        other.hand.length == hand.length &&
        List.generate(hand.length, (i) => hand[i] == other.hand[i])
            .every((bool equalResult) => equalResult);
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isActivePlayer, Object.hashAll(hand));
}
