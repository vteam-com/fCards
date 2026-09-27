import 'package:cards/models/game/score_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScoreSessionService.sessionIdFromTableName', () {
    test('strips the SCORE- prefix and lowercases the id', () {
      expect(
        ScoreSessionService.sessionIdFromTableName('SCORE-ABC123'),
        'abc123',
      );
    });

    test('accepts a bare id typed without the prefix', () {
      expect(ScoreSessionService.sessionIdFromTableName(' abc123 '), 'abc123');
    });

    test('accepts a lowercase prefix', () {
      expect(ScoreSessionService.sessionIdFromTableName('score-xyz'), 'xyz');
    });

    test('returns null when nothing usable is left', () {
      expect(ScoreSessionService.sessionIdFromTableName('   '), isNull);
      expect(ScoreSessionService.sessionIdFromTableName('SCORE-'), isNull);
    });
  });
}
