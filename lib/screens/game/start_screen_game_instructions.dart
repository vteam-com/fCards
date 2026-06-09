import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/screens/game/game_style.dart';
import 'package:flutter/material.dart';

/// Expandable game rules section.
class StartScreenGameInstructions extends StatelessWidget {
  /// Creates a [StartScreenGameInstructions].
  const StartScreenGameInstructions({
    required this.gameStyle,
    required this.isExpanded,
    required this.onExpansionChanged,
    super.key,
  });

  /// Current game style shown in the instructions.
  final GameStyles gameStyle;

  /// Whether the section is expanded.
  final bool isExpanded;

  /// Callback for expansion changes.
  final ValueChanged<bool> onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      initiallyExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      title: Text(
        l10n.gameRules,
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
            child: GameStyle(style: gameStyle),
          ),
        ),
      ],
    );
  }
}
