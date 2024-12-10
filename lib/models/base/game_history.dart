class GameHistory {
  GameHistory();

  factory GameHistory.fromJson(Map json) {
    return GameHistory()
      ..date = json['date']
      ..playersNames = List<String>.from(json['playersNames']);
  }

  DateTime date = DateTime.now();
  List<String> playersNames = [];

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
