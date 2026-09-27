import 'dart:math';

import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/score_session.dart';
import 'package:cards/models/game/score_session_closure.dart';
import 'package:cards/models/game/score_session_participant.dart';
import 'package:cards/models/game/score_session_state.dart';
import 'package:cards/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

const String _scoreSessionsNode = 'score_sessions';
const String _participantsNode = 'participants';
const String _tableNameNode = 'table_name';
const String _displayNameNode = 'display_name';
const String _emailNode = 'email';
const String _firebaseIdNode = 'firebase_id';
const String _fullNameNode = 'full_name';
const String _avatarUrlNode = 'avatar_url';
const String _oAuthTypeNode = 'oauth_type';
const String _scoreStateNode = 'score_state';
const String _closedGameNode = 'closed_game';
const String _defaultParticipantName = 'HOST';
const String _scoreInviteParameter = 'scoreSession';
const String _scoreTableNamePrefix = 'SCORE-';
const int _sessionIdRadix = 36;

/// Coordinates authenticated Score Keeper QR sessions through Firebase.
class ScoreSessionService {
  /// Creates a fresh table with a generated default name and its host.
  ///
  /// When [initialState] has players, the table starts from those columns
  /// instead of a single host column.
  static Future<ScoreSession?> createSession(
    String participantName, {
    ScoreSessionState? initialState,
  }) async {
    await useFirebase();
    final String? uid = AuthService.currentUser?.uid;
    if (!backendReady || uid == null) {
      return null;
    }

    final String id = _newSessionId();
    final ScoreSession session = ScoreSession(
      id: id,
      tableName: '$_scoreTableNamePrefix${id.toUpperCase()}',
    );
    final ScoreSessionState state =
        initialState != null && initialState.playerIds.isNotEmpty
        ? initialState
        : ScoreSessionState(
            playerIds: [uid],
            playerNames: [_participantName(participantName)],
            scores: const [
              [0],
            ],
          );
    try {
      await FirebaseDatabase.instance.ref('$_scoreSessionsNode/$id').set({
        _tableNameNode: session.tableName,
        _participantsNode: {uid: _participantValue(uid, participantName)},
        _scoreStateNode: state.toValue(),
      });
      return session;
    } on FirebaseException catch (error) {
      logger.w('createScoreSession failed: $error');
      return null;
    } catch (error) {
      logger.w('createScoreSession failed: $error');
      return null;
    }
  }

  /// Adds the authenticated device's participant identity to [sessionId].
  static Future<void> joinSession(
    String sessionId,
    String participantName,
  ) async {
    await useFirebase();
    final String? uid = AuthService.currentUser?.uid;
    if (!backendReady || uid == null || sessionId.isEmpty) {
      return;
    }

    try {
      await FirebaseDatabase.instance
          .ref('$_scoreSessionsNode/$sessionId/$_participantsNode/$uid')
          .set(_participantValue(uid, participantName));
      await _scoreStateReference(sessionId).runTransaction((Object? value) {
        final ScoreSessionState state = ScoreSessionState.fromValue(value);
        if (state.playerIds.contains(uid)) {
          return Transaction.success(value);
        }
        final List<String> playerIds = [...state.playerIds, uid];
        final List<String> playerNames = [
          ...state.playerNames,
          _participantName(participantName),
        ];
        final List<List<int>> existingScores = state.scores.isEmpty
            ? [List<int>.filled(state.playerIds.length, 0)]
            : state.scores;
        final List<List<int>> scores = existingScores
            .map((List<int> round) => [...round, 0])
            .toList();
        return Transaction.success(
          ScoreSessionState(
            playerIds: playerIds,
            playerNames: playerNames,
            scores: scores,
          ).toValue(),
        );
      });
    } on FirebaseException catch (error) {
      logger.w('joinScoreSession failed: $error');
    } catch (error) {
      logger.w('joinScoreSession failed: $error');
    }
  }

  /// Loads the table details for [sessionId].
  static Future<ScoreSession?> getSession(String sessionId) async {
    await useFirebase();
    if (!backendReady || sessionId.isEmpty) {
      return null;
    }

    try {
      final DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref('$_scoreSessionsNode/$sessionId')
          .get();
      final Object? value = snapshot.value;
      if (value is! Map || value[_tableNameNode] is! String) {
        return null;
      }
      return ScoreSession(
        id: sessionId,
        tableName: value[_tableNameNode] as String,
      );
    } on FirebaseException catch (error) {
      logger.w('getScoreSession failed: $error');
      return null;
    } catch (error) {
      logger.w('getScoreSession failed: $error');
      return null;
    }
  }

  /// Streams the current table participants with their account identifiers.
  static Stream<List<ScoreSessionParticipant>> participants(String sessionId) {
    return FirebaseDatabase.instance
        .ref('$_scoreSessionsNode/$sessionId/$_participantsNode')
        .onValue
        .map((DatabaseEvent event) {
          final Object? value = event.snapshot.value;
          if (value is! Map) {
            return <ScoreSessionParticipant>[];
          }
          return value.entries.map((MapEntry<dynamic, dynamic> entry) {
            final String uid = entry.key.toString();
            final Object? participant = entry.value;
            if (participant is String) {
              return ScoreSessionParticipant(
                avatarUrl: '',
                displayName: participant,
                email: '',
                firebaseId: uid,
                fullName: '',
                oAuthType: anonymousOAuthProviderType,
              );
            }
            if (participant is Map) {
              final Object? avatarUrl = participant[_avatarUrlNode];
              final Object? displayName = participant[_displayNameNode];
              final Object? email = participant[_emailNode];
              final Object? firebaseId = participant[_firebaseIdNode];
              final Object? fullName = participant[_fullNameNode];
              final Object? oAuthType = participant[_oAuthTypeNode];
              return ScoreSessionParticipant(
                avatarUrl: avatarUrl is String ? avatarUrl : '',
                displayName: displayName is String
                    ? displayName
                    : _defaultParticipantName,
                email: email is String && email.contains('@') ? email : '',
                firebaseId: firebaseId is String && firebaseId.isNotEmpty
                    ? firebaseId
                    : uid,
                fullName: fullName is String ? fullName : '',
                oAuthType: oAuthType is String
                    ? oAuthType
                    : anonymousOAuthProviderType,
              );
            }
            return ScoreSessionParticipant(
              avatarUrl: '',
              displayName: _defaultParticipantName,
              email: '',
              firebaseId: uid,
              fullName: '',
              oAuthType: anonymousOAuthProviderType,
            );
          }).toList();
        });
  }

  /// Streams the shared score card for [sessionId].
  static Stream<ScoreSessionState> scoreState(String sessionId) {
    return _scoreStateReference(sessionId).onValue.map(
      (DatabaseEvent event) =>
          ScoreSessionState.fromValue(event.snapshot.value),
    );
  }

  /// Announces to every participant that the host closed a game.
  static Future<void> publishClosure(
    String sessionId,
    ScoreSessionClosure closure,
  ) async {
    try {
      await FirebaseDatabase.instance
          .ref('$_scoreSessionsNode/$sessionId/$_closedGameNode')
          .set(closure.toValue());
    } on FirebaseException catch (error) {
      logger.w('publishClosure failed: $error');
    } catch (error) {
      logger.w('publishClosure failed: $error');
    }
  }

  /// Streams the latest closed game of [sessionId], or null before the first.
  static Stream<ScoreSessionClosure?> closures(String sessionId) {
    return FirebaseDatabase.instance
        .ref('$_scoreSessionsNode/$sessionId/$_closedGameNode')
        .onValue
        .map(
          (DatabaseEvent event) =>
              ScoreSessionClosure.fromValue(event.snapshot.value),
        );
  }

  /// Updates one score cell without replacing unrelated concurrent edits.
  static Future<void> updateScore(
    String sessionId,
    int roundIndex,
    int playerIndex,
    int score,
  ) => _updateState(sessionId, (ScoreSessionState state) {
    if (roundIndex >= state.scores.length ||
        playerIndex >= state.playerIds.length) {
      return state;
    }
    final List<List<int>> scores = state.scores
        .map((List<int> round) => [...round])
        .toList();
    scores[roundIndex][playerIndex] = score;
    return ScoreSessionState(
      playerIds: state.playerIds,
      playerNames: state.playerNames,
      scores: scores,
    );
  });

  /// Appends an empty score round using the latest shared player count.
  static Future<void> addRound(String sessionId) => _updateState(
    sessionId,
    (ScoreSessionState state) => ScoreSessionState(
      playerIds: state.playerIds,
      playerNames: state.playerNames,
      scores: [...state.scores, List<int>.filled(state.playerIds.length, 0)],
    ),
  );

  /// Removes a score round while retaining at least one round.
  static Future<void> removeRound(String sessionId, int roundIndex) =>
      _updateState(sessionId, (ScoreSessionState state) {
        if (state.scores.length <= 1 || roundIndex >= state.scores.length) {
          return state;
        }
        return ScoreSessionState(
          playerIds: state.playerIds,
          playerNames: state.playerNames,
          scores: [...state.scores]..removeAt(roundIndex),
        );
      });

  /// Resets every shared score while preserving players.
  static Future<void> clearScores(String sessionId) => _updateState(
    sessionId,
    (ScoreSessionState state) => ScoreSessionState(
      playerIds: state.playerIds,
      playerNames: state.playerNames,
      scores: [List<int>.filled(state.playerIds.length, 0)],
    ),
  );

  /// Removes one player column from the shared table.
  static Future<void> removePlayer(String sessionId, int playerIndex) =>
      _updateState(sessionId, (ScoreSessionState state) {
        if (playerIndex >= state.playerIds.length) {
          return state;
        }
        return ScoreSessionState(
          playerIds: [...state.playerIds]..removeAt(playerIndex),
          playerNames: [...state.playerNames]..removeAt(playerIndex),
          scores: state.scores.map((List<int> round) {
            return [...round]..removeAt(playerIndex);
          }).toList(),
        );
      });

  /// Renames a player column by ID so concurrent reorders keep the right name.
  static Future<void> renamePlayer(
    String sessionId,
    String playerId,
    String playerName,
  ) => _updateState(sessionId, (ScoreSessionState state) {
    final int playerIndex = state.playerIds.indexOf(playerId);
    if (playerIndex < 0 || playerIndex >= state.playerNames.length) {
      return state;
    }
    return ScoreSessionState(
      playerIds: state.playerIds,
      playerNames: [...state.playerNames]..[playerIndex] = playerName,
      scores: state.scores,
    );
  });

  /// Moves a player column by ID so a concurrent edit cannot move another player.
  static Future<void> movePlayer(
    String sessionId,
    String playerId,
    String targetPlayerId,
  ) => _updateState(
    sessionId,
    (ScoreSessionState state) => state.movePlayer(playerId, targetPlayerId),
  );

  /// Replaces the player columns with an explicitly applied edit snapshot.
  static Future<void> replacePlayersAndScores(
    String sessionId, {
    required List<String> playerIds,
    required List<String> playerNames,
    required List<List<int>> scores,
  }) => _updateState(
    sessionId,
    (_) => ScoreSessionState(
      playerIds: List<String>.from(playerIds),
      playerNames: List<String>.from(playerNames),
      scores: scores.map((List<int> round) => List<int>.from(round)).toList(),
    ),
  );

  /// Extracts a score-session ID from a web invitation URL.
  static String? sessionIdFromUri(Uri uri) =>
      uri.queryParameters[_scoreInviteParameter];

  /// Converts a typed table name such as `SCORE-ABC123` into a session ID.
  ///
  /// The `SCORE-` prefix is optional; returns null when nothing usable is left.
  static String? sessionIdFromTableName(String tableName) {
    final String normalized = tableName.trim().toUpperCase();
    final String id = normalized.startsWith(_scoreTableNamePrefix)
        ? normalized.substring(_scoreTableNamePrefix.length)
        : normalized;
    return id.isEmpty ? null : id.toLowerCase();
  }

  static String _newSessionId() {
    final String time = DateTime.now().microsecondsSinceEpoch.toRadixString(
      _sessionIdRadix,
    );
    final String random = Random.secure()
        .nextInt(_sessionIdRadix)
        .toRadixString(_sessionIdRadix);
    return '$time$random';
  }

  static DatabaseReference _scoreStateReference(String sessionId) =>
      FirebaseDatabase.instance.ref(
        '$_scoreSessionsNode/$sessionId/$_scoreStateNode',
      );

  /// Applies [update] transactionally to the latest shared score state.
  static Future<void> _updateState(
    String sessionId,
    ScoreSessionState Function(ScoreSessionState) update,
  ) async {
    try {
      await _scoreStateReference(sessionId).runTransaction((Object? value) {
        final ScoreSessionState next = update(
          ScoreSessionState.fromValue(value),
        );
        return Transaction.success(next.toValue());
      });
    } on FirebaseException catch (error) {
      logger.w('updateScoreSessionState failed: $error');
    } catch (error) {
      logger.w('updateScoreSessionState failed: $error');
    }
  }

  static String _participantName(String participantName) {
    final String normalized = participantName.trim().toUpperCase();
    return normalized.isEmpty ? _defaultParticipantName : normalized;
  }

  /// Serializes the active account metadata for a score-session participant.
  static Map<String, String> _participantValue(
    String uid,
    String participantName,
  ) {
    final String? email = AuthService.currentUser?.email;
    final String? fullName = AuthService.currentUser?.displayName;
    final String? avatarUrl = AuthService.currentUser?.photoURL;
    return {
      _avatarUrlNode: avatarUrl ?? '',
      _displayNameNode: _participantName(participantName),
      _emailNode: email ?? '',
      _firebaseIdNode: uid,
      _fullNameNode: fullName ?? '',
      _oAuthTypeNode: _activeOAuthType(),
    };
  }

  /// Returns the active user's primary OAuth provider label.
  static String _activeOAuthType() => AuthService.currentOAuthProviderType;
}
