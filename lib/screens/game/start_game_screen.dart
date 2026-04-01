import 'dart:async';

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_history.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/screens/game/game_screen.dart';
import 'package:cards/screens/game/game_style.dart';
import 'package:cards/screens/game/table_name_flow_helpers.dart';
import 'package:cards/utils/browser_utils.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/helpers/table_widget.dart';
import 'package:cards/widgets/player/players_in_room_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  /// Optional prevalidated table name for create flow.
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
    text: _offlineDemoDefaultRoomName, // Default room name
  );

  /// Whether the currently checked table name already exists.
  bool _doesCreateTableNameExist = false;

  /// Error text for the player name input field. Currently unused.
  final String _errorTextName = '';

  /// Error text for the room name input field. Currently unused.
  final String _errorTextRoom = '';

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
  static const String _offlineDemoDefaultRoomName = 'KIWI';
  static const String _offlineDemoPlayerBob = 'BOB';
  static const String _offlineDemoPlayerJohn = 'JOHN';
  static const String _offlineDemoPlayerSue = 'SUE';
  static const Set<String> _offlineDemoPlayers = {
    _offlineDemoPlayerBob,
    _offlineDemoPlayerSue,
    _offlineDemoPlayerJohn,
  };
  static const String _offlineDemoRoomName = 'BANANA';

  /// A set of player names currently in the room.
  Set<String> _playerNames = {};

  /// Debounces room lookup while typing a room name.
  Timer? _roomLookupDebounce;

  /// The currently selected game style.
  GameStyles _selectedGameStyle = GameStyles.frenchCards9;

  /// A subscription to the Firebase Realtime Database stream.
  ///
  /// This is used to receive real-time updates for the current room.
  StreamSubscription? _streamSubscription;

  /// A flag indicating whether the app is waiting for the first data from the backend.
  bool _waitingOnFirstBackendData = !isRunningOffLine;

  /// The current version of the app.
  String appVersion = '?.?.?';
  @override
  void initState() {
    super.initState();
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
    _getAppVersion();
  }

  @override
  void dispose() {
    // Cancel the Firebase subscription to prevent memory leaks.
    _streamSubscription?.cancel();
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
    final bool isCreateTableNameCheckReady =
        roomName.isNotEmpty &&
        _checkedCreateTableName == roomName &&
        !_isCheckingCreateTableName;
    final bool showJoinShortcut =
        isCreateTableNameStep &&
        isCreateTableNameCheckReady &&
        _doesCreateTableNameExist;
    final bool canContinueToPlayerSetup =
        isCreateTableNameStep &&
        isCreateTableNameCheckReady &&
        !_doesCreateTableNameExist;
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
                  if (!widget.createRoomFlow) _gameMode(),
                  if (!widget.createRoomFlow)
                    IntrinsicHeight(child: _gameInstructionsWidget()),
                  if (isCreateTableNameStep)
                    Padding(
                      padding: const EdgeInsets.all(ConstLayout.paddingS),
                      child: Text(
                        localizations.enterTableName,
                        style: TextStyle(
                          fontSize: ConstLayout.textS,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: ConstLayout.sizeM),
                  if (!widget.createRoomFlow || isCreateTableNameStep)
                    Row(
                      children: [
                        EditBox(
                          label: localizations.table,
                          controller: _controllerRoom,
                          onSubmitted: () {
                            _controllerRoom.text = _controllerRoom.text
                                .toUpperCase();
                            if (roomName.isEmpty) {
                              return;
                            }

                            if (isCreateTableNameStep) {
                              _lookupCreateTableName(roomName);
                              return;
                            }

                            prepareBackEndForRoom(roomName);
                          },
                          onChanged: (String _ /* tableName */) {
                            _onRoomNameChanged();
                          },
                          errorStatus: _errorTextRoom,
                          rightSideChild: widget.createRoomFlow
                              ? const SizedBox.shrink()
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExpandedRooms = !_isExpandedRooms;
                                    });
                                  },
                                  icon: Icon(
                                    _isExpandedRooms
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  if (widget.createRoomFlow && !isCreateTableNameStep)
                    Padding(
                      padding: const EdgeInsets.all(ConstLayout.paddingS),
                      child: Text(
                        localizations.tableLabel(roomName),
                        style: TextStyle(
                          fontSize: ConstLayout.textM,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (!widget.createRoomFlow && _isExpandedRooms)
                    TableWidget(
                      roomId: roomName,
                      rooms: _listOfRooms,
                      onSelected: (String room) {
                        _controllerRoom.text = room;
                        if (roomName.isNotEmpty) {
                          prepareBackEndForRoom(roomName);
                        }
                        setState(() {
                          // we can now close the drop down
                          _isExpandedRooms = false;
                        });
                      },
                      onRemoveRoom: _playerName == 'JP'
                          ? (String _ /* room */) {}
                          : null,
                    ),
                  if (isCreateTableNameStep &&
                      roomName.isNotEmpty &&
                      _isCheckingCreateTableName)
                    const Padding(
                      padding: EdgeInsets.all(ConstLayout.paddingS),
                      child: SizedBox(
                        width: ConstLayout.sizeXXL,
                        height: ConstLayout.sizeXXL,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  const SizedBox(height: ConstLayout.sizeXS),
                  if (showPlayerInputFields)
                    SizedBox(
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
                    ),
                  if (showJoinShortcut)
                    Padding(
                      padding: const EdgeInsets.all(ConstLayout.paddingS),
                      child: Text(
                        localizations.thisTableAlreadyHasPlayers,
                        style: TextStyle(
                          fontSize: ConstLayout.textS,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (showJoinShortcut)
                    MyButtonRectangle(
                      width: double.infinity,
                      onTap: () {
                        openJoinFlowForTable(
                          context: context,
                          tableName: roomName,
                          gameStyle: _selectedGameStyle,
                        );
                      },
                      child: Text(
                        localizations.joinThisTable,
                        style: TextStyle(
                          fontSize: ConstLayout.textS,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  if (showJoinShortcut)
                    Padding(
                      padding: const EdgeInsets.all(ConstLayout.paddingS),
                      child: Text(
                        localizations.enterTableName,
                        style: TextStyle(
                          fontSize: ConstLayout.textS,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (isCreateTableNameStep)
                    MyButtonRectangle(
                      width: double.infinity,
                      onTap: canContinueToPlayerSetup
                          ? _continueCreateWithNewTableName
                          : null,
                      child: Text(
                        localizations.next,
                        style: TextStyle(
                          fontSize: ConstLayout.textM,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  const SizedBox(height: ConstLayout.sizeS),
                  if (showPlayerInputFields)
                    Padding(
                      padding: const EdgeInsets.all(ConstLayout.paddingS),
                      child: Text(localizations.whoAreYou),
                    ),
                  if (showPlayerInputFields)
                    const SizedBox(height: ConstLayout.sizeS),
                  if (showPlayerInputFields)
                    EditBox(
                      label: localizations.join,
                      controller: _controllerName,
                      onSubmitted: () {
                        _controllerName.text = _controllerName.text
                            .toUpperCase();
                        joinGame(_controllerName.text);
                      },
                      errorStatus: _errorTextName,
                      rightSideChild: IconButton(
                        onPressed: () {
                          joinGame(_controllerName.text);
                        },
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  const SizedBox(height: ConstLayout.sizeM),
                  if (showPlayerInputFields) actionButton(),
                  const SizedBox(height: ConstLayout.sizeM),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A button that either joins the current player to the game or starts the game.
  ///
  /// The button's label and action change based on whether the current player
  /// has already joined the game and whether there are enough players to start.
  Widget actionButton() {
    final AppLocalizations localizations = AppLocalizations.of(context);

    if (_playerName.isEmpty) {
      return MyButtonRectangle(
        onTap: () {}, // Disabled action
        width: double.infinity,
        height: ConstLayout.sizeXXL,
        child: Text(
          localizations.pleaseEnterYourName,
          style: TextStyle(
            fontSize: ConstLayout.textM,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    bool isPartOfTheList = _playerNames.contains(_playerName.toUpperCase());

    String label = isPartOfTheList
        ? (_playerNames.length > 1
              ? localizations.startGame
              : localizations.waitingForPlayers)
        : (widget.createRoomFlow
              ? localizations.createNewTable
              : localizations.joinGame);
    return MyButtonRectangle(
      onTap: () {
        if (isPartOfTheList) {
          if (_playerNames.length > 1) {
            startGame(context);
          }
        } else {
          joinGame(_playerName);
        }
      },
      width: double.infinity,
      height: ConstLayout.sizeXXL,
      child: Text(
        label,
        style: TextStyle(
          fontSize: ConstLayout.textM,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  /// Adds one or more players to the current room.
  ///
  /// This method takes a comma-separated string of names, processes them, and
  /// adds them to the list of players for the current room. It then updates the
  /// backend with the new list of players.
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

    setPlayersInRoom(roomName, _playerNames);
  }

  /// Prepares the backend for the specified room.
  ///
  /// This method sets up the connection to the backend service (Firebase) for
  /// the given [roomId]. It fetches the initial list of players in the room
  /// and sets up a stream to listen for real-time updates.
  void prepareBackEndForRoom(final String roomId) {
    final String normalizedRoomId = roomId.trim().toUpperCase();
    if (normalizedRoomId.isEmpty) {
      setState(() {
        _playerNames = {};
        _waitingOnFirstBackendData = false;
      });
      return;
    }

    if (isRunningOffLine) {
      setState(() {
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

    // Cancel any existing subscription.
    _streamSubscription?.cancel();

    // Fetch the initial data from Firebase.
    useFirebase()
        .then((_) async {
          final List<String> invitees = await getPlayersInRoom(
            normalizedRoomId,
          );
          if (!mounted || roomName != normalizedRoomId) {
            return;
          }

          setState(() {
            _playerNames = Set.from(invitees);
            _waitingOnFirstBackendData = false;

            // Listen for updates to the list of invitees.
            _streamSubscription = onBackendInviteesUpdated(normalizedRoomId, (
              invitees,
            ) async {
              final List<String> listOfRooms = await getAllRooms();
              if (!mounted || roomName != normalizedRoomId) {
                return;
              }

              setState(() {
                _listOfRooms = listOfRooms;
                _playerNames = Set.from(invitees);
              });
            });
          });
        })
        .catchError((Object error) {
          logger.e(
            'Error preparing backend for room $normalizedRoomId: $error',
          );
          if (!mounted || roomName != normalizedRoomId) {
            return;
          }
          setState(() {
            _playerNames = {};
            _waitingOnFirstBackendData = false;
          });
        });
  }

  /// Removes a player from the current room.
  ///
  /// This method removes the specified player from the list of players and
  /// updates the backend to reflect the change.
  void removePlayer(final String nameToRemove) {
    if (!_playerNames.contains(nameToRemove)) {
      return;
    }

    // Remove the player's name from the list of players.
    setState(() {
      _playerNames.remove(nameToRemove);
    });

    // Push the updated list of players to the backend.
    setPlayersInRoom(roomName, _playerNames);
  }

  /// The name of the room, derived from the [_controllerRoom].
  String get roomName => _controllerRoom.text.trim().toUpperCase();

  /// Starts the game and navigates to the game screen.
  ///
  /// This method is called when the user clicks the "Start Game" button. It
  /// creates a new [GameModel] with the current game settings and navigates
  /// to the [GameScreen].
  void startGame(BuildContext context) async {
    final List<GameHistory> history = await getGameHistory(roomName);
    logger.d(history.join('|'));

    final config = getGameStyleConfig(_selectedGameStyle, _playerNames.length);

    final GameModel newGame = GameModel(
      version: appVersion,
      gameStyle: _selectedGameStyle,
      roomName: roomName,
      roomHistory: history,
      loginUserName: _controllerName.text.toUpperCase(),
      names: _playerNames.toList(),
      cardsToDeal: config.cardsToDeal,
      deck: DeckModel(
        numberOfDecks: config.decks,
        gameStyle: _selectedGameStyle,
      ),
      isNewGame: true,
    );

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

  /// A widget that displays the game instructions in an expandable tile.
  Widget _gameInstructionsWidget() {
    final colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations localizations = AppLocalizations.of(context);
    return ExpansionTile(
      initiallyExpanded: _isExpandedRules,
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpandedRules = expanded;
        });
      },
      title: Text(
        localizations.gameRules,
        style: TextStyle(
          fontSize: ConstLayout.textM,
          color: colorScheme.primaryContainer,
        ),
      ),
      children: <Widget>[
        SizedBox(
          height: ConstLayout.gameStyleWidgetHeight,
          child: Padding(
            padding: const EdgeInsets.all(ConstLayout.paddingS),
            child: GameStyle(style: _selectedGameStyle),
          ),
        ),
      ],
    );
  }

  /// A widget for selecting the game mode.
  Widget _gameMode() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(ConstLayout.paddingS),
      child: SegmentedButton<GameStyles>(
        segments: [
          ButtonSegment<GameStyles>(
            value: GameStyles.frenchCards9,
            label: Text(localizations.golf9Cards),
          ),
          ButtonSegment<GameStyles>(
            value: GameStyles.skyjo,
            label: Text(localizations.skyjo),
          ),
          ButtonSegment<GameStyles>(
            value: GameStyles.miniPut,
            label: Text(localizations.miniPut),
          ),
        ],
        selected: {_selectedGameStyle},
        onSelectionChanged: (Set<GameStyles> value) {
          setState(() {
            _selectedGameStyle = value.first;
          });
        },
      ),
    );
  }

  /// Fetches the application version from the platform package info.
  Future<void> _getAppVersion() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
      });
    });
  }

  /// Generates a shareable URL for the current game.
  ///
  /// This method constructs a URL that includes the current game mode, room name,
  /// and player list, allowing others to join the game directly.
  String _getUrlToGame() {
    if (!kIsWeb) {
      return '';
    }
    return getWindowOrigin() +
        GameModel.getLinkToGameFromInput(
          _selectedGameStyle.index.toString(),
          roomName,
          _playerNames.toList(),
        );
  }

  /// Validates whether [tableName] already exists so create flow can enforce uniqueness.
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
      final TableNameLookupResult lookup = await lookupTableNameAvailability(
        normalizedTableName,
      );

      if (!mounted || roomName != normalizedTableName) return;

      setState(() {
        _listOfRooms = lookup.rooms;
        _checkedCreateTableName = normalizedTableName;
        _doesCreateTableNameExist = lookup.exists;
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
    _streamSubscription?.cancel();

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

    _roomLookupDebounce = Timer(
      const Duration(milliseconds: ConstLayout.animationDuration300),
      () {
        _lookupCreateTableName(roomName);
      },
    );
  }

  /// The trimmed player name entered by the user.
  String get _playerName => _controllerName.text.trim();

  /// Processes URL arguments to set the initial state of the screen.
  ///
  /// This method parses the URL for 'room', 'players', and 'mode' query
  /// parameters and configures the screen accordingly. This allows users to
  /// join a game directly via a shared link.
  void _processUrlArguments() {
    if (isRunningOffLine) {
      // For offline testing, use predefined values.
      // Example: '?room=BANANA&players=BOB,SUE,JOHN'
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
        _playerNames = _offlineDemoPlayers;
        _controllerRoom.text = _offlineDemoRoomName;
        _controllerName.text = _offlineDemoPlayerBob;
      }
      return;
    }

    // Parse the current URL.
    final uri = Uri.parse(Uri.base.toString());

    // Set the game mode from the 'mode' query parameter.
    final gameModeUrl = uri.queryParameters['mode'] ?? '';
    _selectedGameStyle = intToGameStyles(
      int.tryParse(gameModeUrl) ?? _selectedGameStyle.index,
    );

    // Set the room name from the 'room' query parameter.
    final roomFromUrl = uri.queryParameters['room'];
    if (roomFromUrl != null) {
      _controllerRoom.text = roomFromUrl.toUpperCase();
    }

    // Set the player names from the 'players' query parameter.
    final playersFromUrl = uri.queryParameters['players'];
    if (playersFromUrl != null) {
      final playerNames = playersFromUrl
          .toUpperCase()
          .split(',')
          .map((name) => name.trim())
          .toList();
      _controllerName.text =
          playerNames.first; // Set the first player as the default name.
      _playerNames = playerNames
          .toSet(); // Set the list of players in the room.

      // Delay setting players in the room until after the initial data load completes.
      Future.delayed(Duration.zero, () async {
        await useFirebase(); // Ensure Firebase is initialized.
        setPlayersInRoom(
          roomName,
          _playerNames,
        ); // Update the backend with the players.
      });
    }

    // Initialize the backend connection only when a room has been specified.
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
  ///
  /// This method uses the browser's History API to update the URL, which is
  /// useful for reflecting the current game state in the URL without a full
  /// page refresh.
  void _updateUrlWithoutReload() {
    if (kIsWeb) {
      final AppLocalizations localizations = AppLocalizations.of(context);
      // Push the new state to the browser's history.
      pushHistoryState('${localizations.appTitle} $roomName', _getUrlToGame());
    }
  }
}
