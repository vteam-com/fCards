/// Represents a playing card with a suit and rank.
///
/// The [CardModel] class represents a single playing card, with properties for the suit, rank, and whether the card is revealed. It provides methods for converting the card to and from JSON, as well as getting the numerical value of the card.
///
/// The [suits] and [ranks] static lists define the valid suits and ranks for a standard deck of playing cards.
class CardModel {
  factory CardModel.fromJson(Map<String, dynamic> json) {
    final String suit = json['suit'];
    final String rank = json['rank'];

    return CardModel(
      suit: suit,
      rank: rank,
      value: json['value'] ?? int.tryParse(rank),
      isRevealed: json['isRevealed'] ?? false,
    );
  }

  CardModel({
    required this.suit,
    required this.rank,
    required this.value,
    this.partOfSet = false,
    this.isRevealed = false,
  });

  // The suit and the rank of the card
  final String suit;
  final String rank;
  final int value;

  /// Indicates whether the card is currently revealed or hidden.
  bool isRevealed = false;

  /// Indicates whether the card is selectable by the user.
  bool isSelectable = false;

  /// Indicates whether the card is part of a set of same Rank for a granting a total of zero points
  bool partOfSet;

  @override
  String toString() {
    return '$rank$suit${value.toString().padLeft(2)}${isRevealed ? '^' : 'v'}${isSelectable ? 'S' : ' '}';
  }

  Map<String, dynamic> toJson() {
    return {
      'suit': suit,
      'rank': rank,
      'value': value,
      'isRevealed': isRevealed ? true : null,
    };
  }
}
