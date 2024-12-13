import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:cards/misc.dart';
import 'package:cards/models/backend_model.dart';
import 'package:cards/models/game_history.dart';
import 'package:cards/models/game_model.dart';
import 'package:cards/screens/game_screen.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/players_in_room_widget.dart';
import 'package:cards/widgets/rooms_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// The initial screen presented to the user, allowing them to join or start a game.
///
/// Users can enter their name and a room name. If the room exists, they can
/// join it; otherwise, a new room is created. The screen displays a list of
/// players currently in the room.  Once at least two players have joined, the
/// game can be started.  The screen also provides a brief explanation of the
/// game's rules.
class StartScreen extends StatefulWidget {
  /// Creates the Start Screen widget.
  const StartScreen({super.key});

  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  /// Subscription to the Firebase Realtime Database.
  StreamSubscription? _streamSubscription;

  GameStyles _selectedGameStyle = GameStyles.frenchCards9;

  /// Controller for the room name text field.
  final TextEditingController _controllerRoom = TextEditingController(
    text: 'KIWI', // Default room name
  );

  String get roomName => _controllerRoom.text.trim().toUpperCase();

  /// Placeholder for room name error text.  Currently unused.
  final String _errorTextRoom = '';

  /// Controller for the player name text field.
  final TextEditingController _controllerName = TextEditingController();

  /// Placeholder for player name error text. Currently unused.
  final String _errorTextName = '';

  /// List of player names currently in the room.
  Set<String> _playerNames = {};
  List<String> _listOfRooms = [];

  /// Returns the trimmed player name entered by the user.
  String get _playerName => _controllerName.text.trim();
  bool _waitingOnFirstBackendData = !isRunningOffLine;
  bool _isExpandedRules = false;
  bool _isExpandedRooms = false;

  @override
  void initState() {
    super.initState();
    _processUrlArguments();
  }

  @override
  void dispose() {
    // Cancel the Firebase subscription to prevent leaks.
    _streamSubscription?.cancel();
    _controllerRoom.dispose();
    _controllerName.dispose();
    super.dispose();
  }

  void _processUrlArguments() {
    if (isRunningOffLine) {
      // '?room=BANANA&players=BOB,SUE,JOHN'
      _playerNames = {'BOB', 'SUE', 'JOHN'};
      _controllerRoom.text = 'BANANA';
      _controllerName.text = 'BOB';
      return;
    }

    // Example URL: https://your-app-url?room=MYROOM&players=PLAYER1,PLAYER2
    final uri = Uri.parse(Uri.base.toString());

    // Mode
    final gameModeUrl = uri.queryParameters['mode'] ?? '';
    _selectedGameStyle = intToGameStyles(
      int.tryParse(gameModeUrl) ?? GameStyles.frenchCards9.index,
    );

    // Room
    final roomFromUrl = uri.queryParameters['room'];
    if (roomFromUrl != null) {
      _controllerRoom.text = roomFromUrl.toUpperCase();
    }

    // Players
    final playersFromUrl = uri.queryParameters['players'];
    if (playersFromUrl != null) {
      final playerNames = playersFromUrl
          .toUpperCase()
          .split(',')
          .map((name) => name.trim())
          .toList();
      _controllerName.text =
          playerNames.first; // Set the first player as the default name
      _playerNames = playerNames
          .toSet(); // or joinGame(playersFromUrl) after initial data load

      //Delay setting players in room until after initial data load completes
      Future.delayed(Duration.zero, () async {
        await useFirebase(); // Ensure Firebase is initialized

        setPlayersInRoom(roomName, _playerNames); // Update backend with players
      });
    }

    prepareBackEndForRoom(
      roomName,
    ); // Initialize backend connection after processing URL arguments.
  }

  void prepareBackEndForRoom(final String roomId) {
    if (isRunningOffLine) {
      _waitingOnFirstBackendData = false;
      return;
    }

    _waitingOnFirstBackendData = true;

    _streamSubscription?.cancel();

    // First pull
    useFirebase().then((_) async {
      final List<String> invitees = await getPlayersInRoom(roomId);

      setState(() {
        _playerNames = Set.from(invitees);
        _waitingOnFirstBackendData = false;
        // Listen for updates
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
        return getUrlToGame();
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
                  gameMode(),
                  IntrinsicHeight(child: gameInstructionsWidget()),
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
                          // we can no close the drop down
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

  Widget gameMode() {
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

  Widget gameInstructionsWidget() {
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
          child: Markdown(
            selectable: true,
            styleSheet: MarkdownStyleSheet(textScaler: TextScaler.linear(1.2)),
            data: gameInstructions(_selectedGameStyle),
            onTapLink: (text, href, title) async {
              if (href != null) {
                await launchUrlString(href);
              }
            },
          ),
        ),
      ],
    );
  }

  /// Widget for creating labeled text input fields.
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

  /// Adds the a player or players to a room.
  ///
  /// Takes a comma-separated string of names, converts them to uppercase,
  /// trims whitespace, and adds them to the list of players.  If the list
  /// already contains the player's name, it does nothing.  Updates the backend
  /// with the new player list. After successfully adding the player, the player
  /// name input field is updated to reflect only the first entered name.
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

  /// Removes a player from the game.
  void removePlayer(final String nameToRemove) {
    // remove the name of player from the list of players
    _playerNames.remove(nameToRemove);

    // push to back end
    setPlayersInRoom(roomName, _playerNames);
  }

  /// Starts the game and navigates to the game screen.
  void startGame(BuildContext context) async {
    final List<GameHistory> history = await getGameHistory(roomName);
    debugLog(history.join('|'));

    final GameModel newGame = GameModel(
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

    // Update URL to include room ID
    updateUrlWithoutReload();

    // bring in the main game screen
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(gameModel: newGame),
        ),
      );
    }
  }

  String getUrlToGame() {
    if (kIsWeb) {
      return html.window.location.origin +
          GameModel.getLinkToGameFromInput(
            _selectedGameStyle.index.toString(),
            roomName,
            _playerNames.toList(),
          );
    }
    return '';
  }

  void updateUrlWithoutReload() {
    if (kIsWeb) {
      // Push the new state to the browser's history
      html.window.history.pushState(
        null,
        'vteam cards $roomName',
        getUrlToGame(),
      );
    }
  }

  /// Widget for the "Join Game" or "Start Game" button.
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
