import 'dart:async';

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/identity_service.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_history.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/game/leaderboard_service.dart';
import 'package:cards/models/game/table_service.dart';
import 'package:cards/models/version.dart';
import 'package:cards/screens/game/game_screen.dart';
import 'package:cards/screens/game/start_screen_game_instructions.dart';
import 'package:cards/utils/browser_utils.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/buttons/my_button_round.dart';
import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/player/players_in_room_widget.dart';
import 'package:cards/widgets/tables/rename_table_dialog.dart';
import 'package:cards/widgets/tables/table_summary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Query parameter carrying a lobby id in shared web links.
const String lobbyLinkParameter = 'lobby';

/// Where a virtual-card group gathers before the game starts.
///
/// Shows the table name (editable), the game, and who has joined. As players
/// come and go it shows which table this exact group plays at; *Start Game*
/// resolves that table, creating it with the lobby's name for a new group.
class LobbyScreen extends StatefulWidget {
  /// Creates the lobby for [lobbyId].
  const LobbyScreen({super.key, required this.lobbyId});

  /// Id of the lobby and its live room.
  final String lobbyId;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  GameTable? _groupTable;
  bool _instructionsExpanded = false;
  bool _loading = true;
  GameLobby? _lobby;
  StreamSubscription<GameLobby?>? _lobbySubscription;
  String _me = '';
  final TextEditingController _nameController = TextEditingController();
  Set<String> _players = <String>{};
  StreamSubscription<dynamic>? _playersSubscription;
  bool _starting = false;
  @override
  void initState() {
    super.initState();
    _join();
  }

  @override
  void dispose() {
    _lobbySubscription?.cancel();
    _playersSubscription?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final GameLobby? lobby = _lobby;
    return Screen(
      isWaiting: _loading || _starting,
      title: localizations.startTable,
      getLinkToShare: kIsWeb
          ? () => '${getWindowOrigin()}?$lobbyLinkParameter=${widget.lobbyId}'
          : null,
      child: lobby == null
          ? Center(child: Text(localizations.tableNotFound))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(ConstLayout.paddingM),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: ConstLayout.startGameScreenMaxWidth,
                  ),
                  child: Column(
                    spacing: ConstLayout.sizeM,
                    children: [
                      _buildHeader(lobby, localizations),
                      StartScreenGameInstructions(
                        gameStyle: lobby.gameType,
                        isExpanded: _instructionsExpanded,
                        onExpansionChanged: (bool expanded) =>
                            setState(() => _instructionsExpanded = expanded),
                      ),
                      PlayersInRoomWidget(
                        activePlayerName: _me,
                        playerNames: _players.toList(),
                        onPlayerSelected: (String _) {},
                        onRemovePlayer: _removePlayer,
                      ),
                      Text(
                        localizations.lobbyAddPlayer,
                        style: const TextStyle(fontSize: ConstLayout.textS),
                      ),
                      EditBox(
                        prefixIcon: const Icon(Icons.person_add),
                        controller: _nameController,
                        onSubmitted: _addPlayers,
                        errorStatus: '',
                        rightSideChild: IconButton(
                          onPressed: _addPlayers,
                          icon: const Icon(Icons.add),
                        ),
                      ),
                      _buildStartButton(localizations),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Adds the comma-separated names typed in the field.
  void _addPlayers() {
    final List<String> names = _nameController.text
        .toUpperCase()
        .split(',')
        .map((String name) => name.trim())
        .where((String name) => name.isNotEmpty)
        .toList();
    if (names.isEmpty) return;
    setState(() {
      _players.addAll(names);
      _nameController.clear();
    });
    setPlayersInRoom(widget.lobbyId, _players);
    _findGroupTable();
  }

  /// Table name with its rename button, the game, and the group's table.
  Widget _buildHeader(GameLobby lobby, AppLocalizations localizations) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final GameTable? table = _groupTable;
    return Column(
      spacing: ConstLayout.sizeXS,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: ConstLayout.sizeS,
          children: [
            Flexible(
              child: Text(
                table?.name ?? lobby.name,
                key: const Key('lobby.tableName'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ConstLayout.textL,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            MyButtonRound(
              key: const Key('lobby.rename'),
              onTap: _rename,
              child: const Icon(Icons.edit, size: ConstLayout.iconS),
            ),
          ],
        ),
        Text(
          gameTypeLabel(lobby.gameType, localizations),
          style: TextStyle(
            fontSize: ConstLayout.textM,
            color: colorScheme.tertiary,
          ),
        ),
        Text(
          table != null
              ? localizations.tableForThisGroup
              : localizations.newTableForThisGroup,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ConstLayout.textS,
            color: colorScheme.onSurface.withAlpha(ConstLayout.alphaL),
          ),
        ),
      ],
    );
  }

  /// Start Game, enabled once enough players have joined.
  Widget _buildStartButton(AppLocalizations localizations) {
    final bool ready = _players.length >= CardModel.minPlayersToStartGame;
    return Column(
      spacing: ConstLayout.sizeS,
      children: [
        Text(
          ready
              ? localizations.readyToPlayPlayersAtTable(_players.length)
              : localizations.waitingForMorePlayers,
          style: const TextStyle(fontSize: ConstLayout.textS),
        ),
        MyButtonRectangle.primary(
          key: const Key('lobby.startGame'),
          width: double.infinity,
          height: ConstLayout.dialogButtonHeight,
          onTap: ready && !_starting ? _startGame : null,
          child: Text(
            localizations.startGame,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// Looks up the table where exactly the current players play this game.
  Future<void> _findGroupTable() async {
    final GameLobby? lobby = _lobby;
    if (lobby == null) return;
    final Set<String> players = Set<String>.of(_players);
    final GameTable? table = await TableService.findTable(
      lobby.gameType,
      players,
    );
    if (mounted && players.length == _players.length) {
      setState(() => _groupTable = table);
    }
  }

  /// Loads the lobby, adds this player, and follows everyone who joins.
  Future<void> _join() async {
    final GameLobby? lobby = await TableService.getLobby(widget.lobbyId);
    final String me = (await IdentityService.resolveIdentityName() ?? '')
        .trim()
        .toUpperCase();
    if (!mounted) return;
    if (lobby == null) {
      setState(() => _loading = false);
      return;
    }
    final List<String> players = await getPlayersInRoom(widget.lobbyId);
    if (!mounted) return;
    setState(() {
      _lobby = lobby;
      _me = me;
      _players = <String>{...players, if (me.isNotEmpty) me};
      _loading = false;
    });
    setPlayersInRoom(widget.lobbyId, _players);
    _lobbySubscription = TableService.watchLobby(widget.lobbyId).listen((
      GameLobby? updated,
    ) {
      if (updated != null && mounted) {
        setState(() => _lobby = updated);
      }
    });
    if (!isRunningOffLine) {
      _playersSubscription = onBackendInviteesUpdated(widget.lobbyId, (
        List<String> invitees,
      ) {
        if (mounted) {
          setState(() => _players = invitees.toSet());
          _findGroupTable();
        }
      });
    }
    await _findGroupTable();
  }

  void _removePlayer(String name) {
    setState(() => _players.remove(name));
    setPlayersInRoom(widget.lobbyId, _players);
    _findGroupTable();
  }

  /// Renames the group's table when it exists, otherwise the proposed name.
  Future<void> _rename() async {
    final GameLobby? lobby = _lobby;
    if (lobby == null) return;
    final GameTable? table = _groupTable;
    await renameTableWithFeedback(
      context: context,
      currentName: table?.name ?? lobby.name,
      rename: (String name) => table != null
          ? TableService.renameTable(table.id, name)
          : TableService.renameLobby(lobby, name),
    );
    await _findGroupTable();
  }

  /// Resolves the group's table and starts the virtual-card game.
  Future<void> _startGame() async {
    final GameLobby? lobby = _lobby;
    if (lobby == null) return;
    setState(() => _starting = true);
    final GameTable table = await TableService.resolveTable(
      gameType: lobby.gameType,
      players: _players,
      proposedName: lobby.name,
    );
    final List<GameHistory> history = await LeaderboardService.roomWinHistory(
      table.id,
    );
    final GameStyleConfig config = getGameStyleConfig(
      lobby.gameType,
      _players.length,
    );
    if (!mounted) return;
    final GameModel gameModel = GameModel(
      version: packageVersion,
      gameStyle: lobby.gameType,
      roomName: lobby.id,
      tableId: table.id,
      tableName: table.name,
      roomHistory: history,
      loginUserName: _me,
      names: _players.toList(),
      cardsToDeal: config.cardsToDeal,
      deck: DeckModel(numberOfDecks: config.decks, gameStyle: lobby.gameType),
      isNewGame: true,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext _) => GameScreen(gameModel: gameModel),
      ),
    );
  }
}
