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
    // Create a new PlayerModel instance with the parsed data.
    final GolfPlayerModel instance =
        GolfPlayerModel(name: json['name'] as String);

    // Status
    instance.status = PlayerStatus.fromJson(json['status']);

    // Hand
    instance.hand = HandModel(
      3,
      3,
      (json['hand'] as List<dynamic>)
          .map(
            (cardJson) => GolfFrenchSuitCardModel.fromJson(
              cardJson as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

    return instance;
  }

  ///
  /// Creates a `PlayerModel` with the given name.
  ///
  GolfPlayerModel({required super.name});
}
