/// Represents the history of a game, including the date and the names of the players.
class GameHistory {
  /// Constructs a new instance of the [GameHistory] class.
  GameHistory();

  /// Constructs a new instance of the [GameHistory] class from a JSON map.
  ///
  /// The JSON map should have the following keys:
  /// - `date`: a DateTime object representing the date of the game
  /// - `playersNames`: a list of strings representing the names of the players
  ///
  /// This factory method creates a new [GameHistory] instance and initializes its
  /// `date` and `playersNames` properties from the provided JSON map.
  factory GameHistory.fromJson(Map json) {
    return GameHistory()
      ..date = json['date']
      ..playersNames = List<String>.from(json['playersNames']);
  }

  /// The current date and time when this [GameHistory] instance was created.
  DateTime date = DateTime.now();

  /// The names of the players involved in the game.
  List<String> playersNames = [];

  /// Converts the [GameHistory] instance to a JSON map.
  ///
  /// The resulting map will have the following keys:
  /// - `date`: a DateTime object representing the date of the game
  /// - `playersNames`: a list of strings representing the names of the players
  ///
  /// This method is useful for serializing a [GameHistory] instance to a JSON format.
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'playersNames': playersNames,
    };
  }

  @override
  String toString() {
    return '${date.toIso8601String()} ${playersNames.join(',')}';
  }
}
