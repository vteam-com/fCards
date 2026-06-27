import 'dart:async';

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/auth_service.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/identity_service.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_constants.dart';
import 'package:cards/models/game/game_history.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/version.dart';
import 'package:cards/screens/game/game_screen.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/helpers/table_widget.dart';
import 'package:cards/widgets/helpers/wizard_footer.dart';
import 'package:cards/widgets/player/players_in_room_widget.dart';
import 'package:flutter/material.dart';

const int _stepTablePick = 0;
const int _stepGameType = 1;
const int _stepWaiting = 2;

const double _miniCardWidth = ConstLayout.sizeM;
const double _miniCardHeight = ConstLayout.sizeL;
const double _miniCardSpacing = ConstLayout.sizeXS;

const List<_GameTypeOption> _gameTypeOptions = <_GameTypeOption>[
  _GameTypeOption(
    style: GameStyles.frenchCards9,
    labelKey: 'golf9CardsFull',
    columns: CardModel.standardColumns,
    rows: CardModel.standardRows,
  ),
  _GameTypeOption(
    style: GameStyles.miniPut,
    labelKey: 'miniPutFull',
    columns: CardModel.miniPutColumns,
    rows: CardModel.miniPutRows,
  ),
  _GameTypeOption(
    style: GameStyles.skyjo,
    labelKey: 'Skyjo',
    columns: CardModel.skyjoColumns,
    rows: CardModel.skyjoRows,
  ),
];

class _GameTypeOption {
  const _GameTypeOption({
    required this.columns,
    required this.labelKey,
    required this.rows,
    required this.style,
  });

  final int columns;
  final String labelKey;
  final int rows;
  final GameStyles style;
}

/// Step-by-step screen for joining or starting a game.
///
/// When [canCreateTable] is true (the Start flow), an extra
/// "Create New Table" option appears on the table-picker step and leads to
/// the game-type wizard before creating a named table.
class JoinGameScreen extends StatefulWidget {
  ///
  const JoinGameScreen({
    super.key,
    this.canCreateTable = false,
    this.initialRoom,
    this.gameStyle = GameStyles.frenchCards9,
  });

  /// When true, shows the "Create New Table" option on the table-picker step.
  final bool canCreateTable;

  /// Game style to use when launching the game from the join wizard.
  final GameStyles gameStyle;

  /// Optional room preselected before entering the join wizard.
  final String? initialRoom;

  @override
  JoinGameScreenState createState() => JoinGameScreenState();
}

///
class JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _controllerName = TextEditingController();
  int _currentStep = 0;
  late List<String> _listOfRooms;
  static const List<String> _offlineDemoRooms = ['BANANA', 'KIWI', 'APPLE'];
  late String _playerName;
  late Set<String> _playerNames;
  late String _preparedRoom;
  bool _roomsFetched = false;
  late GameStyles _selectedGameStyle;
  late String _selectedRoom;
  StreamSubscription? _streamSubscription;
  bool _waitingOnFirstBackendData = false;

  ///
  final String appVersion = packageVersion;
  @override
  void initState() {
    super.initState();
    _selectedGameStyle = widget.gameStyle;
    _selectedRoom = widget.initialRoom?.trim().toUpperCase() ?? '';
    _playerName = '';
    _playerNames = {};
    _preparedRoom = '';
    _listOfRooms = [];
    _currentStep = _selectedRoom.isNotEmpty ? _stepWaiting : _stepTablePick;
    _prefillPlayerNameFromIdentity().then((_) {
      if (_selectedRoom.isNotEmpty) {
        _joinGameAndContinue();
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _controllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Screen(
      isWaiting: false,
      title: widget.canCreateTable
          ? localizations.startTable
          : localizations.joinGameTitle,
      child: Padding(
        padding: const EdgeInsets.all(ConstLayout.paddingM),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(child: _buildStepContent()),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  /// Builds navigation actions for the current wizard step.
  Widget _buildActions() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    if (_currentStep == _stepGameType) {
      return WizardFooter(
        backLabel: localizations.back,
        onBack: () => setState(() => _currentStep = _stepTablePick),
        primaryLabel: localizations.next,
        isPrimaryEnabled: true,
        onForward: _navigateToCreateNewGame,
      );
    }
    return WizardFooter(
      backLabel: localizations.back,
      onBack: _currentStep > _stepTablePick
          ? () => setState(() {
              _currentStep = _stepTablePick;
            })
          : null,
      primaryLabel: _currentStep == _stepWaiting
          ? localizations.startGame
          : localizations.next,
      isPrimaryEnabled: _canProceed,
      onForward: () {
        if (_currentStep == _stepWaiting) {
          _startGame(context);
        } else if (_currentStep == _stepTablePick) {
          _joinGameAndContinue();
        }
      },
    );
  }

  /// Builds a selectable game style card with a compact layout preview.
  Widget _buildGameStyleOption({
    required int columns,
    required GameStyles style,
    required int rows,
    required String label,
  }) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool isSelected = _selectedGameStyle == style;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return MyButtonRectangle(
      width: double.infinity,
      height: ConstLayout.mainMenuButtonHeight,
      onTap: () => setState(() => _selectedGameStyle = style),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ConstLayout.paddingM),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? colorScheme.tertiary : colorScheme.onSurface,
            ),
            const SizedBox(width: ConstLayout.sizeM),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: ConstLayout.textM,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    localizations.columnsByRows(columns, rows),
                    style: TextStyle(
                      fontSize: ConstLayout.textS,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: ConstLayout.sizeM),
            _buildMiniLayoutPreview(
              columns: columns,
              isSelected: isSelected,
              rows: rows,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the game-type selection step shown when creating a new table.
  Widget _buildGameTypeStep() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: ConstLayout.mainMenuMaxWidth),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: ConstLayout.sizeM,
        children: [
          Text(
            localizations.wizardStepOneOfTwo,
            style: TextStyle(
              fontSize: ConstLayout.textS,
              fontWeight: FontWeight.bold,
              color: colorScheme.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            localizations.whatTypeOfGame,
            style: TextStyle(
              fontSize: ConstLayout.textL,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            localizations.startGameWizardSubtitle,
            style: TextStyle(
              fontSize: ConstLayout.textS,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          for (final _GameTypeOption option in _gameTypeOptions)
            _buildGameStyleOption(
              columns: option.columns,
              style: option.style,
              rows: option.rows,
              label: _getLocalizedLabel(option.labelKey, localizations),
            ),
        ],
      ),
    );
  }

  /// Builds a single miniature card used in style preview grids.
  Widget _buildMiniCard({required Color cardBorder, required Color cardFill}) {
    return Container(
      width: _miniCardWidth,
      height: _miniCardHeight,
      decoration: BoxDecoration(
        color: cardFill,
        borderRadius: BorderRadius.circular(ConstLayout.radiusXS),
        border: Border.all(color: cardBorder, width: ConstLayout.strokeXXS),
      ),
    );
  }

  /// Builds a mini grid preview that mirrors the selected card layout.
  Widget _buildMiniLayoutPreview({
    required int columns,
    required bool isSelected,
    required int rows,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color cardFill = isSelected
        ? colorScheme.secondary.withAlpha(ConstLayout.alphaH)
        : colorScheme.surface.withAlpha(ConstLayout.alphaM);
    final Color cardBorder = isSelected
        ? colorScheme.tertiary
        : colorScheme.onSurface.withAlpha(ConstLayout.alphaM);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int rowIndex = 0; rowIndex < rows; rowIndex++) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int colIndex = 0; colIndex < columns; colIndex++) ...[
                _buildMiniCard(cardBorder: cardBorder, cardFill: cardFill),
                if (colIndex < columns - 1)
                  const SizedBox(width: _miniCardSpacing),
              ],
            ],
          ),
          if (rowIndex < rows - 1) const SizedBox(height: _miniCardSpacing),
        ],
      ],
    );
  }

  /// Builds the room selection step with searchable available tables.
  Widget _buildRoomSelectionStep() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (!_roomsFetched) {
      _roomsFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAllRooms());
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: ConstLayout.mainMenuMaxWidth),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: ConstLayout.sizeM,
        children: [
          Text(
            localizations.selectTableToJoin,
            style: TextStyle(
              fontSize: ConstLayout.textL,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.canCreateTable
                ? localizations.pickTableOrCreateHint
                : localizations.useSearchBox,
            style: TextStyle(
              fontSize: ConstLayout.textS,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.canCreateTable)
            MyButtonRectangle.menu(
              label: localizations.createNewTable,
              icon: Icons.add_circle_outline,
              onTap: () => setState(() => _currentStep = _stepGameType),
            ),
          TableWidget(
            roomId: _selectedRoom,
            rooms: _listOfRooms,
            onSelected: (String room) {
              setState(() {
                _selectedRoom = room;
                _preparedRoom = '';
              });
            },
            onRemoveRoom: null,
          ),
        ],
      ),
    );
  }

  /// Returns the widget content for the currently active wizard step.
  Widget _buildStepContent() {
    switch (_currentStep) {
      case _stepTablePick:
        return _buildRoomSelectionStep();
      case _stepGameType:
        return _buildGameTypeStep();
      case _stepWaiting:
        return _buildWaitingStep();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Builds the waiting step that shows current players before game start.
  Widget _buildWaitingStep() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    _prepareForSelectedRoomIfNeeded();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: ConstLayout.sizeM,
      children: [
        Text(
          localizations.tableLabel(_selectedRoom),
          style: TextStyle(
            fontSize: ConstLayout.textM,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        _waitingOnFirstBackendData
            ? const CircularProgressIndicator()
            : Container(
                constraints: const BoxConstraints(
                  maxWidth: ConstLayout.joinGamePlayerListMaxWidth,
                ),
                child: PlayersInRoomWidget(
                  activePlayerName: _playerName,
                  playerNames: _playerNames.toList(),
                  onPlayerSelected: (String _ /* name */) {
                    // Do nothing for join mode
                  },
                  onRemovePlayer: _removePlayer,
                ),
              ),

        if (_playerNames.length < CardModel.minPlayersToStartGame)
          Text(
            localizations.waitingForMorePlayers,
            style: TextStyle(fontSize: ConstLayout.textS),
          )
        else
          Text(
            localizations.readyToPlayPlayersAtTable(_playerNames.length),
            style: TextStyle(
              fontSize: ConstLayout.textS,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
      ],
    );
  }

  /// Indicates whether the current step has enough data to move forward.
  bool get _canProceed {
    switch (_currentStep) {
      case _stepTablePick:
        return _selectedRoom.isNotEmpty && _playerName.isNotEmpty;
      case _stepGameType:
        return true;
      case _stepWaiting:
        return _playerNames.length >= CardModel.minPlayersToStartGame;
      default:
        return false;
    }
  }

  /// Loads all joinable rooms from backend (or demo data when offline).
  Future<void> _fetchAllRooms() async {
    if (isRunningOffLine) {
      _listOfRooms = _offlineDemoRooms; // Demo rooms
      setState(() {});
      return;
    }

    try {
      await useFirebase();
      final rooms = await getAllRooms();
      if (mounted) {
        setState(() {
          _listOfRooms = List.from(rooms);
        });
      }
    } catch (e) {
      logger.e('Error fetching rooms: $e');
    }
  }

  /// Gets localized label for a game type option.
  String _getLocalizedLabel(String labelKey, AppLocalizations localizations) {
    switch (labelKey) {
      case 'golf9CardsFull':
        return localizations.golf9CardsFull;
      case 'miniPutFull':
        return localizations.miniPutFull;
      case GameConstants.gameStyleLabelKeySkyjo:
        return localizations.skyjo;
      default:
        return labelKey;
    }
  }

  /// Adds the typed player name to the selected room and local state.
  void _joinGame() {
    final name = _controllerName.text.trim().toUpperCase();
    if (name.isNotEmpty) {
      _playerNames.add(name);
      setPlayersInRoom(_selectedRoom, _playerNames);
      _controllerName.text = name;
      _playerName = name;
      setState(() {});
    }
  }

  /// Joins the room, then advances to the waiting step when possible.
  Future<void> _joinGameAndContinue() async {
    if (_playerName.isEmpty) {
      await _prefillPlayerNameFromIdentity();
    }

    _joinGame();
    if (_playerName.isEmpty) {
      return;
    }

    if (_currentStep < _stepWaiting) {
      setState(() {
        _currentStep = _stepWaiting;
      });
    }
  }

  /// Navigates to the create-room flow using the selected game style.
  void _navigateToCreateNewGame() {
    Navigator.pushReplacementNamed(
      context,
      '/create-table',
      arguments: _selectedGameStyle,
    );
  }

  /// Pre-fills the player name field from stored identity when empty.
  Future<void> _prefillPlayerNameFromIdentity() async {
    final String? stored = await IdentityService.getStoredInitials();
    final String fallbackInitials = Screen.avatarFallbackInitials(
      displayName: AuthService.currentUser?.displayName,
      email: AuthService.currentUser?.email,
    );
    final String name = stored != null && stored.isNotEmpty
        ? stored
        : fallbackInitials;
    if (!mounted || name.isEmpty) return;

    if (_controllerName.text.isEmpty) {
      setState(() {
        _controllerName.text = name;
        _playerName = name;
      });
    }
  }

  /// Subscribes to room updates and initializes invitee state for [roomId].
  void _prepareForRoom(String roomId) {
    setState(() {
      _waitingOnFirstBackendData = true;
    });
    _streamSubscription?.cancel();

    useFirebase().then((_) async {
      try {
        final List<String> invitees = await getPlayersInRoom(roomId);
        if (mounted) {
          setState(() {
            _playerNames = Set.from(invitees);
            _waitingOnFirstBackendData = false;

            _streamSubscription = onBackendInviteesUpdated(roomId, (
              invitees,
            ) async {
              final List<String> rooms = await getAllRooms();
              if (mounted) {
                setState(() {
                  _listOfRooms = List.from(rooms);
                  _playerNames = Set.from(invitees);
                });
              }
            });
          });
        }
      } catch (error) {
        logger.w('prepareForRoom failed: $error');
        if (mounted) {
          setState(() {
            _waitingOnFirstBackendData = false;
          });
        }
      }
    });
  }

  /// Prepares backend listeners once when a new room selection is made.
  void _prepareForSelectedRoomIfNeeded() {
    if (_selectedRoom.isEmpty || _preparedRoom == _selectedRoom) {
      return;
    }

    _preparedRoom = _selectedRoom;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedRoom.isEmpty) {
        return;
      }
      _prepareForRoom(_selectedRoom);
    });
  }

  /// Removes a player from the room and syncs the backend invitee list.
  void _removePlayer(String nameToRemove) {
    _playerNames.remove(nameToRemove);
    setPlayersInRoom(_selectedRoom, _playerNames);
    if (mounted) {
      setState(() {});
    }
  }

  /// Builds a new [GameModel] from selected room settings and navigates.
  Future<void> _startGame(BuildContext context) async {
    final List<GameHistory> history = await getGameHistory(_selectedRoom);

    final config = getGameStyleConfig(_selectedGameStyle, _playerNames.length);

    final gameModel = GameModel(
      version: appVersion,
      gameStyle: _selectedGameStyle,
      roomName: _selectedRoom,
      roomHistory: history,
      loginUserName: _playerName,
      names: _playerNames.toList(),
      cardsToDeal: config.cardsToDeal,
      deck: DeckModel(
        numberOfDecks: config.decks,
        gameStyle: _selectedGameStyle,
      ),
      isNewGame: true,
    );

    if (mounted) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => GameScreen(gameModel: gameModel)),
      );
    }
  }
}
