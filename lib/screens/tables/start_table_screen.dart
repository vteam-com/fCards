import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/card/card_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/game/golf_score_model.dart';
import 'package:cards/models/game/player_selection.dart';
import 'package:cards/models/game/score_sheet_setup.dart';
import 'package:cards/models/game/table_service.dart';
import 'package:cards/screens/tables/lobby_screen.dart';
import 'package:cards/screens/tables/who_is_playing_step.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/buttons/my_button_round.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/helpers/wizard_footer.dart';
import 'package:cards/widgets/tables/game_type_option.dart';
import 'package:cards/widgets/tables/rename_table_dialog.dart';
import 'package:flutter/material.dart';

/// Starts a game: pick the game type, then
///
/// * virtual cards: reopen a table or start a new one, then gather in a lobby;
/// * physical cards: gather the players (by QR code or typed names); their
///   table for this game is found, or created when they have none, and the
///   score sheet opens.
class StartTableScreen extends StatefulWidget {
  /// Creates the start flow for [cards].
  const StartTableScreen({super.key, required this.cards});

  /// Physical (score sheet) or virtual (dealt by the app) cards.
  final CardMedium cards;

  @override
  State<StartTableScreen> createState() => _StartTableScreenState();
}

class _StartTableScreenState extends State<StartTableScreen> {
  bool _busy = false;
  GameStyles _gameType = GameStyles.frenchCards9;
  bool _hasSheetInProgress = false;
  String _newTableName = '';
  bool _onSecondStep = false;
  PlayerSelection _selection = const PlayerSelection(players: <String>[]);
  List<GameTable>? _tables;
  @override
  void initState() {
    super.initState();
    if (_isPhysical) {
      GolfScoreModel.load().then((GolfScoreModel sheet) {
        if (mounted) {
          setState(() => _hasSheetInProgress = sheet.canClose);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Screen(
      isWaiting: _busy,
      title: _isPhysical
          ? localizations.startScoreSheet
          : localizations.startTable,
      child: Padding(
        padding: const EdgeInsets.all(ConstLayout.paddingM),
        child: Column(
          children: [
            Expanded(
              child: _onSecondStep && _isPhysical
                  ? SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: ConstLayout.mainMenuMaxWidth,
                          ),
                          child: WhoIsPlayingStep(
                            gameType: _gameType,
                            onChanged: (PlayerSelection selection) =>
                                setState(() => _selection = selection),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: ConstLayout.mainMenuMaxWidth,
                          ),
                          child: _onSecondStep
                              ? _buildTableStep(localizations)
                              : _buildGameTypeStep(localizations),
                        ),
                      ),
                    ),
            ),
            WizardFooter(
              backLabel: localizations.back,
              onBack: _onSecondStep
                  ? () => setState(() => _onSecondStep = false)
                  : () => Navigator.pop(context),
              primaryLabel: _onSecondStep && _isPhysical
                  ? localizations.startScoreSheet
                  : localizations.next,
              isPrimaryEnabled:
                  !_onSecondStep || (_isPhysical && _playersReady),
              onForward: !_onSecondStep
                  ? (_isPhysical ? _showPlayers : _showTables)
                  : _isPhysical && _playersReady
                  ? _openSheet
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds step 1: the game type.
  Widget _buildGameTypeStep(AppLocalizations localizations) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      spacing: ConstLayout.sizeM,
      children: [
        _buildStepLabel(localizations.wizardStepOneOfTwo),
        Text(
          localizations.whatTypeOfGame,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ConstLayout.textL,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        if (_hasSheetInProgress)
          MyButtonRectangle.menu(
            key: const Key('startTable.continueSheet'),
            icon: Icons.play_arrow,
            label: localizations.continueSheet,
            onTap: () => Navigator.pushReplacementNamed(context, '/score'),
          ),
        for (final GameStyles gameType in GameStyles.values)
          GameTypeOption(
            gameType: gameType,
            selected: _gameType == gameType,
            onTap: () => setState(() => _gameType = gameType),
          ),
      ],
    );
  }

  /// Builds the small "Step n of 2" caption.
  Widget _buildStepLabel(String label) => Text(
    label,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: ConstLayout.textS,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.tertiary,
    ),
  );

  /// Builds virtual-card step 2: a new table, or one of the player's tables
  /// of this game type.
  Widget _buildTableStep(AppLocalizations localizations) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<GameTable>? tables = _tables;
    return Column(
      spacing: ConstLayout.sizeM,
      children: [
        _buildStepLabel(localizations.wizardStepTwoOfTwo),
        Text(
          localizations.chooseTableTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ConstLayout.textL,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          localizations.chooseTableHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ConstLayout.textS,
            color: colorScheme.onSurface,
          ),
        ),
        Row(
          spacing: ConstLayout.sizeS,
          children: [
            Expanded(
              child: MyButtonRectangle.menu(
                key: const Key('startTable.newTable'),
                icon: Icons.add_circle_outline,
                label: localizations.newTable,
                subLabel: _newTableName,
                onTap: () => _open(null),
              ),
            ),
            MyButtonRound(
              key: const Key('startTable.renameNewTable'),
              onTap: _renameNewTable,
              child: const Icon(Icons.edit, size: ConstLayout.iconS),
            ),
          ],
        ),
        if (tables == null)
          const CircularProgressIndicator()
        else if (tables.isEmpty)
          Text(
            localizations.noTablesYet,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ConstLayout.textS,
              color: colorScheme.onSurface.withAlpha(ConstLayout.alphaL),
            ),
          )
        else
          for (final GameTable table in tables)
            MyButtonRectangle.menu(
              key: Key('startTable.table.${table.id}'),
              icon: Icons.table_restaurant,
              label: table.name,
              subLabel: table.players.join(', '),
              onTap: () => _open(table),
            ),
      ],
    );
  }

  bool get _isPhysical => widget.cards == CardMedium.physical;

  /// Opens a lobby for [table], or for a new table when null.
  Future<void> _open(GameTable? table) async {
    setState(() => _busy = true);
    final GameLobby lobby = await TableService.openLobby(
      gameType: _gameType,
      cards: CardMedium.virtual,
      table: table,
      name: _newTableName,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/lobby', arguments: lobby.id),
        builder: (BuildContext _) => LobbyScreen(lobbyId: lobby.id),
      ),
    );
  }

  /// Finds this group's table for the game (creating it when new), names the
  /// shared sheet after it, and opens the score sheet.
  Future<void> _openSheet() async {
    final PlayerSelection selection = _selection;
    setState(() => _busy = true);
    final GameTable table = await TableService.resolveTable(
      gameType: _gameType,
      players: selection.players,
      proposedName: selection.lobby?.name ?? '',
    );
    final GameLobby? lobby = selection.lobby;
    if (lobby != null) {
      await TableService.attachLobby(lobby, table);
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/score',
      arguments: ScoreSheetSetup(
        gameType: _gameType,
        tableName: table.name,
        players: selection.players,
        sessionId: lobby?.id,
      ),
    );
  }

  bool get _playersReady =>
      _selection.players.length >= CardModel.minPlayersToStartGame;

  /// Lets the player change the proposed name of the new table.
  Future<void> _renameNewTable() async {
    final String? name = await renameTableWithFeedback(
      context: context,
      currentName: _newTableName,
      rename: TableService.checkNewName,
    );
    if (name != null && mounted) {
      setState(() => _newTableName = GameTable.normalizeName(name));
    }
  }

  /// Moves to the physical-card players step.
  void _showPlayers() => setState(() {
    _onSecondStep = true;
    _selection = const PlayerSelection(players: <String>[]);
  });

  /// Moves to step 2 and loads a proposed name and the player's tables.
  Future<void> _showTables() async {
    setState(() {
      _onSecondStep = true;
      _tables = null;
    });
    final String name = await TableService.proposeName();
    final List<GameTable> tables = await TableService.tablesForPlayer(
      AuthService.currentUser?.uid ?? '',
      gameType: _gameType,
    );
    if (mounted) {
      setState(() {
        _newTableName = name;
        _tables = tables;
      });
    }
  }
}
