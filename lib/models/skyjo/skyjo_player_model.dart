import 'package:cards/models/base/game_model.dart';
import 'package:cards/models/skyjo/skyjo_card_model.dart';
export 'package:cards/models/base/card_model.dart';

class SkyjoPlayerModel extends PlayerModel {
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
  factory SkyjoPlayerModel.fromJson(Map<String, dynamic> json) {
    // Create a new PlayerModel instance with the parsed data.
    final SkyjoPlayerModel instance =
        SkyjoPlayerModel(name: json['name'] as String);

    // Status
    instance.status = PlayerStatus.fromJson(json['status']);

    // Create a list of CardModel objects from the 'hand' JSON data.
    instance.hand = (json['hand'] as List<dynamic>)
        .map(
          (cardJson) =>
              SkyjoCardModel.fromJson(cardJson as Map<String, dynamic>),
        )
        .toList();

    return instance;
  }

  ///
  /// Creates a `SkyjoPlayerModel` with the given name.
  ///
  SkyjoPlayerModel({required super.name});
}
