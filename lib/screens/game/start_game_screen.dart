import 'dart:async';

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/app/identity_service.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/version.dart';
import 'package:cards/screens/game/game_screen.dart';
import 'package:cards/screens/game/game_style.dart';
import 'package:cards/screens/game/start_screen_action_button.dart';
import 'package:cards/screens/game/start_screen_constants.dart';
import 'package:cards/screens/game/start_screen_game_instructions.dart';
import 'package:cards/screens/game/start_screen_game_handler.dart';
import 'package:cards/screens/game/start_screen_game_mode.dart';
import 'package:cards/screens/game/start_screen_player_name_input.dart';
import 'package:cards/screens/game/start_screen_room_section.dart';
import 'package:cards/screens/game/table_name_flow_helpers.dart';
import 'package:cards/utils/browser_utils.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/player/players_in_room_widget.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The initial screen for the card game application.
///
/// This screen serves as the entry point for users, allowing them to either join an
/// existing game room or create a new one. It features input fields for the
/// user's name and a room name. If the specified room already exists, the user
/// can join it; otherwise, a new room is created.
///
/// The screen displays a real-time list of players in the selected room and
/// enables the game to start once at least two players have joined. It also
/// includes an expandable section that provides a brief overview of the game's
/// rules.
///
/// Key functionalities of this screen include:
/// - **Room and Player Management**: Handles creating, joining, and displaying rooms
///   and players.
/// - **Game Style Selection**: Allows users to choose from different game styles.
/// - **URL Parameter Processing**: Supports joining rooms and setting player names
///   directly via URL parameters for a seamless experience.
/// - **Real-time Updates**: Utilizes Firebase Realtime Database to keep the room
///   state synchronized across all clients.
/// - **Link Sharing**: Generates a shareable link to invite others to the current
///   game room.
/// - **Offline Mode**: Provides an offline mode for testing and development.
class StartScreen extends StatefulWidget {
  /// Creates a [StartScreen] widget.
  ///
  /// [joinMode] when true, pre-expands the rooms dropdown and focuses on joining.
  const StartScreen({
    super.key,
    this.joinMode = false,
    this.initialGameStyle,
    this.createRoomFlow = false,
    this.skipCreateTableNameStep = false,
    this.initialCreateRoomName,
  });

  /// Enables create-room-first behavior (ask for table name first).
  final bool createRoomFlow;

  /// Optional pre-validated table name for create flow.
  final String? initialCreateRoomName;

  /// Optional game style that preselects the create-room flow mode.
  final GameStyles? initialGameStyle;

  /// Whether this screen is opened in join mode.
  final bool joinMode;

  /// When true, skips create table-name step and opens player setup directly.
  final bool skipCreateTableNameStep;

  @override
  StartScreenState createState() => StartScreenState();
}

/// The state for the [StartScreen].
///
/// This class manages the state of the start screen, including handling user
/// input, interacting with the backend service (Firebase), and updating the UI
/// in response to state changes.
class StartScreenState extends State<StartScreen> {
  /// The last table name that was checked for existence.
  String _checkedCreateTableName = '';

  /// Controller for the player name text field.
  final TextEditingController _controllerName = TextEditingController();

  /// Controller for the room name text field.
  final TextEditingController _controllerRoom = TextEditingController(
    text: StartScreenConstants.offlineDemoDefaultRoomName,
  );

  /// Whether the currently checked table name already exists.
  bool _doesCreateTableNameExist = false;

  /// Error text for the player name input field. Currently unused.
  final String _errorTextName = '';

  /// Error text for the room name input field. Currently unused.
  final String _errorTextRoom = '';

  /// Game handler for backend interactions.
  late StartScreenGameHandler _gameHandler;

  /// Whether a create-flow table-name availability check is in progress.
  bool _isCheckingCreateTableName = false;

  /// Whether the create flow has passed the table-name-only step.
  bool _isCreateTableStepComplete = false;

  /// A flag indicating whether the list of rooms is expanded.
  bool _isExpandedRooms = false;

  /// A flag indicating whether the game rules are expanded.
  bool _isExpandedRules = false;

  /// A list of all available rooms.
  List<String> _listOfRooms = [];

  /// A set of player names currently in the room.
  Set<String> _playerNames = {};

  /// Debounces room lookup while typing a room name.
  Timer? _roomLookupDebounce;

  /// The currently selected game style.
  GameStyles _selectedGameStyle = GameStyles.frenchCards9;

  /// A flag indicating whether the app is waiting for the first data from the backend.
  bool _waitingOnFirstBackendData = !isRunningOffLine;
  @override
  void initState() {
    super.initState();
    _gameHandler = StartScreenGameHandler(
      onPlayersUpdated: (List<String> players, List<String> rooms) {
        if (!mounted || roomName != _controllerRoom.text.trim().toUpperCase()) {
          return;
        }
        setState(() {
          _listOfRooms = rooms;
          _playerNames = Set.from(players);
        });
      },
      onError: (String error) {
        logger.e(error);
      },
    );
    _selectedGameStyle = widget.initialGameStyle ?? GameStyles.frenchCards9;
    _isExpandedRooms = widget.joinMode;
    _isCreateTableStepComplete = !widget.createRoomFlow;
    if (widget.createRoomFlow) {
      _waitingOnFirstBackendData = false;
      final String prefilledCreateRoomName =
          (widget.initialCreateRoomName ?? '').trim().toUpperCase();
      final bool hasPrefilledCreateRoom =
          widget.skipCreateTableNameStep && prefilledCreateRoomName.isNotEmpty;
      if (hasPrefilledCreateRoom) {
        _controllerRoom.text = prefilledCreateRoomName;
        _isCreateTableStepComplete = true;
        _checkedCreateTableName = prefilledCreateRoomName;
      } else {
        _controllerRoom.clear();
      }
    }
    _processUrlArguments();
    _prefillPlayerNameFromIdentity();
  }

  @override
  void dispose() {
    _gameHandler.dispose();
    _roomLookupDebounce?.cancel();
    _controllerRoom.dispose();
    _controllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool isCreateTableNameStep =
        widget.createRoomFlow && !_isCreateTableStepComplete;
    final bool showPlayerInputFields =
        !widget.createRoomFlow || _isCreateTableStepComplete;

    return Screen(
      isWaiting: _waitingOnFirstBackendData,
      title: localizations.cardGamesTitle,
      getLinkToShare: () {
        return _getUrlToGame();
      },
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(ConstLayout.paddingM),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ConstLayout.startGameScreenMaxWidth,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!widget.createRoomFlow) _buildGameModeWidget(),
                  if (!widget.createRoomFlow)
                    IntrinsicHeight(child: _buildGameInstructionsWidget()),
                  _buildRoomSectionWidget(isCreateTableNameStep),
                  const SizedBox(height: ConstLayout.sizeXS),
                  if (showPlayerInputFields) _buildPlayersWidget(),
                  const SizedBox(height: ConstLayout.sizeS),
                  if (showPlayerInputFields) _buildPlayerNameInputWidget(),
                  const SizedBox(height: ConstLayout.sizeM),
                  if (showPlayerInputFields) _buildActionButtonWidget(),
                  const SizedBox(height: ConstLayout.sizeM),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Adds one or more players to the current room.
  void joinGame(final String nameOrNamesToAdd) {
    if (roomName.isEmpty) {
      return;
    }

    final List<String> names = nameOrNamesToAdd
        .toUpperCase()
        .split(',')
        .map((String name) => name.trim())
        .where((String name) => name.isNotEmpty)
        .toList();

    if (names.isEmpty) {
      return;
    }

    setState(() {
      _playerNames.addAll(names);
      _controllerName.text = names.first;
    });

    _gameHandler.addPlayersToRoom(roomName, _playerNames);
  }

  /// Prepares the backend for the specified room.
  void prepareBackEndForRoom(final String roomId) async {
    final String normalizedRoomId = roomId.trim().toUpperCase();
    if (normalizedRoomId.isEmpty) {
      setState(() {
        _playerNames = {};
        _waitingOnFirstBackendData = false;
      });
      return;
    }

    setState(() {
      _waitingOnFirstBackendData = true;
      if (widget.createRoomFlow) {
        _playerNames = {};
      }
    });

    final List<String> players = await _gameHandler.prepareBackEndForRoom(
      normalizedRoomId,
    );

    if (!mounted || roomName != normalizedRoomId) {
      return;
    }

    setState(() {
      _playerNames = Set.from(players);
      _waitingOnFirstBackendData = false;
    });
  }

  /// Removes a player from the current room.
  void removePlayer(final String nameToRemove) {
    if (!_playerNames.contains(nameToRemove)) {
      return;
    }

    setState(() {
      _playerNames.remove(nameToRemove);
    });

    _gameHandler.removePlayerFromRoom(roomName, _playerNames);
  }

  /// The name of the room, derived from the [_controllerRoom].
  String get roomName => _controllerRoom.text.trim().toUpperCase();

  /// Starts the game and navigates to the game screen.
  void startGame(BuildContext context) async {
    final GameModel? newGame = await _gameHandler.initializeGame(
      appVersion: packageVersion,
      gameStyle: _selectedGameStyle,
      roomName: roomName,
      playerName: _controllerName.text.toUpperCase(),
      playerNames: _playerNames.toList(),
    );

    if (newGame == null) {
      return;
    }

    // Update the URL to include the room ID without reloading the page.
    _updateUrlWithoutReload();

    // Navigate to the main game screen.
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext _) => GameScreen(gameModel: newGame),
        ),
      );
    }
  }

  /// Builds the action button widget.
  Widget _buildActionButtonWidget() {
    return StartScreenActionButton(
      playerName: _playerName,
      isPlayerInList: _playerNames.contains(_playerName.toUpperCase()),
      playerCount: _playerNames.length,
      isCreateRoomFlow: widget.createRoomFlow,
      onJoinGame: () => joinGame(_playerName),
      onStartGame: () => startGame(context),
    );
  }

  /// Builds the game instructions widget.
  Widget _buildGameInstructionsWidget() {
    return StartScreenGameInstructions(
      gameStyle: _selectedGameStyle,
      isExpanded: _isExpandedRules,
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpandedRules = expanded;
        });
      },
    );
  }

  /// Builds the game mode widget.
  Widget _buildGameModeWidget() {
    return StartScreenGameMode(
      selectedGameStyle: _selectedGameStyle,
      onGameStyleChanged: (GameStyles style) {
        setState(() {
          _selectedGameStyle = style;
        });
      },
    );
  }

  /// Builds the player name input widget.
  Widget _buildPlayerNameInputWidget() {
    return StartScreenPlayerNameInput(
      controller: _controllerName,
      onSubmitted: () {
        _controllerName.text = _controllerName.text.toUpperCase();
        joinGame(_controllerName.text);
      },
      onAddTap: () => joinGame(_controllerName.text),
      errorStatus: _errorTextName,
    );
  }

  /// Builds the players-in-room list widget.
  Widget _buildPlayersWidget() {
    return SizedBox(
      width: ConstLayout.startGameScreenMaxWidth,
      child: PlayersInRoomWidget(
        activePlayerName: _playerName,
        playerNames: _playerNames.toList(),
        onPlayerSelected: (String name) {
          setState(() {
            _controllerName.text = name;
          });
        },
        onRemovePlayer: removePlayer,
      ),
    );
  }

  /// Builds the room section widget.
  Widget _buildRoomSectionWidget(bool isCreateTableNameStep) {
    return StartScreenRoomSection(
      roomController: _controllerRoom,
      isCreateTableNameStep: isCreateTableNameStep,
      isCheckingCreateTableName: _isCheckingCreateTableName,
      isExpandedRooms: _isExpandedRooms,
      availableRooms: _listOfRooms,
      doesTableNameExist: _doesCreateTableNameExist,
      isCreateRoomFlow: widget.createRoomFlow,
      playerName: _playerName,
      roomName: roomName,
      errorStatus: _errorTextRoom,
      onRoomChanged: (_) => _onRoomNameChanged(),
      onRoomSubmitted: () {
        _controllerRoom.text = _controllerRoom.text.toUpperCase();
        if (roomName.isEmpty) return;
        if (isCreateTableNameStep) {
          _lookupCreateTableName(roomName);
          return;
        }
        prepareBackEndForRoom(roomName);
      },
      onShowRoomsToggle: () {
        setState(() {
          _isExpandedRooms = !_isExpandedRooms;
        });
      },
      onRoomSelected: (String room) {
        _controllerRoom.text = room;
        if (roomName.isNotEmpty) {
          prepareBackEndForRoom(roomName);
        }
        setState(() {
          _isExpandedRooms = false;
        });
      },
      onContinuePressed: _continueCreateWithNewTableName,
      onJoinExistingTable: () {
        openJoinFlowForTable(
          context: context,
          tableName: roomName,
          gameStyle: _selectedGameStyle,
        );
      },
      onRemoveRoom: (_) {},
    );
  }

  /// Proceeds from table-name validation to player setup for a unique new table.
  void _continueCreateWithNewTableName() {
    final bool isUniqueTableName =
        roomName.isNotEmpty &&
        _checkedCreateTableName == roomName &&
        !_doesCreateTableNameExist &&
        !_isCheckingCreateTableName;
    if (!isUniqueTableName) {
      return;
    }

    setState(() {
      _isCreateTableStepComplete = true;
      _waitingOnFirstBackendData = false;
    });

    prepareBackEndForRoom(roomName);
  }

  /// Generates a shareable URL for the current game.
  String _getUrlToGame() {
    if (!kIsWeb) {
      return '';
    }
    // Invite link — omit player names so joiners start with a blank name field.
    return '${getWindowOrigin()}?mode=${_selectedGameStyle.index}&room=${Uri.encodeComponent(roomName)}';
  }

  /// Validates whether [tableName] already exists.
  Future<void> _lookupCreateTableName(String tableName) async {
    final String normalizedTableName = tableName.trim().toUpperCase();
    if (normalizedTableName.isEmpty) {
      return;
    }

    if (isRunningOffLine) {
      if (!mounted || roomName != normalizedTableName) return;

      setState(() {
        _checkedCreateTableName = normalizedTableName;
        _doesCreateTableNameExist = false;
        _isCheckingCreateTableName = false;
      });
      return;
    }

    try {
      final result = await _gameHandler.checkTableNameAvailability(
        normalizedTableName,
      );

      if (!mounted || roomName != normalizedTableName) return;

      setState(() {
        _listOfRooms = result.rooms;
        _checkedCreateTableName = normalizedTableName;
        _doesCreateTableNameExist = result.exists;
        _isCheckingCreateTableName = false;
      });
    } catch (error) {
      logger.e(
        'Error checking create-table name availability for $normalizedTableName: $error',
      );
      if (!mounted || roomName != normalizedTableName) return;
      setState(() {
        _checkedCreateTableName = normalizedTableName;
        _doesCreateTableNameExist = false;
        _isCheckingCreateTableName = false;
      });
    }
  }

  /// Handles room-name changes and validates uniqueness in create flow.
  void _onRoomNameChanged() {
    if (!widget.createRoomFlow || _isCreateTableStepComplete) {
      return;
    }

    _roomLookupDebounce?.cancel();

    if (roomName.isEmpty) {
      setState(() {
        _playerNames = {};
        _checkedCreateTableName = '';
        _doesCreateTableNameExist = false;
        _isCheckingCreateTableName = false;
        _waitingOnFirstBackendData = false;
      });
      return;
    }

    setState(() {
      _playerNames = {};
      _checkedCreateTableName = roomName;
      _doesCreateTableNameExist = false;
      _isCheckingCreateTableName = true;
      _waitingOnFirstBackendData = false;
    });

    _roomLookupDebounce = Timer(StartScreenConstants.roomLookupDebounce, () {
      _lookupCreateTableName(roomName);
    });
  }

  /// The trimmed player name entered by the user.
  String get _playerName => _controllerName.text.trim();

  /// Fetches the application version from the platform package info.
  /// Pre-fills the player name field from stored identity when empty.
  Future<void> _prefillPlayerNameFromIdentity() async {
    if (_controllerName.text.isNotEmpty) return;
    final name = await IdentityService.resolveIdentityName();
    if (!mounted || name == null || name.isEmpty) return;
    if (_controllerName.text.isEmpty) {
      setState(() {
        _controllerName.text = name;
      });
      if (widget.createRoomFlow && _isCreateTableStepComplete) {
        joinGame(name);
      }
    }
  }

  /// Processes URL arguments to set the initial state of the screen.
  void _processUrlArguments() {
    if (isRunningOffLine) {
      if (widget.createRoomFlow) {
        final String prefilledCreateRoomName =
            (widget.initialCreateRoomName ?? '').trim().toUpperCase();
        final bool hasPrefilledCreateRoom =
            widget.skipCreateTableNameStep &&
            prefilledCreateRoomName.isNotEmpty;
        _isCreateTableStepComplete = hasPrefilledCreateRoom;
        _isCheckingCreateTableName = false;
        _doesCreateTableNameExist = false;
        _checkedCreateTableName = hasPrefilledCreateRoom
            ? prefilledCreateRoomName
            : '';
        _playerNames = {};
        _controllerRoom.text = hasPrefilledCreateRoom
            ? prefilledCreateRoomName
            : '';
        _controllerName.text = '';
      } else {
        _isCreateTableStepComplete = true;
        _playerNames = StartScreenConstants.offlineDemoPlayers;
        _controllerRoom.text = StartScreenConstants.offlineDemoRoomName;
        _controllerName.text = StartScreenConstants.offlineDemoPlayerBob;
      }
      return;
    }

    final uri = Uri.parse(Uri.base.toString());

    final gameModeUrl = uri.queryParameters['mode'] ?? '';
    _selectedGameStyle = intToGameStyles(
      int.tryParse(gameModeUrl) ?? _selectedGameStyle.index,
    );

    final roomFromUrl = uri.queryParameters['room'];
    if (roomFromUrl != null) {
      _controllerRoom.text = roomFromUrl.toUpperCase();
    }

    final playersFromUrl = uri.queryParameters['players'];
    if (playersFromUrl != null && playersFromUrl.isNotEmpty) {
      final playerNames = playersFromUrl
          .toUpperCase()
          .split(',')
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toList();
      if (playerNames.isNotEmpty) {
        _controllerName.text = playerNames.first;
        _playerNames = playerNames.toSet();

        Future.delayed(Duration.zero, () async {
          await useFirebase();
          _gameHandler.addPlayersToRoom(roomName, _playerNames);
        });
      }
    }

    if (roomName.isNotEmpty) {
      if (widget.createRoomFlow && !_isCreateTableStepComplete) {
        _onRoomNameChanged();
      } else {
        prepareBackEndForRoom(roomName);
      }
    } else {
      _waitingOnFirstBackendData = false;
    }
  }

  /// Updates the browser's URL without reloading the page.
  void _updateUrlWithoutReload() {
    if (kIsWeb) {
      final AppLocalizations localizations = AppLocalizations.of(context);
      pushHistoryState('${localizations.appTitle} $roomName', _getUrlToGame());
    }
  }
}
