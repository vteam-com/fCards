import 'dart:async';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_history.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/screens/game/game_screen.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/player/players_in_room_widget.dart';
import 'package:cards/widgets/helpers/table_widget.dart';
import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:cards/widgets/helpers/step_indicator.dart';
import 'package:cards/widgets/helpers/wizard_footer.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

const String _selectRoomPlaceholder = 'SELECT_ROOM';

/// Step-by-step screen for joining an existing game.
class JoinGameScreen extends StatefulWidget {
  ///
  const JoinGameScreen({
    super.key,
    this.initialRoom,
    this.gameStyle = GameStyles.frenchCards9,
  });

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

  late String _playerName;

  late Set<String> _playerNames;

  late String _preparedRoom;

  bool _roomsFetched = false;

  late GameStyles _selectedGameStyle;

  late String _selectedRoom;

  StreamSubscription? _streamSubscription;

  bool _waitingOnFirstBackendData = false;

  ///
  late String appVersion;

  @override
  void initState() {
    super.initState();
    _selectedGameStyle = widget.gameStyle;
    _selectedRoom = widget.initialRoom?.trim().toUpperCase() ?? '';
    _playerName = '';
    _playerNames = {};
    _preparedRoom = '';
    _listOfRooms = [];
    _currentStep = _selectedRoom.isNotEmpty ? 1 : 0;
    _getAppVersion();
    // Don't fetch rooms immediately - wait until user chooses to join
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
      title: localizations.joinGameTitle,
      child: Padding(
        padding: const EdgeInsets.all(ConstLayout.sizeM),
        child: Column(
          children: [
            StepIndicator(
              currentStep: _currentStep,
              stepCount: ConstLayout.joinGameStepCount,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(child: _buildStepContent()),
              ),
            ),
            WizardFooter(
              backLabel: localizations.back,
              onBack: _currentStep > 0
                  ? () => setState(() => _currentStep--)
                  : null,
              primaryLabel: _currentStep < ConstLayout.joinGameStepCount - 1
                  ? localizations.next
                  : localizations.startGame,
              isPrimaryEnabled: _canProceed,
              onForward: !_isSingleCtaStep
                  ? () {
                      if (_currentStep < ConstLayout.joinGameStepCount - 1) {
                        setState(() => _currentStep++);
                      } else {
                        _startGame(context);
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the step where the player enters a name before joining the room.
  Widget _buildNameEntryStep() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    _prepareForSelectedRoomIfNeeded();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: ConstLayout.sizeL,
      children: [
        Text(
          localizations.joiningTable(_selectedRoom),
          style: TextStyle(
            fontSize: ConstLayout.textL,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          localizations.enterYourName,
          style: TextStyle(
            fontSize: ConstLayout.textS,
            color: colorScheme.onSurface,
          ),
        ),

        EditBox(
          label: localizations.yourName,
          controller: _controllerName,
          onSubmitted: _joinGameAndContinue,
          errorStatus: '',
          rightSideChild: const SizedBox.shrink(),
        ),

        MyButtonRectangle(
          onTap: _joinGameAndContinue,
          child: Text(localizations.joinTable),
        ),

        if (_playerName.isNotEmpty)
          Text(
            localizations.welcomePlayer(_playerName),
            style: TextStyle(
              fontSize: ConstLayout.textM,
              color: colorScheme.secondary,
            ),
          ),
      ],
    );
  }

  /// Builds the room selection step with searchable available tables.
  Widget _buildRoomSelectionStep() {
    final AppLocalizations localizations = AppLocalizations.of(context);
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
          localizations.selectTableToJoin,
          style: TextStyle(
            fontSize: ConstLayout.textL,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ConstLayout.sizeS),
        Text(
          localizations.useSearchBox,
          style: TextStyle(fontSize: ConstLayout.textS),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ConstLayout.sizeM),
        TableWidget(
          roomId: _selectedRoom.isEmpty
              ? _selectRoomPlaceholder
              : _selectedRoom,
          rooms: _listOfRooms,
          onSelected: (String room) {
            setState(() {
              _selectedRoom = room;
              _preparedRoom = '';
            });
          },
          onRemoveRoom: null, // No remove for join mode
        ),
      ],
    );
  }

  /// Returns the widget content for the currently active wizard step.
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

  /// Builds the waiting step that shows current players before game start.
  Widget _buildWaitingStep() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
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

  /// Loads all joinable rooms from backend (or demo data when offline).
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

  bool get _isSingleCtaStep => _currentStep == 1;

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
  void _joinGameAndContinue() {
    _joinGame();
    if (_playerName.isEmpty) {
      return;
    }

    if (_currentStep < ConstLayout.joinGameStepCount - 1) {
      setState(() {
        _currentStep++;
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
