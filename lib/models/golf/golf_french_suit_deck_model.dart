import 'package:cards/models/base/game_model.dart';
import 'package:cards/models/golf/golf_french_suit_card_model.dart';
export 'package:cards/models/base/card_model.dart';

class GolfFrenchSuitDeckModel extends DeckModel {
  GolfFrenchSuitDeckModel({required super.numberOfDecks});

  factory GolfFrenchSuitDeckModel.fromJson(Map<String, dynamic> json) {
    return GolfFrenchSuitDeckModel(numberOfDecks: json['numberOfDecks'] ?? 1)
      ..cardsDeckPile = List<GolfFrenchSuitCardModel>.from(
        json['cardsDeckPile']
                ?.map((card) => GolfFrenchSuitCardModel.fromJson(card)) ??
            [],
      )
      ..cardsDeckDiscarded = List<GolfFrenchSuitCardModel>.from(
        json['cardsDeckDiscarded']
                ?.map((card) => GolfFrenchSuitCardModel.fromJson(card)) ??
            [],
      );
  }

  @override
  void addCardsToDeck() {
    for (String suit in GolfFrenchSuitCardModel.suits) {
      for (String rank in GolfFrenchSuitCardModel.ranks) {
        cardsDeckPile.add(
          GolfFrenchSuitCardModel(
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
