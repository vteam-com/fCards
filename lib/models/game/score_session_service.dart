import 'dart:math';

import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/score_session.dart';
import 'package:cards/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

const String _scoreSessionsNode = 'score_sessions';
const String _participantsNode = 'participants';
const String _tableNameNode = 'table_name';
const String _defaultParticipantName = 'HOST';
const String _scoreInviteParameter = 'scoreSession';
const int _sessionIdRadix = 36;

/// Coordinates authenticated Score Keeper QR sessions through Firebase.
class ScoreSessionService {
  /// Creates a fresh table with a generated default name and its host.
  static Future<ScoreSession?> createSession(String participantName) async {
    await useFirebase();
    final String? uid = AuthService.currentUser?.uid;
    if (!backendReady || uid == null) {
      return null;
    }

    final String id = _newSessionId();
    final ScoreSession session = ScoreSession(
      id: id,
      tableName: 'SCORE-${id.toUpperCase()}',
    );
    try {
      await FirebaseDatabase.instance.ref('$_scoreSessionsNode/$id').set({
        _tableNameNode: session.tableName,
        _participantsNode: {uid: _participantName(participantName)},
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
          .set(_participantName(participantName));
    } on FirebaseException catch (error) {
      logger.w('joinScoreSession failed: $error');
    } catch (error) {
      logger.w('joinScoreSession failed: $error');
    }
  }

  /// Streams the current table participants in their backend order.
  static Stream<List<String>> participants(String sessionId) {
    return FirebaseDatabase.instance
        .ref('$_scoreSessionsNode/$sessionId/$_participantsNode')
        .onValue
        .map((DatabaseEvent event) {
          final Object? value = event.snapshot.value;
          if (value is! Map) {
            return <String>[];
          }
          return value.values.whereType<String>().toList();
        });
  }

  /// Extracts a score-session ID from a web invitation URL.
  static String? sessionIdFromUri(Uri uri) =>
      uri.queryParameters[_scoreInviteParameter];

  static String _newSessionId() {
    final String time = DateTime.now().microsecondsSinceEpoch.toRadixString(
      _sessionIdRadix,
    );
    final String random = Random.secure()
        .nextInt(_sessionIdRadix)
        .toRadixString(_sessionIdRadix);
    return '$time$random';
  }

  static String _participantName(String participantName) {
    final String normalized = participantName.trim().toUpperCase();
    return normalized.isEmpty ? _defaultParticipantName : normalized;
  }
}
