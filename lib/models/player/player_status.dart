/// This class represents the current status of a player in a game. It stores two
/// fields: an emoji and a phrase. The emoji is used to display a visual
/// representation of the player's status, while the phrase provides a brief
/// description of their state.
class PlayerStatus {
  /// Creates a new [PlayerStatus] instance.
  ///
  /// This constructor initializes a [PlayerStatus] object with optional [emoji] and [phrase] parameters.
  ///
  /// Parameters:
  /// - [emoji]: A [String] representing the emoji associated with the player's status.
  ///   Defaults to an empty string if not provided.
  /// - [phrase]: A [String] describing the player's status in words.
  ///   Defaults to an empty string if not provided.
  ///
  /// Returns a new [PlayerStatus] instance with the specified emoji and phrase.
  PlayerStatus({this.emoji = '', this.phrase = ''});

  /// This constructor creates a new `PlayerStatus` instance from a JSON object.
  /// It expects the JSON object to have two fields: 'emoji' and 'phrase'. The
  /// value of these fields is used to initialize the corresponding fields in
  /// the newly created `PlayerStatus` instance.
  factory PlayerStatus.fromJson(Map<String, dynamic>? json) {
    return PlayerStatus(
      emoji: json?['emoji'] ?? '',
      phrase: json?['phrase'] ?? '',
    );
  }

  /// The emoji representing the player's status.
  ///
  /// This field stores a [String] that contains an emoji character
  /// used to visually represent the player's current status.
  final String emoji;

  /// A brief phrase describing the player's status.
  ///
  /// This field stores a [String] that provides a short textual
  /// description of the player's current status.
  final String phrase;

  /// Converts the [PlayerStatus] instance to a JSON-compatible [Map].
  ///
  /// This method creates a [Map] representation of the [PlayerStatus] object,
  /// which can be easily serialized to JSON format.
  ///
  /// Returns:
  /// A [Map] with two key-value pairs:
  /// - 'emoji': The [String] value of the [emoji] field.
  /// - 'phrase': The [String] value of the [phrase] field.
  Map toJson() => {'emoji': emoji, 'phrase': phrase};
}

/// Standard status to choose from
final List<PlayerStatus> playersStatuses = [
  PlayerStatus(emoji: '', phrase: ''),
  PlayerStatus(emoji: '😊', phrase: 'Feeling Good!'),
  PlayerStatus(emoji: '🤢', phrase: 'BRB'),
  PlayerStatus(emoji: '🤔', phrase: 'Thinking...'),
  PlayerStatus(emoji: '😙', phrase: 'Voila!'),
  PlayerStatus(emoji: '😱', phrase: 'Oh NO!'),
];

/// Finds a matching [PlayerStatus] instance from the [playersStatuses] list.
///
/// This function searches through the predefined list of player statuses and
/// returns the first instance that matches both the provided [emoji] and [phrase].
///
/// Parameters:
/// - [emoji]: The emoji string to match against
/// - [phrase]: The phrase string to match against
///
/// Returns:
/// - The matching [PlayerStatus] instance if found
/// - A new empty [PlayerStatus] instance if no match is found
PlayerStatus findMatchingPlayerStatusInstance(String emoji, String phrase) {
  for (final PlayerStatus status in playersStatuses) {
    if (status.emoji == emoji && status.phrase == phrase) {
      return status;
    }
  }
  return PlayerStatus();
}
