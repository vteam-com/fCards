import 'package:cards/models/constants.dart';

/// Represents a playing card with a suit and rank.
///
/// The [CardModel] class represents a single playing card, with properties for the suit, rank, and whether the card is revealed. It provides methods for converting the card to and from JSON, as well as getting the numerical value of the card.
///
/// The [suits] and [ranks] static lists define the valid suits and ranks for a standard deck of playing cards.
class CardModel {
  /// Creates a [CardModel] from a JSON map.
  ///
  /// The JSON map should contain the keys 'suit', 'rank', and optionally 'value' and 'isRevealed'.
  /// If 'value' is not present, it attempts to parse the rank as an integer.
  /// If 'isRevealed' is not present, it defaults to false.
  ///
  /// @param json The JSON map representing the card.
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

  /// Creates a new [CardModel].
  ///
  /// @param suit The suit of the card.
  /// @param rank The rank of the card.
  /// @param value The numerical value of the card.
  /// @param partOfSet Indicates whether the card is part of a set of same Rank for a granting a total of zero points. Defaults to false.
  /// @param isRevealed Indicates whether the card is currently revealed or hidden. Defaults to false.
  CardModel({
    required this.suit,
    required this.rank,
    required this.value,
    this.partOfSet = false,
    this.isRevealed = false,
  });

  /// The suit of the card.
  final String suit;

  /// The rank of the card.
  final String rank;

  /// The numerical value of the card.
  final int value;

  /// Indicates whether the card is currently revealed or hidden.
  bool isRevealed = false;

  /// Indicates whether the card is selectable by the user.
  bool isSelectable = false;

  /// Indicates whether the card is part of a set of same Rank for a granting a total of zero points
  bool partOfSet;

  /// Returns a string representation of the card.
  ///
  /// The string includes the rank, suit, value, reveal state, and selectability.
  @override
  String toString() {
    return '$rank$suit${value.toString().padLeft(Constants.cardDisplayPaddingWidth)}${isRevealed ? '^' : 'v'}${isSelectable ? 'S' : ' '}';
  }

  /// Converts the [CardModel] to a JSON map.
  ///
  /// The JSON map includes the keys 'suit', 'rank', 'value', and optionally 'isRevealed' if it is true.
  ///
  /// @return A JSON map representing the card.
  Map<String, dynamic> toJson() {
    return {
      'suit': suit,
      'rank': rank,
      'value': value,
      'isRevealed': isRevealed ? true : null,
    };
  }
}
