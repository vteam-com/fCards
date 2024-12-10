import 'package:cards/models/base/card_model.dart';
import 'package:cards/models/base/player_status.dart';
export 'package:cards/models/base/card_model.dart';
export 'package:cards/models/base/player_status.dart';

class PlayerModel {
  ///
  /// Creates a `PlayerModel` with the given name.
  ///
  PlayerModel({required this.name});

  /// Properties
  int id = -1;
  final String name;
  PlayerStatus status = playersStatuses.first;
  bool isActivePlayer = false;

  // Keep track of winnings
  bool isWinner = false;

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
      'status': status.toJson(),
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
