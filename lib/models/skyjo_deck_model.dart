import 'package:cards/models/deck_model.dart';
import 'package:cards/models/skyjo_card_model.dart';
export 'package:cards/models/card_model.dart';

class SkyjoDeckModel extends DeckModel {
  SkyjoDeckModel({required super.numberOfDecks});

  factory SkyjoDeckModel.fromJson(Map<String, dynamic> json) {
    return SkyjoDeckModel(numberOfDecks: json['numberOfDecks'] ?? 1)
      ..cardsDeckPile = List<SkyjoCardModel>.from(
        json['cardsDeckPile']?.map((card) => SkyjoCardModel.fromJson(card)) ??
            [],
      )
      ..cardsDeckDiscarded = List<SkyjoCardModel>.from(
        json['cardsDeckDiscarded']
                ?.map((card) => SkyjoCardModel.fromJson(card)) ??
            [],
      );
  }

  @override
  void addCardsToDeck() {
    for (int i = -2; i <= 12; i++) {
      int count = i == 0
          ? 15
          : i == -2
              ? 5
              : 10;
      for (int j = 0; j < count; j++) {
        cardsDeckPile.add(SkyjoCardModel(suit: '*', rank: i.toString()));
      }
    }
  }
}
