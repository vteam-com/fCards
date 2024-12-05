import 'package:cards/models/card_model.dart';

/// Represents a playing card with a suit and rank.
///
/// The [SkyjoCardModel] class represents a single playing card, with properties for the suit, rank, and whether the card is revealed. It provides methods for converting the card to and from JSON, as well as getting the numerical value of the card.
///
/// The [suits] and [ranks] static lists define the valid suits and ranks for a standard deck of playing cards.
class SkyjoCardModel extends CardModel {
  factory SkyjoCardModel.fromJson(Map<String, dynamic> json) {
    return SkyjoCardModel(
      suit: json['suit'],
      rank: json['rank'],
      isRevealed: json['isRevealed'] ?? false,
    );
  }

  SkyjoCardModel({
    required super.suit,
    required super.rank,
    super.partOfSet = false,
    super.isRevealed = false,
  });

  @override
  int get value => int.tryParse(rank) ?? 0;
}
