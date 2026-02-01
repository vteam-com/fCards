import 'package:cards/models/player/player_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerStatus', () {
    test('fromJson creates PlayerStatus with valid data', () {
      final json = {'emoji': '😊', 'phrase': 'Hello World'};

      final result = PlayerStatus.fromJson(json);

      expect(result.emoji, '😊');
      expect(result.phrase, 'Hello World');
    });

    test(
      'fromJson creates PlayerStatus with empty strings when json is null',
      () {
        final result = PlayerStatus.fromJson(null);

        expect(result.emoji, '');
        expect(result.phrase, '');
      },
    );

    test(
      'fromJson creates PlayerStatus with empty strings when fields are missing',
      () {
        final json = <String, dynamic>{};

        final result = PlayerStatus.fromJson(json);

        expect(result.emoji, '');
        expect(result.phrase, '');
      },
    );

    test(
      'fromJson creates PlayerStatus with empty strings when fields are null',
      () {
        final json = {'emoji': null, 'phrase': null};

        final result = PlayerStatus.fromJson(json);

        expect(result.emoji, '');
        expect(result.phrase, '');
      },
    );

    test('findMatchingPlayerStatusInstance', () {
      final PlayerStatus result1 = findMatchingPlayerStatusInstance(
        'X',
        'NOT REAL',
      );
      // expecting to not find anything
      expect(result1.emoji, '');
      expect(result1.phrase, '');

      final PlayerStatus result = findMatchingPlayerStatusInstance(
        '😙',
        'Voila!',
      );
      expect(result.emoji, '😙');
      expect(result.phrase, 'Voila!');
    });
  });
}
