import 'package:cards/models/base/game_model.dart';
import 'package:cards/models/golf/golf_french_suit_card_model.dart';
export 'package:cards/models/base/card_model.dart';

class GolfPlayerModel extends PlayerModel {
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
  factory GolfPlayerModel.fromJson(Map<String, dynamic> json) {
    // Create a list of CardModel objects from the 'hand' JSON data.
    final hand = (json['hand'] as List<dynamic>)
        .map(
          (cardJson) => GolfFrenchSuitCardModel.fromJson(
            cardJson as Map<String, dynamic>,
          ),
        )
        .toList();

    // Create a new PlayerModel instance with the parsed data.
    return GolfPlayerModel(
      name: json['name'] as String,
    )..hand = hand;
  }

  ///
  /// Creates a `PlayerModel` with the given name.
  ///
  GolfPlayerModel({required super.name});

  /// Properties
  @override
  int getSumOfCardsInHand() {
    int score = 0;
    List<bool> markedForZeroScore = List.filled(hand.length, false);

    List<List<int>> checkingIndices = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      // [0, 4, 8], // Diagonal from top-left to bottom-right
      // [2, 4, 6], // Diagonal from top-right to bottom-left
    ];

    for (final List<int> indices in checkingIndices) {
      markIfSameRank(hand, markedForZeroScore, indices);
    }

    for (final CardModel card in hand) {
      if (card.isRevealed && card.partOfSet == false) {
        score += card.value;
      }
    }

    return score;
  }

  void markIfSameRank(
    List<CardModel> hand,
    List<bool> markedForZeroScore,
    List<int> indices,
  ) {
    if (indices.length == 3 &&
        areAllTheSameRankAndNotAlreadyUsed(
          hand[indices[0]],
          hand[indices[1]],
          hand[indices[2]],
        )) {
      for (final int index in indices) {
        if (hand[index].rank != '§') {
          hand[index].partOfSet = true;
        }
      }
    }
  }
}
