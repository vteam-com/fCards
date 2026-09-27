import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/card/card_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:flutter/material.dart';

const double _miniCardWidth = ConstLayout.sizeM;
const double _miniCardHeight = ConstLayout.sizeL;
const double _miniCardSpacing = ConstLayout.sizeXS;

/// Selectable game type card with a miniature preview of its card grid.
class GameTypeOption extends StatelessWidget {
  /// Creates the option for [gameType].
  const GameTypeOption({
    super.key,
    required this.gameType,
    required this.selected,
    required this.onTap,
  });

  /// Game type this option picks.
  final GameStyles gameType;

  /// Called when the option is tapped.
  final VoidCallback onTap;

  /// Whether this option is the current choice.
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return MyButtonRectangle(
      key: Key('gameType.${gameType.name}'),
      width: double.infinity,
      height: ConstLayout.mainMenuButtonHeight,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ConstLayout.paddingM),
        child: Row(
          spacing: ConstLayout.sizeM,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? colorScheme.tertiary : colorScheme.onSurface,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gameType == GameStyles.skyjo
                        ? localizations.skyjo
                        : localizations.golf9CardsFull,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ConstLayout.textM,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    localizations.columnsByRows(_columns, _rows),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ConstLayout.textS,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            _buildPreview(colorScheme),
          ],
        ),
      ),
    );
  }

  /// Builds a miniature grid mirroring the game's card layout.
  Widget _buildPreview(ColorScheme colorScheme) {
    final Color fill = selected
        ? colorScheme.secondary.withAlpha(ConstLayout.alphaH)
        : colorScheme.surface.withAlpha(ConstLayout.alphaM);
    final Color border = selected
        ? colorScheme.tertiary
        : colorScheme.onSurface.withAlpha(ConstLayout.alphaM);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: _miniCardSpacing,
      children: [
        for (int row = 0; row < _rows; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: _miniCardSpacing,
            children: [
              for (int column = 0; column < _columns; column++)
                Container(
                  width: _miniCardWidth,
                  height: _miniCardHeight,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(ConstLayout.radiusXS),
                    border: Border.all(
                      color: border,
                      width: ConstLayout.strokeXXS,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  int get _columns => gameType == GameStyles.skyjo
      ? CardModel.skyjoColumns
      : CardModel.standardColumns;
  int get _rows => gameType == GameStyles.skyjo
      ? CardModel.skyjoRows
      : CardModel.standardRows;
}
