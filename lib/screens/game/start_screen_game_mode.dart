import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:flutter/material.dart';

/// Segmented control for selecting the game mode.
class StartScreenGameMode extends StatelessWidget {
  /// Creates a [StartScreenGameMode].
  const StartScreenGameMode({
    required this.selectedGameStyle,
    required this.onGameStyleChanged,
    super.key,
  });

  /// Callback when the game style changes.
  final ValueChanged<GameStyles> onGameStyleChanged;

  /// Currently selected game style.
  final GameStyles selectedGameStyle;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(ConstLayout.paddingS),
      child: SegmentedButton<GameStyles>(
        segments: [
          ButtonSegment<GameStyles>(
            value: GameStyles.frenchCards9,
            label: Text(l10n.golf9Cards),
          ),
          ButtonSegment<GameStyles>(
            value: GameStyles.skyjo,
            label: Text(l10n.skyjo),
          ),
          ButtonSegment<GameStyles>(
            value: GameStyles.miniPut,
            label: Text(l10n.miniPut),
          ),
        ],
        selected: {selectedGameStyle},
        onSelectionChanged: (Set<GameStyles> value) {
          onGameStyleChanged(value.first);
        },
      ),
    );
  }
}
