import 'dart:async';
import 'package:cards/models/backend_model.dart';
import 'package:cards/models/game_history.dart';
import 'package:cards/models/game_model.dart';
import 'package:cards/screens/game/game_screen.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/players_in_room_widget.dart';
import 'package:cards/widgets/rooms_widget.dart';
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
  int _currentStep = 0;
  StreamSubscription? _streamSubscription;
  late List<String> _listOfRooms;
  late String _selectedRoom;
  late String _playerName;
  late Set<String> _playerNames;
  bool _roomsFetched = false;

  ///
  late String appVersion;

  final TextEditingController _controllerRoom = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  bool _waitingOnFirstBackendData = false;

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

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
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
      debugPrint('Error fetching rooms: $e');
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

          _streamSubscription =
              onBackendInviteesUpdated(roomId, (invitees) async {
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

  void _removePlayer(String nameToRemove) {
    _playerNames.remove(nameToRemove);
    setPlayersInRoom(_selectedRoom, _playerNames);
    if (mounted) {
      setState(() {});
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedRoom.isNotEmpty;
      case 1:
        return _playerName.isNotEmpty;
      case 2:
        return _playerNames.length >= 2;
      default:
        return false;
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
        numberOfDecks:
            numberOfDecks(GameStyles.frenchCards9, _playerNames.length),
        gameStyle: GameStyles.frenchCards9,
      ),
      isNewGame: true,
    );

    if (mounted) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(gameModel: gameModel),
        ),
      );
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: CircleAvatar(
              radius: 12,
              backgroundColor:
                  i <= _currentStep ? Colors.green[400] : Colors.grey[400],
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
      case 2:
        return _buildWaitingStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildRoomSelectionStep() {
    // Fetch rooms if not already done
    if (!_roomsFetched) {
      _roomsFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAllRooms();
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Select a Room to Join',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
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
        if (_selectedRoom.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[400]!),
            ),
            child: Text(
              'Selected: $_selectedRoom',
              style: const TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNameEntryStep() {
    if (_selectedRoom.isNotEmpty && !_waitingOnFirstBackendData) {
      _prepareForRoom(_selectedRoom);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Joining Room: $_selectedRoom',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          'Enter Your Name',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _controllerName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'YOUR NAME',
              hintStyle: TextStyle(color: Colors.black54),
              border: InputBorder.none,
            ),
            onChanged: (text) {
              _controllerName.value = _controllerName.value.copyWith(
                text: text.toUpperCase(),
              );
            },
            onSubmitted: (_) => _joinGame(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _joinGame,
          child: const Text('Join Room', style: TextStyle(fontSize: 18)),
        ),
        if (_playerName.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Welcome, $_playerName!',
            style: TextStyle(fontSize: 18, color: Colors.yellow[300]),
          ),
        ],
      ],
    );
  }

  Widget _buildWaitingStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Room: $_selectedRoom',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _waitingOnFirstBackendData
            ? const CircularProgressIndicator()
            : Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: PlayersInRoomWidget(
                  activePlayerName: _playerName,
                  playerNames: _playerNames.toList(),
                  onPlayerSelected: (String name) {
                    // Do nothing for join mode
                  },
                  onRemovePlayer: _removePlayer,
                ),
              ),
        const SizedBox(height: 20),
        if (_playerNames.length < 2)
          const Text(
            'Waiting for more players to join...',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          )
        else
          Text(
            'Ready to play! ${_playerNames.length} players in room.',
            style: TextStyle(fontSize: 16, color: Colors.green[400]),
          ),
      ],
    );
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
                child: SingleChildScrollView(
                  child: _buildStepContent(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _currentStep--),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _canProceed
                      ? () {
                          if (_currentStep < 2) {
                            setState(() => _currentStep++);
                          } else {
                            _startGame(context);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _canProceed ? Colors.green[600] : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(_currentStep < 2 ? 'Next' : 'Start Game'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _controllerRoom.dispose();
    _controllerName.dispose();
    super.dispose();
  }
}
