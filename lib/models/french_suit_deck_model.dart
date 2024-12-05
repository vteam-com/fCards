import 'package:cards/models/french_suit_card_model.dart';
import 'package:cards/models/game_model.dart';
export 'package:cards/models/card_model.dart';

class FrenchSuitDeckModel extends DeckModel {
  FrenchSuitDeckModel({required super.numberOfDecks});

  factory FrenchSuitDeckModel.fromJson(Map<String, dynamic> json) {
    return FrenchSuitDeckModel(numberOfDecks: json['numberOfDecks'] ?? 1)
      ..cardsDeckPile = List<FrenchSuitCardModel>.from(
        json['cardsDeckPile']
                ?.map((card) => FrenchSuitCardModel.fromJson(card)) ??
            [],
      )
      ..cardsDeckDiscarded = List<FrenchSuitCardModel>.from(
        json['cardsDeckDiscarded']
                ?.map((card) => FrenchSuitCardModel.fromJson(card)) ??
            [],
      );
  }

  @override
  void addCardsToDeck() {
    for (String suit in FrenchSuitCardModel.suits) {
      for (String rank in FrenchSuitCardModel.ranks) {
        cardsDeckPile.add(
          FrenchSuitCardModel(
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
}
