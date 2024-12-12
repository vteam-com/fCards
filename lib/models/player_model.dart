import 'package:cards/misc.dart';
import 'package:cards/models/hand_model.dart';
import 'package:cards/models/player_status.dart';

export 'package:cards/models/card_model.dart';
export 'package:cards/models/hand_model.dart';
export 'package:cards/models/player_status.dart';

class PlayerModel {
  ///
  /// Creates a `PlayerModel` with the given name.
  ///
  PlayerModel({
    required this.name,
    required this.columns,
    required this.rows,
    required this.skyJoLogic,
  }) {
    clear();
  }

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
  factory PlayerModel.fromJson({
    required final Map<String, dynamic> json,
    required final int columns,
    required final int rows,
    required final bool skyJoLogic,
  }) {
    // Create a new PlayerModel instance with the parsed data.
    final PlayerModel instance = PlayerModel(
      name: json['name'] as String,
      columns: columns,
      rows: rows,
      skyJoLogic: skyJoLogic,
    );

    // Status
    instance.status = PlayerStatus.fromJson(json['status']);

    // Hand
    try {
      instance.hand = HandModel(
        columns,
        rows,
        (json['hand'] as List<dynamic>)
            .map(
              (cardJson) => CardModel.fromJson(
                cardJson as Map<String, dynamic>,
              ),
            )
            .toList(),
      );
    } catch (error) {
      debugLog(error.toString());
    }

    return instance;
  }

  /// Properties
  int id = -1;
  final String name;
  final int columns;
  final int rows;
  final bool skyJoLogic;
  PlayerStatus status = playersStatuses.first;
  bool isActivePlayer = false;

  // Keep track of winnings
  bool isWinner = false;

  int get sumOfRevealedCards {
    if (skyJoLogic) {
      return hand.getSumOfCardsInHandSkyJo();
    } else {
      return hand.getSumOfCardsForGolf();
    }
  }

  // the list of cards in hand for this player
  HandModel hand = HandModel(0, 0, []);

  void clear() {
    hand = HandModel(columns, rows, []);
  }

  bool areAllCardsRevealed() {
    return hand.areAllCardsRevealed();
  }

  void addCardToHand(CardModel card) {
    hand.add(card);
  }

  void revealInitialCards() {
    hand[3].isRevealed = true;
    hand[5].isRevealed = true;
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
      'hand': hand.toJson(),
      'status': status.toJson(),
    };
  }

  @override
  String toString() {
    return 'Player[$id] ${name.padRight(10)} ${isActivePlayer ? "* " : '  '} $hand ${sumOfRevealedCards.toString().padLeft(3)}';
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
  int get hashCode => Object.hash(id, name, isActivePlayer, hand.hashCode);
}
