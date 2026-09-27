import 'package:cards/models/game/card_medium.dart';
import 'package:cards/models/game/game_styles.dart';

const String _nameNode = 'name';
const String _gameTypeNode = 'game_type';
const String _cardsNode = 'cards';
const String _tableIdNode = 'table_id';
const String _createdAtNode = 'created_at';

/// A group getting ready to play, before its table is known.
///
/// Virtual-card lobbies live at `rooms/{id}`, shared physical-card sheets at
/// `score_sessions/{id}`. The table is resolved from the final players when
/// the game starts (virtual) or closes (physical); a new group's table takes
/// the lobby [name].
class GameLobby {
  /// Creates a lobby.
  const GameLobby({
    required this.id,
    required this.name,
    required this.gameType,
    required this.cards,
    required this.createdAt,
    this.tableId,
  });

  /// Parses a lobby stored at `lobbies/{id}`, or null when absent.
  static GameLobby? fromValue(String id, Object? value) {
    if (value is! Map) {
      return null;
    }
    final Object? name = value[_nameNode];
    final GameStyles? gameType = GameStyles.values
        .asNameMap()[value[_gameTypeNode]];
    final CardMedium? cards = CardMedium.values.asNameMap()[value[_cardsNode]];
    final Object? tableId = value[_tableIdNode];
    final Object? createdAt = value[_createdAtNode];
    if (name is! String || gameType == null || cards == null) {
      return null;
    }
    return GameLobby(
      id: id,
      name: name,
      gameType: gameType,
      cards: cards,
      tableId: tableId is String && tableId.isNotEmpty ? tableId : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        createdAt is num ? createdAt.toInt() : 0,
      ),
    );
  }

  /// Lobby id, shared with its live room or score session.
  final String id;

  /// Name shown while gathering: the reopened table's name, or the proposed
  /// name of a new table.
  final String name;

  /// Game type chosen for this lobby.
  final GameStyles gameType;

  /// Physical or virtual cards.
  final CardMedium cards;

  /// Table this lobby reopened, if any.
  final String? tableId;

  /// When the lobby was opened.
  final DateTime createdAt;

  /// Returns a copy with a new [name].
  GameLobby renamed(String name) => GameLobby(
    id: id,
    name: name,
    gameType: gameType,
    cards: cards,
    tableId: tableId,
    createdAt: createdAt,
  );

  /// Serializes the lobby for Firebase.
  Map<String, Object> toValue() => <String, Object>{
    _nameNode: name,
    _gameTypeNode: gameType.name,
    _cardsNode: cards.name,
    _tableIdNode: ?tableId,
    _createdAtNode: createdAt.millisecondsSinceEpoch,
  };
}
