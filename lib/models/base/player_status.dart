/// This class represents the current status of a player in a game. It stores two
/// fields: an emoji and a phrase. The emoji is used to display a visual
/// representation of the player's status, while the phrase provides a brief
/// description of their state.
class PlayerStatus {
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

  final String emoji;
  final String phrase;

  bool get isEmpty => emoji.isEmpty && phrase.isEmpty;

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

PlayerStatus findMatchingPlayerStatusInstance(String emoji, String phrase) {
  for (final PlayerStatus status in playersStatuses) {
    if (status.emoji == emoji && status.phrase == phrase) {
      return status;
    }
  }
  return PlayerStatus();
}
