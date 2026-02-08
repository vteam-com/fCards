import 'dart:async';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_history.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/screens/game/game_style.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/screens/game/game_screen.dart';
import 'package:cards/widgets/helpers/my_button.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/player/players_in_room_widget.dart';
import 'package:cards/widgets/helpers/rooms_widget.dart';
import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:cards/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Step-by-step screen for joining an existing game.
class JoinGameScreen extends StatefulWidget {
  ///
  const JoinGameScreen({super.key});

  @override
  JoinGameScreenState createState() => JoinGameScreenState();
}

///
class JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _controllerName = TextEditingController();

  final TextEditingController _controllerRoom = TextEditingController();

  int _currentStep = 0;

  late List<String> _listOfRooms;

  late String _playerName;

  late Set<String> _playerNames;

  bool _roomsFetched = false;

  late String _selectedRoom;

  StreamSubscription? _streamSubscription;

  bool _waitingOnFirstBackendData = false;

  ///
  late String appVersion;

  @override
  void initState() {
    super.initState();
    _selectedRoom = '';
    _playerName = '';
    _playerNames = {};
    _listOfRooms = [];
    _getAppVersion();
    // Don't fetch rooms immediately - wait until user chooses to join
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _controllerRoom.dispose();
    _controllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      isWaiting: false,
      title: 'Join Game',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(child: _buildStepContent()),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  MyButton(
                    onTap: () => setState(() => _currentStep--),
                    child: Row(
                      mainAxisAlignment: .center,
                      spacing: ConstLayout.sizeM,
                      children: [
                        const Icon(Icons.arrow_back),
                        const Text('Back'),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                MyButton(
                  onTap: _canProceed
                      ? () {
                          if (_currentStep <
                              ConstLayout.joinGameStepCount - 1) {
                            setState(() => _currentStep++);
                          } else {
                            _startGame(context);
                          }
                        }
                      : null,
                  child: Text(
                    _currentStep < ConstLayout.joinGameStepCount - 1
                        ? 'Next'
                        : 'Start Game',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameEntryStep() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_selectedRoom.isNotEmpty && !_waitingOnFirstBackendData) {
      _prepareForRoom(_selectedRoom);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: ConstLayout.sizeL,
      children: [
        Text(
          'Joining Room: $_selectedRoom',
          style: TextStyle(
            fontSize: ConstLayout.textL,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Enter Your Name',
          style: TextStyle(
            fontSize: ConstLayout.textS,
            color: colorScheme.onSurface,
          ),
        ),

        EditBox(
          label: 'Your Name',
          controller: _controllerName,
          onSubmitted: _joinGame,
          errorStatus: '',
          rightSideChild: const SizedBox.shrink(),
        ),

        MyButton(onTap: _joinGame, child: const Text('Join Room')),

        if (_playerName.isNotEmpty)
          Text(
            'Welcome, $_playerName!',
            style: TextStyle(
              fontSize: ConstLayout.textM,
              color: colorScheme.secondary,
            ),
          ),
      ],
    );
  }

  Widget _buildRoomSelectionStep() {
    final colorScheme = Theme.of(context).colorScheme;
    // Fetch rooms if not already done
    if (!_roomsFetched) {
      _roomsFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAllRooms();
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: ConstLayout.sizeM,
      children: [
        Text(
          'Select a Room to Join',
          style: TextStyle(
            fontSize: ConstLayout.textL,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ConstLayout.sizeS),
        Text(
          'Use the search box to quickly find a room',
          style: TextStyle(fontSize: ConstLayout.textS),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ConstLayout.sizeM),
        RoomsWidget(
          roomId: _selectedRoom.isEmpty ? 'SELECT_ROOM' : _selectedRoom,
          rooms: _listOfRooms,
          onSelected: (String room) {
            setState(() {
              _selectedRoom = room;
            });
          },
          onRemoveRoom: null, // No remove for join mode
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildRoomSelectionStep();
      case 1:
        return _buildNameEntryStep();
      case ConstLayout.joinGameStepCount - 1:
        return _buildWaitingStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStepIndicator() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < ConstLayout.joinGameStepCount; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: ConstLayout.sizeXS),
            child: CircleAvatar(
              radius: ConstLayout.circleAvatarRadius,
              backgroundColor: i <= _currentStep
                  ? colorScheme.primary
                  : colorScheme.onSurface,
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWaitingStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: ConstLayout.sizeM,
      children: [
        Text(
          'Room: $_selectedRoom',
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
            'Waiting for more players to join...',
            style: TextStyle(fontSize: ConstLayout.textS),
          )
        else
          Text(
            'Ready to play! ${_playerNames.length} players in room.',
            style: TextStyle(
              fontSize: ConstLayout.textS,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
      ],
    );
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedRoom.isNotEmpty;
      case 1:
        return _playerName.isNotEmpty;
      case ConstLayout.joinGameStepCount - 1:
        return _playerNames.length >= CardModel.minPlayersToStartGame;
      default:
        return false;
    }
  }

  Future<void> _fetchAllRooms() async {
    if (isRunningOffLine) {
      _listOfRooms = ['BANANA', 'KIWI', 'APPLE']; // Demo rooms
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

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

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

  void _prepareForRoom(String roomId) {
    _waitingOnFirstBackendData = true;
    _streamSubscription?.cancel();

    useFirebase().then((_) async {
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
    });
  }

  void _removePlayer(String nameToRemove) {
    _playerNames.remove(nameToRemove);
    setPlayersInRoom(_selectedRoom, _playerNames);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startGame(BuildContext context) async {
    final List<GameHistory> history = await getGameHistory(_selectedRoom);

    final gameModel = GameModel(
      version: appVersion,
      gameStyle: GameStyles.frenchCards9, // Default, could make configurable
      roomName: _selectedRoom,
      roomHistory: history,
      loginUserName: _playerName,
      names: _playerNames.toList(),
      cardsToDeal: numberOfCards(GameStyles.frenchCards9),
      deck: DeckModel(
        numberOfDecks: numberOfDecks(
          GameStyles.frenchCards9,
          _playerNames.length,
        ),
        gameStyle: GameStyles.frenchCards9,
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
