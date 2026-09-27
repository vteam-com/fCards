import 'dart:math';

const List<String> _adjectives = <String>[
  'AMBER',
  'BLUE',
  'BOLD',
  'BRAVE',
  'BRIGHT',
  'CALM',
  'CLEVER',
  'COSY',
  'CRIMSON',
  'DANCING',
  'EAGER',
  'FANCY',
  'GOLDEN',
  'GRAND',
  'GREEN',
  'HAPPY',
  'JOLLY',
  'LUCKY',
  'MERRY',
  'MIGHTY',
  'NOBLE',
  'PLUCKY',
  'PROUD',
  'QUICK',
  'QUIET',
  'ROYAL',
  'RUSTY',
  'SILVER',
  'SLY',
  'SUNNY',
  'SWIFT',
  'VELVET',
  'WILD',
  'WISE',
];

const List<String> _nouns = <String>[
  'ACE',
  'BADGER',
  'BEAR',
  'CASTLE',
  'CEDAR',
  'CLOVER',
  'COMET',
  'CROWN',
  'DRAGON',
  'EAGLE',
  'FALCON',
  'FOX',
  'HARBOR',
  'HAWK',
  'JACK',
  'JOKER',
  'KING',
  'KNIGHT',
  'LANTERN',
  'LION',
  'MAPLE',
  'MEADOW',
  'OTTER',
  'OWL',
  'PANDA',
  'PEBBLE',
  'QUEEN',
  'RAVEN',
  'ROCKET',
  'TIGER',
  'TULIP',
  'VALLEY',
  'WALRUS',
  'WOLF',
];

/// Generates friendly two-word table names such as `LUCKY OTTER`.
class TableNames {
  /// Returns a random two-word name.
  static String generate([Random? random]) {
    final Random source = random ?? Random();
    return '${_adjectives[source.nextInt(_adjectives.length)]} '
        '${_nouns[source.nextInt(_nouns.length)]}';
  }
}
