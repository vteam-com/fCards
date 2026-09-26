/// A score-session participant with a score label and account metadata.
class ScoreSessionParticipant {
  /// Creates participant metadata read from a score session.
  const ScoreSessionParticipant({
    required this.avatarUrl,
    required this.displayName,
    required this.email,
    required this.firebaseId,
    required this.fullName,
    required this.oAuthType,
  });

  /// Account profile image URL, when shared by the provider.
  final String avatarUrl;

  /// Name shown on the score card.
  final String displayName;

  /// Authenticated email, when shared by the provider.
  final String email;

  /// Stable Firebase account identifier.
  final String firebaseId;

  /// Account display name, when shared by the provider.
  final String fullName;

  /// Provider type used to authenticate the account.
  final String oAuthType;

  /// Preferred title for a participant sheet.
  String get title => fullName.isNotEmpty
      ? fullName
      : email.isNotEmpty
      ? email
      : displayName;
}
