const String _scoreInviteHost = 'cards.vteam.com';
const String _scoreInviteParameter = 'scoreSession';

/// A QR-invite Score Keeper table.
class ScoreSession {
  /// Creates a score session with its stable ID and generated table name.
  const ScoreSession({required this.id, required this.tableName});

  /// Stable identifier embedded in the QR invitation.
  final String id;

  /// Default table name displayed while participants join.
  final String tableName;

  /// HTTPS URL encoded in the QR code.
  String get inviteUrl =>
      Uri.https(_scoreInviteHost, '/', {_scoreInviteParameter: id}).toString();
}
