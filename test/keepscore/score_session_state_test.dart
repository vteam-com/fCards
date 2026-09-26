import 'package:cards/models/game/score_session_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips shared score state through Firebase values', () {
    const ScoreSessionState state = ScoreSessionState(
      playerIds: ['host', 'guest'],
      playerNames: ['JP', 'AB'],
      scores: [
        [12, 7],
        [3, 9],
      ],
    );

    final ScoreSessionState parsed = ScoreSessionState.fromValue(
      state.toValue(),
    );

    expect(parsed.playerIds, state.playerIds);
    expect(parsed.playerNames, state.playerNames);
    expect(parsed.scores, state.scores);
  });

  test('parses numeric Firebase values as integer scores', () {
    final ScoreSessionState parsed = ScoreSessionState.fromValue({
      'player_ids': ['host'],
      'player_names': ['JP'],
      'scores': [
        [12.0],
      ],
    });

    expect(parsed.scores, [
      [12],
    ]);
  });
}
