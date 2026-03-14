import 'package:cards/gen/l10n/app_localizations_en.dart';

final AppLocalizationsEn _fallbackLocalizations = AppLocalizationsEn();

const String playerStatusKeyFeelingGood = 'feelingGood';
const String playerStatusKeyBrb = 'brb';
const String playerStatusKeyThinking = 'thinking';
const String playerStatusKeyVoila = 'voila';
const String playerStatusKeyOhNo = 'ohNo';

/// Player status metadata persisted with a player.
///
/// Uses a stable [key] for localization while still carrying a [phrase] for
/// backward compatibility.
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
  PlayerStatus({this.emoji = '', this.key = '', this.phrase = ''});

  /// This constructor creates a new `PlayerStatus` instance from a JSON object.
  /// It expects the JSON object to have two fields: 'emoji' and 'phrase'. The
  /// value of these fields is used to initialize the corresponding fields in
  /// the newly created `PlayerStatus` instance.
  factory PlayerStatus.fromJson(Map<String, dynamic>? json) {
    final String emoji = json?['emoji'] ?? '';
    final String key = json?['key'] ?? '';
    final String phrase = json?['phrase'] ?? '';

    if (key.isNotEmpty) {
      return PlayerStatus(emoji: emoji, key: key, phrase: phrase);
    }

    return PlayerStatus(
      emoji: emoji,
      key: keyFromLegacyPhrase(phrase),
      phrase: phrase,
    );
  }

  /// Converts a legacy, previously persisted phrase into a stable status key.
  static String keyFromLegacyPhrase(String phrase) {
    if (phrase == _fallbackLocalizations.statusFeelingGood) {
      return playerStatusKeyFeelingGood;
    }
    if (phrase == _fallbackLocalizations.statusBrb) {
      return playerStatusKeyBrb;
    }
    if (phrase == _fallbackLocalizations.statusThinking) {
      return playerStatusKeyThinking;
    }
    if (phrase == _fallbackLocalizations.statusVoila) {
      return playerStatusKeyVoila;
    }
    if (phrase == _fallbackLocalizations.statusOhNo) {
      return playerStatusKeyOhNo;
    }
    return '';
  }

  /// The emoji representing the player's status.
  ///
  /// This field stores a [String] that contains an emoji character
  /// used to visually represent the player's current status.
  final String emoji;

  /// Stable status key used for localization.
  ///
  /// This should be persisted instead of a localized phrase.
  final String key;

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
  Map toJson() => {'emoji': emoji, 'key': key, 'phrase': phrase};
}

/// Standard status to choose from
final List<PlayerStatus> playersStatuses = [
  PlayerStatus(emoji: '', key: '', phrase: ''),
  PlayerStatus(
    emoji: '😊',
    key: playerStatusKeyFeelingGood,
    phrase: _fallbackLocalizations.statusFeelingGood,
  ),
  PlayerStatus(
    emoji: '🤢',
    key: playerStatusKeyBrb,
    phrase: _fallbackLocalizations.statusBrb,
  ),
  PlayerStatus(
    emoji: '🤔',
    key: playerStatusKeyThinking,
    phrase: _fallbackLocalizations.statusThinking,
  ),
  PlayerStatus(
    emoji: '😙',
    key: playerStatusKeyVoila,
    phrase: _fallbackLocalizations.statusVoila,
  ),
  PlayerStatus(
    emoji: '😱',
    key: playerStatusKeyOhNo,
    phrase: _fallbackLocalizations.statusOhNo,
  ),
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
  final String legacyKey = PlayerStatus.keyFromLegacyPhrase(phrase);
  for (final PlayerStatus status in playersStatuses) {
    final bool isPhraseMatch = status.phrase == phrase;
    final bool isKeyMatch = legacyKey.isNotEmpty && status.key == legacyKey;
    if (status.emoji == emoji && (isPhraseMatch || isKeyMatch)) {
      return status;
    }
  }
  return PlayerStatus();
}
