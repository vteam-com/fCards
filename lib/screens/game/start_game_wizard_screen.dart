import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/card/card_model.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/screens/game/join_game_screen.dart';
import 'package:cards/screens/game/start_game_screen.dart';
import 'package:cards/utils/logger.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/helpers/step_indicator.dart';
import 'package:cards/widgets/helpers/table_widget.dart';
import 'package:flutter/material.dart';

const int _wizardStepCount = 2;
const int _wizardLastStep = 1;
const String _roomSelectionPlaceholder = 'SELECT_ROOM';
const double _miniCardWidth = ConstLayout.sizeM;
const double _miniCardHeight = ConstLayout.sizeL;
const double _miniCardSpacing = ConstLayout.sizeXS;
const List<_GameTypeOption> _gameTypeOptions = <_GameTypeOption>[
  _GameTypeOption(
    style: GameStyles.frenchCards9,
    label: 'Golf 9 Cards',
    columns: CardModel.standardColumns,
    rows: CardModel.standardRows,
  ),
  _GameTypeOption(
    style: GameStyles.miniPut,
    label: 'MiniPut 4 Cards',
    columns: CardModel.miniPutColumns,
    rows: CardModel.miniPutRows,
  ),
  _GameTypeOption(
    style: GameStyles.skyJo,
    label: 'Skylo',
    columns: CardModel.skyjoColumns,
    rows: CardModel.skyjoRows,
  ),
];

class _GameTypeOption {
  const _GameTypeOption({
    required this.columns,
    required this.label,
    required this.rows,
    required this.style,
  });

  final int columns;
  final String label;
  final int rows;
  final GameStyles style;
}

/// Step-by-step entry flow for starting a game.
///
/// Step 1: Select game type.
/// Step 2: Select an existing room or create a new room.
class StartGameWizardScreen extends StatefulWidget {
  ///
  const StartGameWizardScreen({super.key});

  @override
  State<StartGameWizardScreen> createState() => _StartGameWizardScreenState();
}

class _StartGameWizardScreenState extends State<StartGameWizardScreen> {
  int _currentStep = 0;

  bool _isLoadingRooms = false;

  late List<String> _listOfRooms;

  bool _roomsFetched = false;

  late GameStyles _selectedGameStyle;

  @override
  void initState() {
    super.initState();
    _selectedGameStyle = GameStyles.frenchCards9;
    _listOfRooms = [];
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      isWaiting: false,
      title: 'Start Game',
      child: Padding(
        padding: const EdgeInsets.all(ConstLayout.sizeM),
        child: Column(
          children: [
            StepIndicator(
              currentStep: _currentStep,
              stepCount: _wizardStepCount,
            ),
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

  Widget _buildActions() {
    if (_currentStep == 0) {
      return Align(
        alignment: Alignment.centerRight,
        child: MyButtonRectangle(
          onTap: _onNextPressed,
          child: const Text('Next'),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: MyButtonRectangle(
        onTap: () {
          setState(() {
            _currentStep--;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: ConstLayout.sizeM,
          children: [const Icon(Icons.arrow_back), const Text('Back')],
        ),
      ),
    );
  }

  Widget _buildGameStyleOption({
    required int columns,
    required GameStyles style,
    required int rows,
    required String label,
  }) {
    final bool isSelected = _selectedGameStyle == style;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return MyButtonRectangle(
      width: double.infinity,
      height: ConstLayout.mainMenuButtonHeight,
      onTap: () {
        setState(() {
          _selectedGameStyle = style;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ConstLayout.sizeM),
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
                    '$columns x $rows',
                    style: TextStyle(
                      fontSize: ConstLayout.textXS,
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

  Widget _buildGameTypeStep() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: ConstLayout.mainMenuMaxWidth),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: ConstLayout.sizeM,
        children: [
          Text(
            'What type of game?',
            style: TextStyle(
              fontSize: ConstLayout.textL,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          for (final _GameTypeOption option in _gameTypeOptions)
            _buildGameStyleOption(
              columns: option.columns,
              style: option.style,
              rows: option.rows,
              label: option.label,
            ),
        ],
      ),
    );
  }

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

  Widget _buildRoomStep() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (!_roomsFetched) {
      _roomsFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAllRooms();
      });
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: ConstLayout.mainMenuMaxWidth),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: ConstLayout.sizeM,
        children: [
          Text(
            'Pick a table or create a new one',
            style: TextStyle(
              fontSize: ConstLayout.textM,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Tap an existing table to continue',
            style: TextStyle(
              fontSize: ConstLayout.textS,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (_isLoadingRooms)
            const CircularProgressIndicator()
          else if (_listOfRooms.isNotEmpty)
            TableWidget(
              roomId: _roomSelectionPlaceholder,
              rooms: _listOfRooms,
              onSelected: (String room) {
                _navigateToJoinExistingRoom(room);
              },
              onRemoveRoom: null,
            )
          else
            Text(
              'No existing tables found. Create a new one to continue.',
              style: TextStyle(
                fontSize: ConstLayout.textS,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          MyButtonRectangle(
            width: double.infinity,
            onTap: () {
              _navigateToCreateNewGame();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: ConstLayout.sizeS,
              children: [
                const Icon(Icons.add_circle_outline),
                Text(
                  'Create New Table',
                  style: TextStyle(
                    fontSize: ConstLayout.textS,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildGameTypeStep();
      case _wizardLastStep:
        return _buildRoomStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _fetchAllRooms() async {
    if (isRunningOffLine) {
      setState(() {
        _listOfRooms = ['BANANA', 'KIWI', 'APPLE'];
      });
      return;
    }

    setState(() {
      _isLoadingRooms = true;
    });

    try {
      await useFirebase();
      final List<String> rooms = await getAllRooms();
      rooms.sort();

      if (mounted) {
        setState(() {
          _listOfRooms = List.from(rooms);
          _isLoadingRooms = false;
        });
      }
    } catch (e) {
      logger.e('Error fetching rooms in start wizard: $e');
      if (mounted) {
        setState(() {
          _isLoadingRooms = false;
        });
      }
    }
  }

  void _navigateToCreateNewGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext _) => StartScreen(
          joinMode: false,
          initialGameStyle: _selectedGameStyle,
          createRoomFlow: true,
        ),
      ),
    );
  }

  void _navigateToJoinExistingRoom(String room) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext _) =>
            JoinGameScreen(initialRoom: room, gameStyle: _selectedGameStyle),
      ),
    );
  }

  void _onNextPressed() {
    if (_currentStep == 0) {
      setState(() {
        _currentStep = _wizardLastStep;
      });
    }
  }
}
