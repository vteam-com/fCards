import 'package:cards/models/game/game_lobby.dart';

/// Who is about to play a physical-card game, and the shared sheet they
/// joined by QR code, if any.
class PlayerSelection {
  /// Creates a selection.
  const PlayerSelection({required this.players, this.lobby});

  /// Player names in column order.
  final List<String> players;

  /// Lobby whose shared sheet the players joined; null for a local sheet.
  final GameLobby? lobby;
}
