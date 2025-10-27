import 'package:cards/models/game_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameHistory', () {
    test('creates instance with default values', () {
      final history = GameHistory();
      expect(history.playersNames, isEmpty);
      expect(history.date, isNotNull);
    });

    test('creates instance from JSON', () {
      final testDate = DateTime.now();
      final testNames = ['Player1', 'Player2', 'Player3'];
      final json = {'date': testDate, 'playersNames': testNames};

      final history = GameHistory.fromJson(json);

      expect(history.date, equals(testDate));
      expect(history.playersNames, equals(testNames));
    });

    test('converts to JSON correctly', () {
      final history = GameHistory()
        ..date = DateTime(2023, 1, 1)
        ..playersNames = ['Alice', 'Bob'];

      final json = history.toJson();

      expect(json['date'], equals(DateTime(2023, 1, 1)));
      expect(json['playersNames'], equals(['Alice', 'Bob']));
    });

    test('converts to string correctly', () {
      final history = GameHistory()
        ..date = DateTime(2023, 1, 1)
        ..playersNames = ['Alice', 'Bob'];

      expect(history.toString(), equals('2023-01-01T00:00:00.000 Alice,Bob'));
    });
  });
}
