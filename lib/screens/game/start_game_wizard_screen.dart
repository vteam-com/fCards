import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/card/card_model.dart';
import 'package:cards/models/game/game_constants.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/screens/game/create_table_name_screen.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:cards/widgets/helpers/wizard_footer.dart';
import 'package:flutter/material.dart';

const int _wizardGameTypeStep = 0;
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

/// Step-by-step entry flow for starting a game.
///
/// Step 1: Select the game type.
/// Step 2: Continue into guided table setup.
class StartGameWizardScreen extends StatefulWidget {
  ///
  const StartGameWizardScreen({super.key});

  @override
  State<StartGameWizardScreen> createState() => _StartGameWizardScreenState();
}

class _StartGameWizardScreenState extends State<StartGameWizardScreen> {
  int _currentStep = 0;
  late GameStyles _selectedGameStyle;
  @override
  void initState() {
    super.initState();
    _selectedGameStyle = GameStyles.frenchCards9;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Screen(
      isWaiting: false,
      title: localizations.startTable,
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
    if (_currentStep == _wizardGameTypeStep) {
      return WizardFooter(
        backLabel: localizations.back,
        onBack: null,
        primaryLabel: localizations.next,
        isPrimaryEnabled: true,
        onForward: _onNextPressed,
      );
    }

    return WizardFooter(
      backLabel: localizations.back,
      onBack: () {
        setState(() {
          _currentStep--;
        });
      },
      primaryLabel: localizations.next,
      isPrimaryEnabled: false,
      onForward: null,
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
      onTap: () {
        setState(() {
          _selectedGameStyle = style;
        });
      },
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

  /// Builds the first wizard step where a game style is selected.
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

  /// Returns the active wizard step content.
  Widget _buildStepContent() {
    switch (_currentStep) {
      case _wizardGameTypeStep:
        return _buildGameTypeStep();
      default:
        return const SizedBox.shrink();
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

  /// Navigates to the create-room flow using the selected game style.
  void _navigateToCreateNewGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext _) =>
            CreateTableNameScreen(gameStyle: _selectedGameStyle),
      ),
    );
  }

  /// Advances from game choice into guided table setup.
  void _onNextPressed() {
    if (_currentStep == _wizardGameTypeStep) {
      _navigateToCreateNewGame();
    }
  }
}
