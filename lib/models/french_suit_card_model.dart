import 'package:cards/models/card_model.dart';

/// Represents a playing card with a suit and rank.
///
/// The [CardModel] class represents a single playing card, with properties for the suit, rank, and whether the card is revealed. It provides methods for converting the card to and from JSON, as well as getting the numerical value of the card.
///
/// The [suits] and [ranks] static lists define the valid suits and ranks for a standard deck of playing cards.
class FrenchSuitCardModel extends CardModel {
  factory FrenchSuitCardModel.fromJson(Map<String, dynamic> json) {
    return FrenchSuitCardModel(
      suit: json['suit'],
      rank: json['rank'],
      isRevealed: json['isRevealed'] ?? false,
    );
  }
  FrenchSuitCardModel({
    required super.suit,
    required super.rank,
    super.partOfSet = false,
    super.isRevealed = false,
  });

  @override
  String toString() {
    return '$rank$suit${isRevealed ? '|' : '_'}${isSelectable ? 'S' : ' '}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'suit': suit,
      'rank': rank,
      'isRevealed': isRevealed ? true : null,
    };
  }

  static const List<String> suits = ['♥️', '♦️', '♣️', '♠️'];
  static const List<String> ranks = [
    'A', // Ace
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'X', // 10
    'J', // Jack
    'Q', // Queen
    'K', // King
    // '§', // Joker are special we ony generate 2 per deck, so do not include them here
  ];

  /// Returns the numerical value of a card rank.
  ///
  /// Handles 10 for for 'X', 'K', 'Q', 'J', '§'
  /// Ranks 'A' '2' through '10' return their face value.
  /// Returns 0 if the rank is invalid.
  @override
  int get value {
    if (rank == '§') {
      return 50;
    }
    if (rank == 'A') {
      return 1;
    }
    if (rank == 'X') {
      return 10;
    }
    if (rank == 'J') {
      return 10;
    }
    if (rank == 'Q') {
      return 10;
    }
    if (rank == 'K') {
      return 10;
    }

    // face value for cards from 2 to 10
    return int.tryParse(rank) ?? 0;
  }
}
