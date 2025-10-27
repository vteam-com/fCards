import 'dart:async';
import 'package:cards/misc.dart';
import 'package:cards/models/backend_model.dart';
import 'package:cards/models/game_history.dart';
import 'package:cards/models/game_model.dart';
import 'package:cards/screens/game/game_screen.dart';

import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/players_in_room_widget.dart';
import 'package:cards/widgets/rooms_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:web/web.dart' as web;

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
  const StartScreen({super.key, this.joinMode = false});

  /// Whether this screen is opened in join mode.
  final bool joinMode;

  @override
  StartScreenState createState() => StartScreenState();
}

/// The state for the [StartScreen].
///
/// This class manages the state of the start screen, including handling user
/// input, interacting with the backend service (Firebase), and updating the UI
/// in response to state changes.
class StartScreenState extends State<StartScreen> {
  /// A subscription to the Firebase Realtime Database stream.
  ///
  /// This is used to receive real-time updates for the current room.
  StreamSubscription? _streamSubscription;

  /// The currently selected game style.
  GameStyles _selectedGameStyle = GameStyles.frenchCards9;

  /// Controller for the room name text field.
  final TextEditingController _controllerRoom = TextEditingController(
    text: 'KIWI', // Default room name
  );

  /// The name of the room, derived from the [_controllerRoom].
  String get roomName => _controllerRoom.text.trim().toUpperCase();

  /// Error text for the room name input field. Currently unused.
  final String _errorTextRoom = '';

  /// Controller for the player name text field.
  final TextEditingController _controllerName = TextEditingController();

  /// Error text for the player name input field. Currently unused.
  final String _errorTextName = '';

  /// A set of player names currently in the room.
  Set<String> _playerNames = {};

  /// A list of all available rooms.
  List<String> _listOfRooms = [];

  /// The trimmed player name entered by the user.
  String get _playerName => _controllerName.text.trim();

  /// A flag indicating whether the app is waiting for the first data from the backend.
  bool _waitingOnFirstBackendData = !isRunningOffLine;

  /// A flag indicating whether the game rules are expanded.
  bool _isExpandedRules = false;

  /// A flag indicating whether the list of rooms is expanded.
  bool _isExpandedRooms = false;

  /// The current version of the app.
  String appVersion = '?.?.?';

  @override
  void initState() {
    super.initState();
    _isExpandedRooms = widget.joinMode;
    _processUrlArguments();
    _getAppVersion();
  }

  /// Fetches the application version from the platform package info.
  Future<void> _getAppVersion() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
      });
    });
  }

  @override
  void dispose() {
    // Cancel the Firebase subscription to prevent memory leaks.
    _streamSubscription?.cancel();
    _controllerRoom.dispose();
    _controllerName.dispose();
    super.dispose();
  }

  /// Processes URL arguments to set the initial state of the screen.
  ///
  /// This method parses the URL for 'room', 'players', and 'mode' query
  /// parameters and configures the screen accordingly. This allows users to
  /// join a game directly via a shared link.
  void _processUrlArguments() {
    if (isRunningOffLine) {
      // For offline testing, use predefined values.
      // Example: '?room=BANANA&players=BOB,SUE,JOHN'
      _playerNames = {'BOB', 'SUE', 'JOHN'};
      _controllerRoom.text = 'BANANA';
      _controllerName.text = 'BOB';
      return;
    }

    // Parse the current URL.
    final uri = Uri.parse(Uri.base.toString());

    // Set the game mode from the 'mode' query parameter.
    final gameModeUrl = uri.queryParameters['mode'] ?? '';
    _selectedGameStyle = intToGameStyles(
      int.tryParse(gameModeUrl) ?? GameStyles.frenchCards9.index,
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
      _playerNames =
          playerNames.toSet(); // Set the list of players in the room.

      // Delay setting players in the room until after the initial data load completes.
      Future.delayed(Duration.zero, () async {
        await useFirebase(); // Ensure Firebase is initialized.
        setPlayersInRoom(
          roomName,
          _playerNames,
        ); // Update the backend with the players.
      });
    }

    // Initialize the backend connection for the room.
    prepareBackEndForRoom(
      roomName,
    );
  }

  /// Prepares the backend for the specified room.
  ///
  /// This method sets up the connection to the backend service (Firebase) for
  /// the given [roomId]. It fetches the initial list of players in the room
  /// and sets up a stream to listen for real-time updates.
  void prepareBackEndForRoom(final String roomId) {
    if (isRunningOffLine) {
      _waitingOnFirstBackendData = false;
      return;
    }

    _waitingOnFirstBackendData = true;

    // Cancel any existing subscription.
    _streamSubscription?.cancel();

    // Fetch the initial data from Firebase.
    useFirebase().then((_) async {
      final List<String> invitees = await getPlayersInRoom(roomId);

      setState(() {
        _playerNames = Set.from(invitees);
        _waitingOnFirstBackendData = false;

        // Listen for updates to the list of invitees.
        _streamSubscription =
            onBackendInviteesUpdated(roomId, (invitees) async {
          final List<String> listOfRooms = await getAllRooms();

          setState(() {
            this._listOfRooms = listOfRooms;
            _playerNames = Set.from(invitees);
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      isWaiting: _waitingOnFirstBackendData,
      title: 'Card Games',
      getLinkToShare: () {
        return _getUrlToGame();
      },
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _gameMode(),
                  IntrinsicHeight(child: _gameInstructionsWidget()),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      editBox(
                        'Room',
                        _controllerRoom,
                        () {
                          _controllerRoom.text =
                              _controllerRoom.text.toUpperCase();
                          prepareBackEndForRoom(roomName);
                        },
                        _errorTextRoom,
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isExpandedRooms = !_isExpandedRooms;
                            });
                          },
                          icon: Icon(
                            _isExpandedRooms
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isExpandedRooms)
                    RoomsWidget(
                      roomId: roomName,
                      rooms: _listOfRooms,
                      onSelected: (String room) {
                        _controllerRoom.text = room;
                        prepareBackEndForRoom(roomName);
                        setState(() {
                          // we can now close the drop down
                          _isExpandedRooms = false;
                        });
                      },
                      onRemoveRoom:
                          _playerName == 'JP' ? (String room) {} : null,
                    ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 400,
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Who Are You?\nSelect above ⬆ or join below ⬇',
                    ),
                  ),
                  const SizedBox(height: 8),
                  editBox(
                    'Join',
                    _controllerName,
                    () {
                      _controllerName.text = _controllerName.text.toUpperCase();
                      joinGame(_controllerName.text);
                    },
                    _errorTextName,
                    IconButton(
                      onPressed: () {
                        setState(() {
                          joinGame(_controllerName.text);
                        });
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  actionButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A widget for selecting the game mode.
  Widget _gameMode() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SegmentedButton<GameStyles>(
        segments: [
          ButtonSegment<GameStyles>(
            value: GameStyles.frenchCards9,
            label: Text('9 Cards'),
          ),
          ButtonSegment<GameStyles>(
            value: GameStyles.skyJo,
            label: Text('SkyJo'),
          ),
          ButtonSegment<GameStyles>(
            value: GameStyles.miniPut,
            label: Text('MiniPut'),
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

  /// A widget that displays the game instructions in an expandable tile.
  Widget _gameInstructionsWidget() {
    return ExpansionTile(
      initiallyExpanded: _isExpandedRules,
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpandedRules = expanded;
        });
      },
      title: Text(
        'Game Rules',
        style: TextStyle(fontSize: 20, color: Colors.green.shade100),
      ),
      children: <Widget>[
        SizedBox(
          height: 500,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GameStyle(style: _selectedGameStyle),
          ),
        ),
      ],
    );
  }

  /// A reusable widget for creating a labeled text input field.
  ///
  /// This widget includes a label, a text field, and a trailing widget (e.g., an
  /// icon button). It is used for both the room name and player name input fields.
  Widget editBox(
    final String label,
    final TextEditingController controller,
    final Function() onSubmitted,
    final String errorStatus,
    final Widget rightSideChild,
  ) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          TextSize(
            label,
            20,
            color: Color.fromARGB(255, 19, 67, 22),
            bold: true,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Type your $label here',
                hintStyle: TextStyle(color: Colors.black.withAlpha(100)),
                errorText: errorStatus.isEmpty ? null : errorStatus,
              ),
              onEditingComplete: onSubmitted,
              onSubmitted: (_) {
                onSubmitted();
              },
              onChanged: (final String text) {
                final String uppercaseText = text.toUpperCase();
                controller.value = controller.value.copyWith(
                  text: uppercaseText,
                  selection:
                      TextSelection.collapsed(offset: uppercaseText.length),
                  composing: TextRange.empty,
                );
              },
            ),
          ),
          rightSideChild,
        ],
      ),
    );
  }

  /// Adds one or more players to the current room.
  ///
  /// This method takes a comma-separated string of names, processes them, and
  /// adds them to the list of players for the current room. It then updates the
  /// backend with the new list of players.
  void joinGame(final String nameOrNamesToAdd) {
    if (nameOrNamesToAdd.trim().isNotEmpty) {
      final List<String> names = nameOrNamesToAdd.toUpperCase().split(',');

      for (final String name in names) {
        _playerNames.add(name.trim());
      }

      setPlayersInRoom(roomName, _playerNames);
      _controllerName.text = names.first;
    }
  }

  /// Removes a player from the current room.
  ///
  /// This method removes the specified player from the list of players and
  /// updates the backend to reflect the change.
  void removePlayer(final String nameToRemove) {
    // Remove the player's name from the list of players.
    _playerNames.remove(nameToRemove);

    // Push the updated list of players to the backend.
    setPlayersInRoom(roomName, _playerNames);
  }

  /// Starts the game and navigates to the game screen.
  ///
  /// This method is called when the user clicks the "Start Game" button. It
  /// creates a new [GameModel] with the current game settings and navigates
  /// to the [GameScreen].
  void startGame(BuildContext context) async {
    final List<GameHistory> history = await getGameHistory(roomName);
    debugLog(history.join('|'));

    final GameModel newGame = GameModel(
      version: appVersion,
      gameStyle: _selectedGameStyle,
      roomName: roomName,
      roomHistory: history,
      loginUserName: _controllerName.text.toUpperCase(),
      names: _playerNames.toList(),
      cardsToDeal: numberOfCards(_selectedGameStyle),
      deck: DeckModel(
        numberOfDecks: numberOfDecks(
          _selectedGameStyle,
          _playerNames.length,
        ),
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
          builder: (context) => GameScreen(gameModel: newGame),
        ),
      );
    }
  }

  /// Generates a shareable URL for the current game.
  ///
  /// This method constructs a URL that includes the current game mode, room name,
  /// and player list, allowing others to join the game directly.
  String _getUrlToGame() {
    if (kIsWeb) {
      return web.window.location.origin +
          GameModel.getLinkToGameFromInput(
            _selectedGameStyle.index.toString(),
            roomName,
            _playerNames.toList(),
          );
    }
    return '';
  }

  /// Updates the browser's URL without reloading the page.
  ///
  /// This method uses the browser's History API to update the URL, which is
  /// useful for reflecting the current game state in the URL without a full
  /// page refresh.
  void _updateUrlWithoutReload() {
    if (kIsWeb) {
      // Push the new state to the browser's history.
      web.window.history.pushState(
        null,
        'vteam cards $roomName',
        _getUrlToGame(),
      );
    }
  }

  /// A button that either joins the current player to the game or starts the game.
  ///
  /// The button's label and action change based on whether the current player
  /// has already joined the game and whether there are enough players to start.
  Widget actionButton() {
    if (_playerName.isEmpty) {
      return const Text('Please enter your name above ⬆');
    }
    bool isPartOfTheList = _playerNames.contains(_playerName.toUpperCase());

    String label = isPartOfTheList
        ? (_playerNames.length > 1
            ? 'Start Game'
            : 'Waiting for players to join')
        : 'Join Game';
    return ElevatedButton(
      onPressed: () {
        if (isPartOfTheList) {
          if (_playerNames.length > 1) {
            startGame(context);
          }
        } else {
          joinGame(_playerName);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
