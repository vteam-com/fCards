/// Shared card rank label parsing and scoring logic used by both the native
/// and web [TfliteService] implementations.
class TfliteRankParser {
  TfliteRankParser._();

  static const String _rankJoker = 'joker';
  static const String _rankAce = 'ace';
  static const String _rankJack = 'jack';
  static const String _rankQueen = 'queen';
  static const String _rankKing = 'king';
  static const String _displayJoker = 'Joker';
  static const String _displayAce = 'Ace';
  static const String _displayJack = 'Jack';
  static const String _displayQueen = 'Queen';
  static const String _displayKing = 'King';
  static const String _shortAce = 'a';
  static const String _shortJack = 'j';
  static const String _shortQueen = 'q';
  static const String _shortKing = 'k';

  /// Public Joker score value used externally (e.g. default for undetected cells).
  static const int jokerRankValue = -2;
  static const int _rankValueJoker = jokerRankValue;

  /// Numeric rank value for Ace.
  static const int rankValueAce = 1;
  static const int _rankValueAce = rankValueAce;

  /// Numeric rank value for Jack.
  static const int rankValueJack = 11;
  static const int _rankValueJack = rankValueJack;

  /// Numeric rank value for Queen.
  static const int rankValueQueen = 12;
  static const int _rankValueQueen = rankValueQueen;

  /// Numeric rank value for King.
  static const int rankValueKing = 0;
  static const int _rankValueKing = rankValueKing;

  /// Normalizes a raw model label string to a canonical rank display name.
  /// Strips all suit information (clubs, diamonds, hearts, spades).
  static String normalizeRankLabel(String label) {
    var normalized = label.toLowerCase().trim();

    if (normalized.contains(_rankJoker)) {
      return _displayJoker;
    }

    // Strip suit letters (c, d, h, s) and 'of' entirely
    normalized = normalized
        .replaceAll(RegExp(r'\s*of\s*'), ' ')
        .replaceAll(RegExp(r'[cdhs](?:\s|$|_)'), ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Extract the first remaining word (the rank)
    final parts = normalized.split(' ');
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return _toDisplayRank(parts.first);
    }

    return _toDisplayRank(normalized);
  }

  /// Maps a short rank token (e.g. 'a', 'j', 'q', 'k', '1', 'three') to its display string.
  static String _toDisplayRank(String rank) {
    // Handle spelled-out numbers if model outputs them
    final spelledOutMap = {
      'one': '1',
      'two': '2',
      'three': '3',
      'four': '4',
      'five': '5',
      'six': '6',
      'seven': '7',
      'eight': '8',
      'nine': '9',
      'ten': '10',
    };

    final mapped = spelledOutMap[rank] ?? rank;

    return switch (mapped) {
      '1' => _displayAce,
      '2' => '2',
      '3' => '3',
      '4' => '4',
      '5' => '5',
      '6' => '6',
      '7' => '7',
      '8' => '8',
      '9' => '9',
      '10' => '10',
      _rankJoker => _displayJoker,
      _shortAce || _rankAce => _displayAce,
      _shortJack || _rankJack => _displayJack,
      _shortQueen || _rankQueen => _displayQueen,
      _shortKing || _rankKing => _displayKing,
      _ => _displayJoker,
    };
  }

  /// Converts a card rank label to its game score value.
  static int? labelToRankValue(String label) {
    final normalized = normalizeRankLabel(label);
    return switch (normalized) {
      _displayJoker => _rankValueJoker,
      _displayAce => _rankValueAce,
      _displayJack => _rankValueJack,
      _displayQueen => _rankValueQueen,
      _displayKing => _rankValueKing,
      _ => int.tryParse(normalized),
    };
  }
}
